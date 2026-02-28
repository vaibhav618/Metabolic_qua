import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

// Model Imports
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/practice_test/data/services/practice_service.dart';
import '../../../../../client-dashboard/data/model/dietitian_model.dart';

// Bloc Imports
import '../../../../../client-dashboard/today_result/today_test_data_bloc.dart';
import '../../../../../client-dashboard/today_result/today_test_data_state.dart';
import '../../../../../client-dashboard/today_result/today_test_data_event.dart';
import '../../../../../client-dashboard/today_result/today_test_data_repository.dart';
import '../../../../../client-dashboard/today_result/today_test_data_api_service.dart';
import '../../../menu/presentation/screens/menu.dart';
import '../../bloc/latest_test_bloc.dart';
import '../../bloc/latest_test_event.dart';
import '../../bloc/latest_test_state.dart';
import '../../../../../common/dialogs/abort_sheet_dialog.dart';
import '../../../../../common/dialogs/floating_message.dart';
import '../../../../../common/widgets/abort_device_manager.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../bluetooth_device_connectivity/domain/params/result_screen_params.dart';
import '../../../../dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';
import '../../../../gifting/dashboard/services/complete_test_history.dart';
import '../../../../profile_info/data/model/dietician_detail_model.dart';
import '../../../presentation/widgets/loading_screen.dart';
import '../../core/color_manager.dart';
import '../../data/models/latest_test_data.dart';
import '../../data/repository/latest_test_repository.dart';
import '../../data/services/latest_test_service.dart';
import '../widgets/dietitian_info.dart';
import '../widgets/hero_calender_widget.dart';
import '../widgets/score_chart.dart';

class QuaDashboard extends StatefulWidget {
  final ClientProfileModel clientProfile;
  final DietitianDetailModel? dietitianDetailModel;

  final double currentMinRange;
  final double currentMaxRange;

  const QuaDashboard({
    super.key,
    required this.clientProfile,
    this.dietitianDetailModel,
    required this.currentMinRange,
    required this.currentMaxRange,
  });

  @override
  State<QuaDashboard> createState() => _QuaDashboardState();
}

class _QuaDashboardState extends State<QuaDashboard>
    with WidgetsBindingObserver {
  late final LatestTestBloc _latestTestBloc;
  late final TodayTestDataBloc _todayTestDataBloc;

  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _dateList = [];

  // ✅ Industry-standard refresh guards
  bool _refreshing = false;
  DateTime _lastRefreshAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _minRefreshGap = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeBlocs();
    _refreshData();

    Future.microtask(() async {
      await _requestRuntimePermissions();
      await _warmUpFcmToken();
    });
  }

  Future<void> _requestRuntimePermissions() async {
    try {
      await [
        Permission.notification,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
    } catch (_) {}
  }

  Future<void> _warmUpFcmToken() async {
    try {
      await FirebaseMessaging.instance.getToken();
    } catch (_) {}
  }

  void _initializeBlocs() {
    _latestTestBloc =
        LatestTestBloc(repo: LatestTestRepository(LatestTestService()));
    _todayTestDataBloc =
        TodayTestDataBloc(TodayTestDataRepository(TodayTestDataApiService()));
  }

  // ✅ Same name, but now safe: throttled + single-flight
  void _refreshData({bool force = false}) {
    final now = DateTime.now();

    if (_refreshing) return;
    if (!force && now.difference(_lastRefreshAt) < _minRefreshGap) return;

    _refreshing = true;
    _lastRefreshAt = now;

    final dateStr = DateHelper.formatDate(_selectedDate);

    _latestTestBloc.add(
      FetchLatestTest(
        dietitianId: widget.clientProfile.dietitianId.toString(),
        profileId: widget.clientProfile.profileId.toString(),
        date: dateStr,
      ),
    );

    _todayTestDataBloc.add(
      LoadTestDataForDay(
        dietitianId: widget.clientProfile.dietitianId.toString(),
        profileId: widget.clientProfile.profileId.toString(),
        date: _selectedDate,
      ),
    );

    // release lock quickly to keep UI snappy but avoid spam
    Future.delayed(const Duration(milliseconds: 400), () {
      _refreshing = false;
    });
  }

  // ✅ for RefreshIndicator
  Future<void> _refreshDataAsync({bool force = false}) async {
    _refreshData(force: force);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _latestTestBloc.close();
    _todayTestDataBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(); // ✅ now safe & throttled
    }
  }

  Future<void> _handleStartTest(TestDataState state) async {
    // 1. Get the Profile ID
    final profileId = widget.clientProfile.profileId;

    // 2. Show a loading indicator so the app doesn't look stuck during API call
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF308BF9)),
      ),
    );

    // ... inside _handleStartTest
    final bool needsPractice =
        await PracticeService().checkNeedsPractice(profileId);

    if (!mounted) return;

    // Close the loading dialog safely
    Navigator.of(context, rootNavigator: true).pop();

    // Add this tiny delay to let the dialog close before pushing a new screen
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    if (needsPractice) {
      context.push(AppRoutes.practiceFlowShell, extra: widget.clientProfile);
    } else {
      _navigateToBluetooth(state);
    }
  }

  Future<void> _navigateToBluetooth(TestDataState state) async {
    await _requestRuntimePermissions();
    if (!mounted) return;

    final connected = FlutterBluePlus.connectedDevices;

    // ✅ IMPORTANT: await push, then refresh AFTER coming back
    if (connected.isEmpty) {
      await context.push(
        AppRoutes.bluetoothDeviceStartTest,
        extra: {
          "client": widget.clientProfile,
          "strategy": _generateMockStrategy(),
          "min_range": widget.currentMinRange,
          "max_range": widget.currentMaxRange,
          "is_test_taken": state.result != null,
        },
      );
    } else {
      await context.push(
        AppRoutes.bluetoothDeviceConnectivity,
        extra: {
          "client": widget.clientProfile,
          "strategy": _generateMockStrategy(),
          "min_range": widget.currentMinRange,
          "max_range": widget.currentMaxRange,
          "is_test_taken": state.result != null,
        },
      );
    }

    if (!mounted) return;
    _refreshData(force: true); // ✅ correct timing
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _latestTestBloc),
        BlocProvider.value(value: _todayTestDataBloc),
      ],
      child: const _QuaDashboardBody(),
    );
  }
}

class _QuaDashboardBody extends StatelessWidget {
  const _QuaDashboardBody();

  @override
  Widget build(BuildContext context) {
    final stateful = context.findAncestorStateOfType<_QuaDashboardState>()!;
    final widgetRef = stateful.widget;
    DateTime? _lastBackPressed;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final now = DateTime.now();

        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit"),
              duration: Duration(seconds: 2),
            ),
          );

          return;
        }

        SystemNavigator.pop();
      },
      child: BlocBuilder<LatestTestBloc, LatestTestState>(
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType || curr is LatestTestLoaded,
        builder: (context, state) {
          if (state is LatestTestLoading) return const LoadingScreen();

          final LatestTestData? testData =
              state is LatestTestLoaded ? state.data : null;
          final bool hasData = testData != null;

          final String? zone =
              testData?.testJsonData?.fatLossMetabolismScore?.zone;

          final Color themeColor = (hasData && zone != null)
              ? ColorManager.getZoneColor(zone: zone)
              : const Color(0xFFA5A9AF);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: themeColor,
              toolbarHeight: 0,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  _ScrollableContent(
                    hasData: hasData,
                    data: testData,
                    themeColor: themeColor,
                    clientProfile: widgetRef.clientProfile,
                    dietitianDetailModel: widgetRef.dietitianDetailModel,
                    currentMinRange: widgetRef.currentMinRange,
                    currentMaxRange: widgetRef.currentMaxRange,
                    selectedDate: stateful._selectedDate,
                    dateList: stateful._dateList,
                    onDateSelected: (date) {
                      stateful.setState(() => stateful._selectedDate = date);
                      stateful._refreshData(force: true);
                    },
                    navigateToDetailedResult: (testId) =>
                        stateful._navigateToDetailedResult(testId),
                  ),
                  _SwipeActionOverlay(
                    clientProfile: widgetRef.clientProfile,
                    onSwiped: (testState) =>
                        stateful._handleStartTest(testState),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScrollableContent extends StatelessWidget {
  final bool hasData;
  final LatestTestData? data;
  final Color themeColor;

  final ClientProfileModel clientProfile;
  final DietitianDetailModel? dietitianDetailModel;

  final double currentMinRange;
  final double currentMaxRange;

  final DateTime selectedDate;
  final List<DateTime> dateList;

  final ValueChanged<DateTime> onDateSelected;
  final Future<void> Function(String testId) navigateToDetailedResult;

  const _ScrollableContent({
    required this.hasData,
    required this.data,
    required this.themeColor,
    required this.clientProfile,
    required this.dietitianDetailModel,
    required this.currentMinRange,
    required this.currentMaxRange,
    required this.selectedDate,
    required this.dateList,
    required this.onDateSelected,
    required this.navigateToDetailedResult,
  });

  @override
  Widget build(BuildContext context) {
    final stateful = context.findAncestorStateOfType<_QuaDashboardState>()!;

    final double minRange = data?.minRange ?? currentMinRange;
    final double maxRange = data?.maxRange ?? currentMaxRange;

    final double latestScore =
        data?.testJsonData?.fatLossMetabolismScore?.score.toDouble() ?? 0.0;

    // ✅ Industry-standard Pull to Refresh
    return RefreshIndicator(
      onRefresh: () => stateful._refreshDataAsync(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _GradientHeader(
              color: themeColor,
              hasData: hasData,
              data: data,
              clientProfile: clientProfile,
              selectedDate: selectedDate,
              dateList: dateList,
              onDateSelected: onDateSelected,
            ),
            SizedBox(height: rh(context: context, px: 0)),
            if (hasData && data != null)
              OutlinedButton(
                onPressed: () {
                  navigateToDetailedResult(data!.testId);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    Text(
                      "View Result",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF308BF9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.24,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined)
                  ],
                ),
              ),
            SizedBox(height: rh(context: context, px: 100)),
            ScoreChart(
              clientProfileModel: clientProfile,
              latestScore: latestScore,
              latestScoreMinRange: minRange,
              latestScoreMaxRange: maxRange,
            ),
            SizedBox(height: rh(context: context, px: 24)),
            DietitianInfo(dietitianDetailModel: dietitianDetailModel),
            Padding(
              padding: EdgeInsetsGeometry.directional(top: 20),
            ),
            // SizedBox(
            //   height: 45, // Much shorter than the previous 61px
            //   child: OutlinedButton.icon(
            //     onPressed: () {
            //       context.push(
            //         AppRoutes.practiceFlowShell,
            //         extra: clientProfile,
            //       );
            //     },
            //     // Adding a small icon makes it look much more professional
            //     icon: const Icon(
            //       Icons.play_circle_outline,
            //       color: Color(0xFF308BF9),
            //       size: 20,
            //     ),
            //     style: OutlinedButton.styleFrom(
            //       elevation: 0,
            //       padding: const EdgeInsets.symmetric(
            //           horizontal: 20), // Keeps it compact
            //       side: const BorderSide(
            //         color: Color(0xFF308BF9), // Blue border
            //         width: 1.5,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30), // Pill shape
            //       ),
            //     ),
            //     label: Text(
            //       "Try Practice Test",
            //       style: GoogleFonts.poppins(
            //         color: const Color(
            //             0xFF308BF9), // Blue text to match the border
            //         fontSize: 14, // Slightly smaller text
            //         fontWeight:
            //             FontWeight.w600, // Semi-bold instead of heavy bold
            //       ),
            //     ),
            //   ),
            // ),
            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.selectClient);
                },
                child: const Text("Select Client"),
              ),
            ),
            Visibility(
              visible: false,
              child: ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.whoIsUsing);
                },
                child: const Text("Who is using"),
              ),
            ),
            SizedBox(height: rh(context: context, px: 120)),
          ],
        ),
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  final Color color;
  final bool hasData;
  final LatestTestData? data;

  final ClientProfileModel clientProfile;
  final DateTime selectedDate;
  final List<DateTime> dateList;
  final ValueChanged<DateTime> onDateSelected;

  const _GradientHeader({
    required this.color,
    required this.hasData,
    required this.data,
    required this.clientProfile,
    required this.selectedDate,
    required this.dateList,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scoreObj = data?.testJsonData?.fatLossMetabolismScore;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.50, 0.00),
          end: const Alignment(0.50, 1.00),
          colors: [color, Colors.white],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopNavBar(clientProfile: clientProfile),
            HeroCalenderWidget(
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
              dateList: dateList,
            ),
            SizedBox(height: rh(context: context, px: 40)),
            if (hasData && scoreObj != null) ...[
              _ScoreDisplay(fatLossScore: scoreObj),
              SizedBox(height: rh(context: context, px: 60)),
              _ZoneInfoCard(themeColor: color, score: scoreObj),
            ] else ...[
              SizedBox(height: rh(context: context, px: 40)),
              _NoDataPrompt(selectedDate: selectedDate),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final ClientProfileModel clientProfile;
  const _TopNavBar({required this.clientProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rh(context: context, px: 20),
        vertical: rh(context: context, px: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clientProfile.profileName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 12),
                ),
              ),
              Text(
                DateHelper.getGreeting(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _ProfileCircle(clientProfile: clientProfile),
        ],
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final dynamic fatLossScore;
  const _ScoreDisplay({required this.fatLossScore});

  @override
  Widget build(BuildContext context) {
    final num score = fatLossScore.score ?? 0;

    return Column(
      children: [
        Text(
          "Fat-Use Pattern Trend",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: rh(context: context, px: 18),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: rh(context: context, px: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              score.toDouble().toStringAsFixed(0),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 100),
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(width: rh(context: context, px: 4)),
            Text(
              "%",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ZoneInfoCard extends StatelessWidget {
  final Color themeColor;
  final dynamic score;
  const _ZoneInfoCard({required this.themeColor, required this.score});

  @override
  Widget build(BuildContext context) {
    final String zone = score.zone ?? "NA";
    final String interpretation = score.clientInterpretation ?? "";
    final String zoneBase = zone.toLowerCase() == "focus" ? "needs to" : "is";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: rh(context: context, px: 16)),
      padding: EdgeInsets.all(rh(context: context, px: 20)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rh(context: context, px: 30)),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Your Score $zoneBase $zone!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: themeColor,
              fontSize: rh(context: context, px: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: rh(context: context, px: 12)),
          Text(
            interpretation,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF4A4A4A),
              fontSize: rh(context: context, px: 13),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataPrompt extends StatelessWidget {
  final DateTime selectedDate;
  const _NoDataPrompt({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final bool isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: rh(context: context, px: 16)),
      padding: EdgeInsets.symmetric(
        vertical: rh(context: context, px: 40),
        horizontal: rh(context: context, px: 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rh(context: context, px: 30)),
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/images/icons/no_test.svg",
            height: rh(context: context, px: 80),
          ),
          SizedBox(height: rh(context: context, px: 24)),
          Text(
            isToday ? "You Haven’t Tested\nYet Today" : "No Test Data Found",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: rh(context: context, px: 22),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: rh(context: context, px: 8)),
          Text(
            isToday
                ? "Swipe below to start \nyour metabolism test!"
                : "Select another date to see\nyour history.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: rh(context: context, px: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionOverlay extends StatelessWidget {
  final ClientProfileModel clientProfile;
  final void Function(TestDataState testState) onSwiped;

  const _SwipeActionOverlay({
    required this.clientProfile,
    required this.onSwiped,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: rh(context: context, px: 30),
      left: 0,
      right: 0,
      child: BlocBuilder<TodayTestDataBloc, TestDataState>(
        buildWhen: (prev, curr) => prev.result != curr.result,
        builder: (context, testState) {
          // final dietitianId = clientProfile.dietitianId?.trim().toLowerCase();
          if (testState.result != null) {
            return const SizedBox.shrink();
          }

          return Center(
            child: SwipeButtonWidget(
              onSwiped: () {
                onSwiped(testState);
              },
            ),
          );
        },
      ),
    );
  }
}

extension on _QuaDashboardState {
  Future<void> _navigateToDetailedResult(String testId) async {
    try {
      final result =
          await TestHistoryCompleteService.fetchTestHistoryCompleteNew(
        dietitianId: widget.clientProfile.dietitianId,
        profileId: widget.clientProfile.profileId,
        testId: int.parse(testId),
      );

      if (!mounted) return;

      context.go(
        AppRoutes.dietitianResultScreen,
        extra: ResultScreenParamsNew(
          result: result,
          clientProfileModel: widget.clientProfile,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      FloatingMessage.show(
        context,
        message: "Could not load result: $e",
        type: FloatingMessageType.error,
      );
    }
  }

  DietPlanStrategyModel _generateMockStrategy() {
    return DietPlanStrategyModel(
      id: -1,
      dietitianId: widget.clientProfile.dietitianId.toString(),
      clientId: widget.clientProfile.profileId.toString(),
      planTitle: "Standard Metabolism Protocol",
      dietType: "Balanced",
      planStartDate: DateTime.now(),
      planEndDate: DateTime.now().add(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      caloriesTarget: 2000,
      proteinTarget: 150,
      fiberTarget: 30,
      carbsTarget: 200,
      fatTarget: 70,
      waterTarget: 3.5,
      testNoAssigned: 1,
      isDiabetic: false,
      status: "active",
      goals: const [],
      approaches: const [],
      dietitianInfo: DietitianModel(
        id: 0,
        dietitianId: "N/A",
        name: widget.dietitianDetailModel?.name ?? "Dietitian",
        email: "",
        phoneNo: "",
        location: "",
        logo: "",
        dttm: "",
        password: "",
      ),
    );
  }
}

class _ProfileCircle extends StatelessWidget {
  final ClientProfileModel clientProfile;
  const _ProfileCircle({required this.clientProfile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardMenuScreen(clientProfileModel: clientProfile),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(rh(context: context, px: 8)),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          "assets/images/icons/ic_profile.svg",
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          width: rh(context: context, px: 24),
          height: rh(context: context, px: 24),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/core/utils/bmi_bmr_conversion.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/domain/dietitian_result_view_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/bmi_bmr_widget.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/metabolism_card.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/section_widget.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/sliver_tabbar_delegate.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/tab_widget.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../core/size/get_height.dart';

class DietitianResultScreen extends StatefulWidget {
  final GeneratingResultModel result;
  final ClientProfileModel clientProfileModel;

  const DietitianResultScreen({
    super.key,
    required this.result,
    required this.clientProfileModel,
  });

  @override
  State<DietitianResultScreen> createState() => _DietitianResultScreenState();
}

class _DietitianResultScreenState extends State<DietitianResultScreen>
    with WidgetsBindingObserver {
  final viewModel = DietitianResultViewModel();
  Timer? _scrollDebounce;

  double? _gutOffset;
  double? _fatOffset;
  double? _liverOffset;
  bool _offsetsComputed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel.scrollController.addListener(_onVerticalScroll);
  }

  @override
  void didChangeMetrics() {
    _offsetsComputed = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());
    super.didChangeMetrics();
  }

  void _onVerticalScroll() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _handleScrollPosition();
    });
  }

  void _handleScrollPosition() {
    if (!viewModel.tabScrollController.hasClients || viewModel.isAnimating) return;

    final offset = viewModel.scrollController.offset;
    final cubit = context.read<DietitianResultCubit>();

    if (!_offsetsComputed) {
      _computeSectionOffsetsIfNeeded();
      return;
    }

    if (_gutOffset == null || _fatOffset == null || _liverOffset == null) return;

    final gutPos = _gutOffset!;
    final fatPos = _fatOffset!;
    final liverPos = _liverOffset!;

    if (offset >= gutPos && offset < fatPos && cubit.state.selectedTab != "Gut") {
      cubit.changeTab("Gut");
      viewModel.tabScrollTo(viewModel.tabGutKey);
    } else if (offset >= fatPos && offset < liverPos && cubit.state.selectedTab != "Fat") {
      cubit.changeTab("Fat");
      viewModel.tabScrollTo(viewModel.tabFatKey);
    } else if (offset >= liverPos && cubit.state.selectedTab != "Liver") {
      cubit.changeTab("Liver");
      viewModel.tabScrollTo(viewModel.tabLiverKey);
    }
  }

  void _computeSectionOffsetsIfNeeded() {
    // if (!mounted) return;
    // if (_offsetsComputed) return;
    //
    // try {
    //   final gutCtx = viewModel.gutKey.currentContext;
    //   final fatCtx = viewModel.fatKey.currentContext;
    //   final liverCtx = viewModel.liverKey.currentContext;
    //
    //   if (gutCtx == null || fatCtx == null || liverCtx == null) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());
    //     return;
    //   }
    //
    //   final scrollOffset = viewModel.scrollController.offset;
    //
    //   final gutBox = gutCtx.findRenderObject() as RenderBox;
    //   final fatBox = fatCtx.findRenderObject() as RenderBox;
    //   final liverBox = liverCtx.findRenderObject() as RenderBox;
    //
    //   _gutOffset = gutBox.localToGlobal(Offset.zero).dy + scrollOffset;
    //   _fatOffset = fatBox.localToGlobal(Offset.zero).dy + scrollOffset;
    //   _liverOffset = liverBox.localToGlobal(Offset.zero).dy + scrollOffset;
    //
    //   _offsetsComputed = true;
    // } catch (_) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollDebounce?.cancel();
    viewModel.scrollController.removeListener(_onVerticalScroll);
    viewModel.scrollController.dispose();
    viewModel.tabScrollController.dispose();
    super.dispose();
  }

  Future<bool> navToDashboard(BuildContext context) async {
    bool didCancel = false;
    if (context.mounted) {
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
    }
    return didCancel;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await navToDashboard(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: BlocBuilder<DietitianResultCubit, DietitianResultState>(
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());

                  return CustomScrollView(
                    controller: viewModel.scrollController,
                    slivers: [
                      _buildAppBar(context),
                      _buildOverviewSection(context, state),
                      _buildStickyTabs(context, state),
                      _buildSections(context, state),
                      SliverToBoxAdapter(child: SizedBox(height: rh(context: context, px: 90))),
                      _buildDisclaimer(),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: rh(context: context, px: 12),
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF308BF9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rh(context: context, px: 50)),
                    ),
                    padding: EdgeInsets.all(rh(context: context, px: 16)),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dttm) {
    if (dttm == null || dttm.isEmpty) return '';
    try {
      final date = DateTime.parse(dttm).toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(date);
    } catch (_) {
      return dttm;
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF308BF9),
      expandedHeight: rh(context: context, px: 50),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: rh(context: context, px: 5),
                  children: [
                    Text(
                      widget.clientProfileModel.profileName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 18),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: rh(context: context, px: -0.72),
                      ),
                    ),
                    Text(
                      formatDateTime(widget.result.dateTime),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 10),
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                        letterSpacing: rh(context: context, px: -0.2),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => navToDashboard(context),
                  icon: SvgPicture.asset(
                    "assets/images/common/closeicon.svg",
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDateTime(DateTime input) {
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    String day = input.day.toString().padLeft(2, '0');
    String month = months[input.month - 1];
    String year = input.year.toString();

    int hour = input.hour % 12 == 0 ? 12 : input.hour % 12;
    String minute = input.minute.toString().padLeft(2, '0');
    String ampm = input.hour >= 12 ? "PM" : "AM";

    return "$day $month $year, $hour:$minute $ampm";
  }

  Widget _buildOverviewSection(BuildContext context, DietitianResultState state) {
    final rawWeight = widget.clientProfileModel.weight;
    final rawHeight = widget.clientProfileModel.height;
    final rawAge = widget.clientProfileModel.age;
    final gender = widget.clientProfileModel.gender;

    final weight = double.tryParse(rawWeight.toString()) ?? 0.0;
    final height = double.tryParse(rawHeight.toString()) ?? 0.0;
    final age = int.tryParse(rawAge.toString()) ?? 0;

    final bmi = BmiBmrUtils.calculateBMI(weightKg: weight, heightCm: height);
    final bmr = BmiBmrUtils.calculateBMR(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: gender,
    );

    Color getZoneColor(String zone) {
      switch (zone.toLowerCase()) {
        case "poor":
          return const Color(0xFFDA5747);
        case "fair":
          return const Color(0xFFF8B10F);
        case "good":
          return const Color(0xFF3FAF58);
        default:
          return Colors.grey;
      }
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 16),
              vertical: rh(context: context, px: 10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: rh(context: context, px: 1),
                        color: const Color(0xFFC7C6CE),
                      ),
                      borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: rh(context: context, px: 14),
                    horizontal: rh(context: context, px: 17),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Overall\nMetabolism Score",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 20),
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: rh(context: context, px: -0.40),
                          ),
                        ),
                      ),
                      SizedBox(width: rh(context: context, px: 20)),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              "${widget.result.respyrResponse.fatLossMetabolismScore.score.toStringAsFixed(0)}%",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 34),
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: rh(context: context, px: -2.04),
                              ),
                            ),
                            Text(
                              widget.result.respyrResponse.fatLossMetabolismScore.zone,
                              style: GoogleFonts.poppins(
                                color: getZoneColor(widget.result.respyrResponse.fatLossMetabolismScore.zone),
                                fontSize: rh(context: context, px: 12),
                                fontWeight: FontWeight.w700,
                                height: 1.10,
                                letterSpacing: rh(context: context, px: -0.24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rh(context: context, px: 30)),
                Text(
                  'Scores Overview',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: rh(context: context, px: -0.4),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  "assets/images/result_screen/dietitian.png",
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 10)),
                  child: Column(
                    children: [
                      SizedBox(height: rh(context: context, px: 15)),
                      MetabolismCard(
                        metabolismType: 'Liver',
                        state: state,
                        result: widget.result,
                      ),
                      SizedBox(height: rh(context: context, px: 25)),
                      MetabolismCard(
                        metabolismType: 'Fat',
                        state: state,
                        result: widget.result,
                      ),
                      SizedBox(height: rh(context: context, px: 25)),
                      MetabolismCard(
                        metabolismType: 'Gut',
                        state: state,
                        result: widget.result,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 16),
              vertical: rh(context: context, px: 10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scores Interpretation',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: rh(context: context, px: -0.4),
                  ),
                ),
                SizedBox(height: rh(context: context, px: 8)),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 12),
                      fontWeight: FontWeight.w400,
                      height: 1.26,
                      letterSpacing: rh(context: context, px: -0.24),
                    ),
                    children: [
                      const TextSpan(
                        text:
                        'Scores interpretations are based on the values recorded by Respyr device. Please refer to the reference ',
                      ),
                      TextSpan(
                        text: 'link',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF308BF9),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: ' for more details.'),
                    ],
                  ),
                ),
                SizedBox(height: rh(context: context, px: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyTabs(BuildContext context, DietitianResultState state) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverTabBarDelegate(
        child: SingleChildScrollView(
          controller: viewModel.tabScrollController,
          scrollDirection: Axis.horizontal,
          child: _buildTabs(state),
        ),
      ),
    );
  }

  Widget _buildSections(BuildContext context, DietitianResultState state) {
    // return SliverList(
    //   delegate: SliverChildListDelegate([
    //     Padding(
    //       padding: EdgeInsets.all(rh(context: context, px: 16)),
    //       child: SectionWidget(
    //         sectionKey: viewModel.gutKey,
    //         metabolismType: 'Gut',
    //         state: state,
    //         clientProfileModel: widget.clientProfileModel,
    //         result: widget.result,
    //       ),
    //     ),
    //     Padding(
    //       padding: EdgeInsets.all(rh(context: context, px: 16)),
    //       child: SectionWidget(
    //         sectionKey: viewModel.fatKey,
    //         metabolismType: 'Fat',
    //         state: state,
    //         clientProfileModel: widget.clientProfileModel,
    //         result: widget.result,
    //       ),
    //     ),
    //     Padding(
    //       padding: EdgeInsets.all(rh(context: context, px: 16)),
    //       child: SectionWidget(
    //         sectionKey: viewModel.liverKey,
    //         metabolismType: 'Liver',
    //         state: state,
    //         clientProfileModel: widget.clientProfileModel,
    //         result: widget.result,
    //       ),
    //     ),
    //   ]),
    // );

    return SizedBox();
  }

  Widget _buildDisclaimer() {
    return SliverToBoxAdapter(
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: rh(context: context, px: 26)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disclaimer',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
              SizedBox(height: rh(context: context, px: 10)),
              Text(
                'This is a sample interpretation guide designed for use by certified dietitians and wellness professionals. Respyr is a non-invasive lifestyle monitoring tool. It does not diagnose, prevent, or treat disease. All data is derived from breath-based VOC analysis and should be interpreted within lifestyle and nutritional context. For medical conditions or abnormalities (e.g., diabetic ketoacidosis, chronic liver disease, IBS/SIBO), users should be referred to licensed physicians.',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(DietitianResultState state) {
    final cubit = context.read<DietitianResultCubit>();
    // return Row(
    //   children: [
    //     TabWidget(
    //       key: viewModel.tabGutKey,
    //       text: "Gut Fermentation Metabolism",
    //       isActive: state.selectedTab == "Gut",
    //       onTap: () async {
    //         if (!mounted) return;
    //         cubit.changeTab("Gut");
    //         if (viewModel.gutKey.currentContext != null) {
    //           await Scrollable.ensureVisible(
    //             viewModel.gutKey.currentContext!,
    //             duration: const Duration(milliseconds: 400),
    //             curve: Curves.easeInOut,
    //           );
    //         }
    //         viewModel.tabScrollTo(viewModel.tabGutKey);
    //         _offsetsComputed = false;
    //         WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());
    //       },
    //     ),
    //     _divider(),
    //     TabWidget(
    //       key: viewModel.tabFatKey,
    //       text: "Glucose vs Fat Metabolism",
    //       isActive: state.selectedTab == "Fat",
    //       onTap: () async {
    //         if (!mounted) return;
    //         cubit.changeTab("Fat");
    //         if (viewModel.fatKey.currentContext != null) {
    //           await Scrollable.ensureVisible(
    //             viewModel.fatKey.currentContext!,
    //             duration: const Duration(milliseconds: 400),
    //             curve: Curves.easeInOut,
    //           );
    //         }
    //         viewModel.tabScrollTo(viewModel.tabFatKey);
    //         _offsetsComputed = false;
    //         WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());
    //       },
    //     ),
    //     _divider(),
    //     TabWidget(
    //       key: viewModel.tabLiverKey,
    //       text: "Liver Hepatic Metabolism",
    //       isActive: state.selectedTab == "Liver",
    //       onTap: () async {
    //         if (!mounted) return;
    //         cubit.changeTab("Liver");
    //         if (viewModel.liverKey.currentContext != null) {
    //           await Scrollable.ensureVisible(
    //             viewModel.liverKey.currentContext!,
    //             duration: const Duration(milliseconds: 400),
    //             curve: Curves.easeInOut,
    //           );
    //         }
    //         viewModel.tabScrollTo(viewModel.tabLiverKey);
    //         _offsetsComputed = false;
    //         WidgetsBinding.instance.addPostFrameCallback((_) => _computeSectionOffsetsIfNeeded());
    //       },
    //     ),
    //   ],
    // );

    return SizedBox();
  }

  Widget _divider() => Container(
    height: rh(context: context, px: 43),
    width: rh(context: context, px: 1),
    color: Colors.black,
  );
}

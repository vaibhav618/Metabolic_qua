import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/consultant_info_card.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/diet_plan_card.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/diet_plan_hero.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/next_meal_info_screen.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/no_diet_plan_hero.dart';
import 'package:respyr_dietitian/common/dialogs/abort_sheet_dialog.dart';
import 'package:respyr_dietitian/common/widgets/abort_device_manager.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import '../../../common/widgets/loading_widget.dart';
import '../../../features/dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';
import '../../../features/gifting/dashboard/presentation/widgets/test_result_history.dart';
import '../../data/bloc/diet_plan_bloc.dart';
import '../../data/bloc/diet_plan_event.dart';
import '../../data/bloc/diet_plan_state.dart';
import '../../data/model/client_profile_model.dart';
import '../../data/repositories/diet_plan_repository.dart';
import '../../data/services/diet_plan_service.dart';
import '../../extras/get_today_key.dart';
import '../../extras/meal_type_helper.dart';
import '../../today_result/today_test_data_api_service.dart';
import '../../today_result/today_test_data_bloc.dart';
import '../../today_result/today_test_data_event.dart';
import '../../today_result/today_test_data_repository.dart';
import '../../today_result/today_test_data_state.dart';
import 'package:http/http.dart' as http;

class ClientWithDietitianScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianModel;

  const ClientWithDietitianScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietitianModel,
  });

  @override
  State<ClientWithDietitianScreen> createState() =>
      _ClientWithDietitianScreenState();
}

class _ClientWithDietitianScreenState extends State<ClientWithDietitianScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _fetchTodayDiet(
      String dietitianId,
      String profileId,
      String dietPlanId,
      ) async {
    final body = jsonEncode({'login_id': dietitianId, 'profile_id': profileId, 'diet_plan_id': dietPlanId,});

    final res = await http.post(
      Uri.parse("https://humorstech.com/dietitian/api/app/get_diet_plan.php"),
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response shape');
    }

    final dataList = decoded['data'] as List? ?? [];
    if (dataList.isEmpty) {
      throw Exception('No data in response');
    }

    final first = dataList.first as Map<String, dynamic>;
    final dietJson = (first['diet_json'] ?? {}) as Map<String, dynamic>;

    final todayKey = TodayKey().todayKey();
    final today = (dietJson[todayKey] ?? {}) as Map<String, dynamic>;

    // If API returns only one day
    if (today.isEmpty && dietJson.isNotEmpty) {
      final keys =
      dietJson.keys.map((e) => e.toString().toLowerCase()).toList();
      if (keys.length == 1) {
        final k = keys.first;
        return {
          'dayKey': k,
          'totals': dietJson[k]?['totals'] ?? const {},
          'meals': dietJson[k]?['meals'] ?? const [],
        };
      }
    }
    return {
      'dayKey': todayKey,
      'totals': today['totals'] ?? const {},
      'meals': today['meals'] ?? const [],
    };
  }

  Future<void> checkDeviceAbortStatus(
      BuildContext context,
      DietPlanStrategyModel d,
      ) async {
    try {
      final isDeviceAborted = await AbortDeviceManager.getAbortStatus();

      if (context.mounted) {
        if (isDeviceAborted) {
          CheckAbortSheet.show(
            context: context,
            onTakeTextClick: () {
              context.push(
                AppRoutes.bluetoothDeviceConnectivity,
                extra: {
                  "client": widget.clientProfileModel,
                  "strategy": d,
                },
              );
            },
          );
        } else {
          context.push(
            AppRoutes.bluetoothDeviceConnectivity,
            extra: {
              "client": widget.clientProfileModel,
              "strategy": d,
            },
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      context.push(
        AppRoutes.bluetoothDeviceConnectivity,
        extra: {
          "client": widget.clientProfileModel,
          "strategy": d,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DietPlanBloc>(
          create: (_) => DietPlanBloc(
            DietPlanRepository(DietPlanService()),
          )
            ..add(
              FetchPlans(dietitianId: widget.clientProfileModel.dietitianId, clientId: widget.clientProfileModel.profileId,),
            ),
        ),
        BlocProvider<TodayTestDataBloc>(
          create: (_) => TodayTestDataBloc(
            TodayTestDataRepository(TodayTestDataApiService()),
          )
            ..add(
              LoadTestDataForDay(
                profileId: widget.clientProfileModel.profileId,
                date: DateTime.now(),
                dietitianId: widget.dietitianModel.dietitianId,
              ),
            ),
        ),
      ],
      child: BlocBuilder<DietPlanBloc, DietPlanState>(
        builder: (context, state) {
          final statusBarColor = state.status == LoadStatus.success &&
              state.data != null &&
              state.data!.active.isNotEmpty
              ? ThemeHelper().getStatusBarColor()
              : const Color(0xFFD3E5FF);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: statusBarColor,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: _buildContent(
              context,
              state,
              widget.clientProfileModel,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      DietPlanState state,
      ClientProfileModel clientProfileModel,
      ) {
    // 🔹 Local refresh handler (has access to Bloc context)
    Future<void> onRefresh() async {
      context.read<DietPlanBloc>().add(
        FetchPlans(
          dietitianId: widget.clientProfileModel.dietitianId,
          clientId: widget.clientProfileModel.profileId,
        ),
      );
      context.read<TodayTestDataBloc>().add(
        LoadTestDataForDay(
          profileId: widget.clientProfileModel.profileId,
          date: DateTime.now(),
          dietitianId: widget.dietitianModel.dietitianId,
        ),
      );
    }

    if (state.status == LoadStatus.loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: LoadingWidget(loadingMessage: ''),
      );
    }

    if (state.status == LoadStatus.failure) {
      return Scaffold(
        body: Center(child: Text(state.error ?? 'Unknown error')),
      );
    }

    if (state.status == LoadStatus.success) {









      final categorized = state.data;


      if (categorized == null || categorized.active.isEmpty) {
        // 🔹 No active plan → wrap body in RefreshIndicator
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              backgroundColor: const Color(0xFFD3E5FF),
              elevation: 0,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: onRefresh,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      NoDietPlanHero(
                        clientProfileModel: widget.clientProfileModel,
                        dietitianDetailModel: widget.dietitianModel,
                      ),
                      const SizedBox(height: 30),
                     BlocBuilder<TodayTestDataBloc, TestDataState>(
                        builder: (context, testState) {
                          final hasResult = testState.status == TestDataStatus.success &&
                              testState.result != null;

                          return TestResultHistory(
                            result: hasResult ? testState.result : null,
                            clientProfileModel: clientProfileModel,
                          );
                        },
                      ),

                      const SizedBox(height: 44),
                      DietPlanCard(
                        activeData: [],
                        completedData: [],
                        canceledData: [],
                        dietitianDetailModel: widget.dietitianModel,
                        clientProfileModel: clientProfileModel,
                      ),
                      const SizedBox(height: 40),
                      ConsultantInfoCard(
                        dietitianModel: widget.dietitianModel,
                        clientProfileModel: widget.clientProfileModel,
                      ),


                      // ElevatedButton(onPressed: (){
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => OverallMetabolismScore()),
                      //   );
                      // }, child: Text("gkgjkh")),
                      // const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final activePlan = categorized.active.last;

      // 🔹 Active plan → also wrap scroll area in RefreshIndicator
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: ThemeHelper().getStatusBarColor(),
            elevation: 0,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [




                    FutureBuilder<Map<String, dynamic>>(
                      future: _fetchTodayDiet(
                        widget.dietitianModel.dietitianId,
                        widget.clientProfileModel.profileId,
                        activePlan.id.toString(),
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snap.hasError) {
                          return NoDietPlanHero(
                            clientProfileModel: widget.clientProfileModel,
                            dietitianDetailModel: widget.dietitianModel,
                          );
                        }
                        if (!snap.hasData) {
                          return const SizedBox.shrink();
                        }

                        final todayData = snap.data!;

                        return Column(
                          children: [
                            DietPlanHero(
                              clientProfileModel: widget.clientProfileModel,
                              dietitianDetailModel: widget.dietitianModel,
                              todayData: todayData,
                              activeData: categorized.active,
                              completedData: categorized.completed,
                              canceledData: categorized.cancelled,
                            ),
                            const SizedBox(height: 30),
                            BlocBuilder<TodayTestDataBloc, TestDataState>(
                              builder: (context, testState) {
                                final hasResult = testState.status == TestDataStatus.success &&
                                    testState.result != null;

                                return TestResultHistory(
                                  result: hasResult ? testState.result : null,
                                  clientProfileModel: clientProfileModel,
                                );
                              },
                            ),
                            const SizedBox(height: 50),
                            DietPlanCard(
                              activeData: categorized.active,
                              completedData: categorized.completed,
                              canceledData: categorized.cancelled,
                              dietitianDetailModel: widget.dietitianModel,
                              clientProfileModel: clientProfileModel,
                            ),
                            const SizedBox(height: 50),
                            ConsultantInfoCard(
                              dietitianModel: widget.dietitianModel,
                              clientProfileModel: widget.clientProfileModel,
                            ),
                            const SizedBox(height: 50),
                            NextMealInfoScreen(
                              todayData: todayData,
                            ),
                            const SizedBox(height: 80),
                          ],
                        );
                      },
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
          bottomNavigationBar: SafeArea(
            child: BlocBuilder<TodayTestDataBloc, TestDataState>(
              builder: (context, testState) {
                final hasResult =
                    testState.status == TestDataStatus.success &&
                        testState.result != null;

                // 👉 Show swipe button only when there is NO result
                if (!hasResult ) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SwipeButtonWidget(
                          onSwiped: () {
                            checkDeviceAbortStatus(
                              context,
                              categorized.active.first,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          )


      );
    }

    return const SizedBox.shrink();
  }
}

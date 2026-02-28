import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/screens/no_diet_plan_hero.dart';
import 'package:respyr_dietitian/features/dashboard/dashboard_operations/presentation/widgets/dashboard_log.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../client-dashboard/data/repositories/diet_plan_repository.dart';
import '../../../../client-dashboard/extras/meal_type_helper.dart';
import '../../../../client-dashboard/presentation/screens/consultant_info_card.dart';
import '../../../../client-dashboard/presentation/screens/diet_plan_card.dart';
import '../../../../client-dashboard/presentation/screens/diet_plan_hero.dart';
import '../../../../client-dashboard/presentation/screens/next_meal_info_screen.dart';
import '../../../../common/dialogs/abort_sheet_dialog.dart';
import '../../../../common/widgets/abort_device_manager.dart';
import '../../../../routes/app_routes.dart';
import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';
import '../../../dietitian_dashboard/presentation/widgets/swipe_button_widget.dart';
import '../../../gifting/dashboard/presentation/widgets/test_result_history.dart';
import '../../../profile_info/data/model/dietician_detail_model.dart';
import '../../../walk_through/presentation/screen/walk_through.dart';
import '../../dashboard_operations/bloc/dashboard_operation_bloc.dart';
import '../../new_exhale_progress_screen.dart';

class DashboardContent extends StatelessWidget {

  final ClientProfileModel clientProfile;
  final DietitianDetailModel dietitian;
  final CategorizedPlans plans;
  final GeneratingResultModel? todayResult;
  final Map<String, dynamic>? todayDietData;
  final String? todayDietError;
  final String? plansError;
  const DashboardContent({super.key,
    required this.clientProfile,
    required this.dietitian,
    required this.plans,
    this.todayResult,
    this.todayDietData,
    this.todayDietError,
    this.plansError,
  });

  @override
  Widget build(BuildContext context) {


    if(plans.active.isEmpty){
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: const Color(0xFFD3E5FF),
            elevation: 0,
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  NoDietPlanHero(clientProfileModel: clientProfile, dietitianDetailModel: dietitian),
                  SizedBox(height: 31,),
                  TestResultHistory(result: todayResult, clientProfileModel: clientProfile,),
                  SizedBox(height: 44,),
                  DietPlanCard(activeData: plans.active, completedData: plans.completed, canceledData: plans.cancelled, dietitianDetailModel: dietitian, clientProfileModel: clientProfile,),
                  SizedBox(height: 40,),
                  ConsultantInfoCard(dietitianModel: dietitian, clientProfileModel: clientProfile,),
                  SizedBox(height: 100,),
                ],
              ),
            )
        ),
      );
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
                    "client": clientProfile,
                    "strategy": d,
                  },
                );
              },
            );
          } else {
            context.push(
              AppRoutes.bluetoothDeviceConnectivity,
              extra: {
                "client": clientProfile,
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
            "client":clientProfile,
            "strategy": d,
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: ThemeHelper().getStatusBarColor(),
          elevation: 0,
        ),
      ),
      body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DietPlanHero(clientProfileModel: clientProfile, dietitianDetailModel: dietitian, todayData: todayDietData!, activeData: plans.active, completedData: plans.completed, canceledData: plans.cancelled,),
                    SizedBox(height: 31,),
                    TestResultHistory(result: todayResult, clientProfileModel: clientProfile,),
                    SizedBox(height: 62,),
                    BlocProvider(
                      create: (_) => DashboardOperationBloc(
                        profileId: clientProfile.profileId,
                        dietPlanId: plans.active.first.id,
                        date: DateTime.now().toIso8601String().split('T').first, // 👈 current date
                      ),
                      child: DashboardLog(clientProfileModel: clientProfile),
                    ),

                    SizedBox(height: 44,),
                    DietPlanCard(activeData: plans.active, completedData: plans.completed, canceledData: plans.cancelled, dietitianDetailModel: dietitian, clientProfileModel: clientProfile,),
                    SizedBox(height: 40,),
                    ConsultantInfoCard(dietitianModel: dietitian, clientProfileModel: clientProfile,),
                    SizedBox(height: 22,),
                    NextMealInfoScreen(todayData: todayDietData!,),
                    SizedBox(height: 100,),
                  ],
                ),
              ),),
              Positioned.fill(
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwipeButtonWidget(
                        onSwiped: () {
                          checkDeviceAbortStatus(
                            context,
                            plans.active.first,
                          );
                        },
                      ),
                      ElevatedButton(onPressed: (){

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => NewExhaleProgressScreen(),
                        //   ),
                        // );



                      }, child: Text("New exhale")),
                      ElevatedButton(onPressed: (){
                        checkDeviceAbortStatus(
                          context,
                          plans.active.first,
                        );
                      }, child: Text("Click"))
                    ],
                  ))
            ],
          )
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';
import '../../../gifting/dashboard/presentation/widgets/test_result_history.dart';

class UserWithoutDietPlan extends StatefulWidget {
  final ClientProfileModel clientProfile;
  final GeneratingResultModel? todayResult;

  const UserWithoutDietPlan({super.key, required this.clientProfile, this.todayResult});

  @override
  State<UserWithoutDietPlan> createState() => _UserWithoutDietPlanState();
}

class _UserWithoutDietPlanState extends State<UserWithoutDietPlan> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
            children: [
              TestResultHistory(result: widget.todayResult, clientProfileModel: widget.clientProfile,),
            ],
          )
      ),
    );
  }
}

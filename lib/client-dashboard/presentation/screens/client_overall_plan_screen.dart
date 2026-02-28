import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../data/model/diet_plan_strategy_model.dart';

import '../../extras/date_helper.dart';
import '../widgets/goal_item.dart';
import '../widgets/plan_history_widgets.dart';
import 'active_plan_screen.dart';


class ClientOverallPlanScreen extends StatefulWidget {
  final DietPlanStrategyModel activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianDetailModel;
  const ClientOverallPlanScreen({super.key, required this.activeData, required this.completedData, required this.canceledData, required this.clientProfileModel, required this.dietitianDetailModel});

  @override
  State<ClientOverallPlanScreen> createState() => _ClientOverallPlanScreenState();
}

class _ClientOverallPlanScreenState extends State<ClientOverallPlanScreen> {

  @override
  Widget build(BuildContext context) {

    List<DietPlanStrategyModel> mergeAndSortPlans({
      required List<DietPlanStrategyModel> completedData,
      required List<DietPlanStrategyModel> canceledData,
    }) {
      final mergedList = [...completedData, ...canceledData];
      mergedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return mergedList;
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F7FA),
        surfaceTintColor: Color(0xFFF5F7FA),
        title: Row(
          children: [
            Text("Your Plans",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.30,
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text("Active Plan",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
            ),
            SizedBox(height: 19,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  DietPlanOverview(activeData: widget.activeData,
                        completedData: widget.completedData, canceledData: widget.canceledData,
                        clientProfileModel: widget.clientProfileModel, dietitianDetailModel: widget.dietitianDetailModel,),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.activeData.planTitle,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.72,
                            ),
                          ),
                          Text("${formatToDayShortMonth(widget.activeData.planStartDate)} - ${formatToDayShortMonth(widget.activeData.planEndDate)}",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15,),
                      Text(formatToDateTimeString(widget.activeData.updatedAt),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      SizedBox(height: 12,),
                      Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF0F5FC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/images/icons/ic_goal.svg"),
                                SizedBox(width: 5,),
                                Text("Goal",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.24,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 19,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.activeData.goals.length,
                                itemBuilder: (context, index) {

                                  final goal = widget.activeData.goals[index];
                                  return goalItem(
                                    goalName: goal.name,
                                    currentStat: goal.currentStat.toString(),
                                    targetStat: goal.targetStat.toString(),
                                    unit: goal.unit,
                                    // optional
                                  );


                                },
                              ) ,
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      Text("Updated 05 Jul, 12:30pm",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text("Plans History",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                  height: 1.2
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 19,),
                  Visibility(
                    visible: widget.completedData.isNotEmpty,
                    replacement: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 38, bottom: 51),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF5F7FA),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFD9D9D9),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Column(
                        children: [
                          Image.asset("assets/images/icons/ic_no_history.png", width: 100, height: 100,),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 218),
                            child: Text("No Plans History\nto show",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFA1A1A1),
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: mergeAndSortPlans(completedData: widget.completedData, canceledData: widget.canceledData).length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final plan = mergeAndSortPlans(completedData: widget.completedData, canceledData: widget.canceledData)[index];
                        return PlanHistoryWidgets().planHistoryItem(dietPlanStrategyModel: plan);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }
}

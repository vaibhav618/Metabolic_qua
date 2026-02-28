import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../../features/diet_plan/presentation/pages/diet_plan_screen.dart';
import '../../../features/log_food/presentation/pages/logged_food_screen.dart';
import '../../data/model/client_profile_model.dart';
import '../../data/model/diet_plan_strategy_model.dart';
import '../../extras/meal_time_helper.dart';
import '../../extras/meal_type_helper.dart';
import '../../extras/pick_current_meal.dart';
import '../widgets/dashboard_appbar.dart';
import '../widgets/diet_food_item_card.dart';

class DietPlanHero extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianDetailModel;

  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;

  /// plain map passed from FutureBuilder (NOT an AsyncSnapshot)
  final Map<String, dynamic> todayData;

  const DietPlanHero({
    super.key,
    required this.clientProfileModel,
    required this.dietitianDetailModel,
    required this.todayData, required this.activeData, required this.completedData, required this.canceledData,
  });

  @override
  Widget build(BuildContext context) {
    final dayKey = (todayData['dayKey'] ?? '').toString();
    final totals = (todayData['totals'] ?? {}) as Map<String, dynamic>;
    final meals = (todayData['meals'] ?? const []) as List;


    Map<String, dynamic>? picked = CurrentMeal().pickCurrentMeal(meals);
    final time = (picked?['time'] ?? '').toString();
    final mTotals = (picked?['totals'] ?? {}) as Map<String, dynamic>;
    final items = (picked!['items'] ?? const []) as List;

    return Container(
      decoration: BoxDecoration(
        gradient: ThemeHelper().getHeroGradient(),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: DashboardAppbar(
              clientProfileModel: clientProfileModel,
              isDefaultColor: false,
              dietitianDetailModel: dietitianDetailModel, activeData: activeData, completedData: [], canceledData: [],
            ),
          ),
          SizedBox(height: 80,),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                MealTimeHelper().getMealName(time),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: ThemeHelper().getThemeDarkColor(),
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.68,
                ),
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "As per your",
                  style: GoogleFonts.poppins(
                    color: ThemeHelper().getThemeDarkColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.30,
                  ),
                ),
                TextSpan(
                  text: "diet plan",
                  style: GoogleFonts.poppins(
                    color: ThemeHelper().getThemeDarkColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 33),
          Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25000),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              MealTimeHelper().getMealTime(time),
              style: GoogleFonts.poppins(
                color: ThemeHelper().getThemeDarkColor(),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.30,
              ),
            ),
          ),
          const SizedBox(height: 33),
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return DietPlanWidgets().dietFoodItemCard(
                index: index + 1,
                foodName: items[index]['name'] ?? '',
                foodPortion:  items[index]['portion'],
                foodCalories:"${items[index]['calories_kcal']} Kcal" , );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 150),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.50,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: ThemeHelper().getThemeDarkColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Your Meal Macros goal",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.20,
                                    ),
                                  ),
                                  Text(
                                    "${items.length} items",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.26,
                                      letterSpacing: -0.30,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "${mTotals["calories_kcal"]} Kcal",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.26,
                                  letterSpacing: -0.40,
                                ),
                              ),
                            ],
                          ),
                          Container(height: 0.5, width: double.infinity, color: Colors.white),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {



                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DietPlanScreen(
                                      dieticianId: dietitianDetailModel.dietitianId,
                                      profileId: clientProfileModel.profileId, dietPlanStrategyModel: activeData.first,
                                    
                                    )),
                                  );


                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    SvgPicture.asset("assets/images/icons/ic_diet_plan.svg", width: 20,),
                                    Text(
                                      "View full plan",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.10,
                                        letterSpacing: -0.24,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_right_outlined, color: Colors.white,size: 15,)
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => FoodLogByDayScreen(
                                        clientProfileModel: clientProfileModel,
                                        dietitianModel: dietitianDetailModel, dietPlanStrategyModel: activeData.first,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    SvgPicture.asset("assets/images/icons/ic_food.svg", width: 20,),
                                    Text(
                                      "View logged meals",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.10,
                                        letterSpacing: -0.24,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_right_outlined, color: Colors.white,size: 15,)
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 33),
        ],
      ),
    );

  }

}

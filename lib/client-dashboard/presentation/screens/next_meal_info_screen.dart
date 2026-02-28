import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../extras/meal_time_helper.dart';
import '../../extras/pick_current_meal.dart';

class NextMealInfoScreen extends StatelessWidget {
  final Map<String, dynamic> todayData;
  const NextMealInfoScreen({super.key, required this.todayData});

  @override
  Widget build(BuildContext context) {

    final dayKey = (todayData['dayKey'] ?? '').toString();
    final totals = (todayData['totals'] ?? {}) as Map<String, dynamic>;
    final meals = (todayData['meals'] ?? const []) as List;


    Map<String, dynamic>? picked = CurrentMeal().pickUpcomingMeal(meals);
    final time = (picked?['time'] ?? '').toString();
    final mTotals = (picked?['totals'] ?? {}) as Map<String, dynamic>;
    final items = (picked!['items'] ?? const []) as List;


    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0.00),
          end: Alignment(0.50, 1.00),
          colors: [const Color(0xFFCAE1FF), const Color(0xFFF0F5FC), Colors.white],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 33),
            child: Text("Up Next",
              style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.30,
                  height: 1.2
              ),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 33),
            child: Text(MealTimeHelper().getMealName(time),
              style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  height: 1.2
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 33),
            child: Row(
              spacing: 10,
              children: [
                Text(MealTimeHelper().getMealTime(time),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
                Container(height: 12, width: 1,color: Color(0xFF252525),),
                Text("${items.length} Items",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 17.5,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // border-radius: 10px
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // 180deg (from top to bottom)
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFeaf3fe), // #FFF 0%
                     Color(0xFFeaf3fe).withAlpha(5)// rgba(255, 255, 255, 0.00) 100%
                  ],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  ListView.separated(
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 20,),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    itemBuilder: (context, index) {
                      return NextFoodItem(index: index+1, foodName: items[index]['name'] ?? '', foodCalories: items[index]['calories_kcal'] ?? 0, foodPortion:  items[index]['portion'],);
                    },
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),

          ),

          SizedBox(height: 99,),
          Center(
            child: Column(
              children: [
                Text("Made In India",
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFA1A1A1),
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                      height: 1.2
                  ),
                ),
                Text("All rights reserved HumorsTech Pvt. Ltd.",
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFA1A1A1),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.20,
                      height: 1.2
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 150,),

        ],
      ),
    );
  }
}


class NextFoodItem extends StatelessWidget {
  final int index;
  final String foodName;
  final int foodCalories;
  final String foodPortion;
  const NextFoodItem({super.key, required this.index,  required this.foodName, required this.foodCalories, required this.foodPortion});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,

      children: [
        Text("$index.",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.26,
            letterSpacing: -0.30,
          ),
        ),
        SizedBox(width: 14,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(foodName,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.26,
                  letterSpacing: -0.30,
                ),
              ),
              Text(foodPortion,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.20,
                ),
              )
            ],
          ),
        ),
        Text("$foodCalories kcal",
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        )
      ],
    );
  }
}

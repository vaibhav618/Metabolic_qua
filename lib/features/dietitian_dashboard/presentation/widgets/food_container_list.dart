import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:respyr_dietitian/core/utils/text_style.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';

class FoodContainerList extends StatelessWidget {
  final List<DietitianDashboardFoodItem> foodItems;
  final Color iconColor;
  const FoodContainerList({
    super.key,
    required this.foodItems,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foodItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final item = foodItems[index];

        return foodContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/dietitian_dashboard/dish_svg.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                Text(
                  item.foodNumber.toString(),
                  style: poppinsTextStyle(
                    color: iconColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.foodName,
                      style: poppinsTextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          item.foodDetails,
                          style: poppinsTextStyle(
                            color: const Color(0xFF252525),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.info_outline,
                            size: 12,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  "${item.kCal} kcal",
                  style: poppinsTextStyle(
                    color: const Color(0xFF535359),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget foodContainer({required Widget child}) {
    return Opacity(
      opacity: 0.50,
      child: Container(
        width: 335,
        height: 85,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [
              Colors.white,
              Colors.white,
              Colors.white.withValues(alpha: 0),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

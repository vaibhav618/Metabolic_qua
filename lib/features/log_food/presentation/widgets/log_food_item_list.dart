import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/food_item.dart';

class LogFoodItemList extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const LogFoodItemList({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: item.isSelected,
          onChanged: (_) => onTap(),
          checkColor: Color(0xFF308BF9),
          activeColor: Colors.white,
          side: WidgetStateBorderSide.resolveWith(
            (states) => const BorderSide(color: Color(0xFFA1A1A1), width: 2),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.26,
                  letterSpacing: -0.24,
                ),
              ),
              if (item.subTitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    item.subTitle!,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/core/color_manager.dart';
import 'hero_calender_widget.dart';

class QuaHero extends StatefulWidget {

  const QuaHero({super.key});

  @override
  State<QuaHero> createState() => _QuaHeroState();
}

class _QuaHeroState extends State<QuaHero> {
  DateTime _selectedDate = DateTime(2025, 2, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.50, 0.00),
          end: const Alignment(0.50, 1.00),
          colors: [ColorManager.getZoneColor(zone: "Poor"), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi Sparsh",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.24,
                      ),
                    ),
                    Text(
                      "Good morning",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.80,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    IconButton(
                        onPressed: (){},
                        icon: SvgPicture.asset("assets/images/icons/ic_calender.svg"),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        )
                    ),
                    IconButton(
                        onPressed: (){}, icon: SvgPicture.asset("assets/images/icons/ic_profile.svg"),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        )
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 35,),

          SizedBox(height: 60,),

        ],
      ),
    );
  }
}

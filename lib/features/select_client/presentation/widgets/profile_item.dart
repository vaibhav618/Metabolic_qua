import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: rh(context: context, px: 15),
      children: [
        SvgPicture.asset(
          "assets/images/icons/default1.svg",
          width: rh(context: context, px: 40),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: rh(context: context, px: 10),
            children: [
              Row(
                spacing: rh(context: context, px: 10),
                children: [
                  Text(
                    "Sparsh",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 12),
                      fontWeight: FontWeight.w600,
                      letterSpacing: rh(context: context, px: -0.24),
                      height: rh(context: context, px: 1),
                    ),
                  ),
                  Text(
                    "sagar@respyr.in",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFA1A1A1),
                      fontSize: rh(context: context, px: 12),
                      fontWeight: FontWeight.w400,
                      letterSpacing: rh(context: context, px: -0.24),
                      height: rh(context: context, px: 1),
                    ),
                  ),
                ],
              ),
              Text(
                "27 years, Male",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 10),
                  fontWeight: FontWeight.w400,
                  letterSpacing: rh(context: context, px: -0.20),
                  height: rh(context: context, px: 1),
                ),
              ),
              Text(
                "Weight Loss",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 10),
                  fontWeight: FontWeight.w400,
                  letterSpacing: rh(context: context, px: -0.20),
                  height: rh(context: context, px: 1),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
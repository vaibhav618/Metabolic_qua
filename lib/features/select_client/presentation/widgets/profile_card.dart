import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class ProfileCard extends StatelessWidget {
  final bool isProfileAvailable;
  const ProfileCard({super.key, required this.isProfileAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: isProfileAvailable
            ? const Color(0xFFF0F5FC)
            : const Color(0xFFD9D9D9),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(rh(context: context, px: 15)),
        ),
      ),
      child: isProfileAvailable
          ? Column(
        children: [
          Expanded(
            child: SvgPicture.asset(
              "assets/images/icons/def1.svg",
            ),
          ),
          Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                      rh(context: context, px: 15)),
                  bottomRight: Radius.circular(
                      rh(context: context, px: 15)),
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 14),
              vertical: rh(context: context, px: 12),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Sparsh",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize:
                    rh(context: context, px: 10),
                    fontWeight: FontWeight.w400,
                    letterSpacing:
                    rh(context: context, px: -0.20),
                  ),
                ),
                Text(
                  "27 years, Male",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize:
                    rh(context: context, px: 10),
                    fontWeight: FontWeight.w400,
                    letterSpacing:
                    rh(context: context, px: -0.20),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : const SizedBox.shrink(),
    );
  }
}
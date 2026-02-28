import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';

class HoldBreachFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const HoldBreachFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();

    String title;
    if (lower.contains("exhale")) {
      title = "You breathed out\nInstead of holding";
    } else if (lower.contains("inhale")) {
      title = "You breathed in\nInstead of holding";
    } else {
      title = "Hold failed.\nPlease try again";
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontWeight: FontWeight.w600,
              fontSize: rh(context: context, px: 25),
              height: rh(context: context, px: 1.29),
              letterSpacing: rh(context: context, px: -1),
            ),
          ),
          SizedBox(height: rh(context: context, px: 37)),
          Expanded(child:  Image.asset("assets/images/device_connection/hold_failed.png"),),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(
                  vertical: rh(context: context, px: 16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Start Again",
                style: GoogleFonts.poppins(
                  fontSize: rh(context: context, px: 15),
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: rh(context: context, px: 1.10),
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 20)),
        ],
      ),
    );
  }
}

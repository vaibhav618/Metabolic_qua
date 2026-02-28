import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';

class InhaleFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const InhaleFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  bool _contains(String t, String match) {
    return t.toLowerCase().contains(match.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final isExhale = _contains(text, "exhale");
    final isDropped = _contains(text, "dropped") || _contains(text, "stopped");
    // Add timeout catch for "Out of range for 2 seconds" or disconnected
    final isTimeout = _contains(text, "out of range") ||
        _contains(text, "timeout") ||
        _contains(text, "no response");

    if (isDropped) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          children: [
            const Spacer(),
            Center(
                child: Image.asset(
              "assets/images/device_connection/img_inhale_exhale_dropped.png",
            )),
            SizedBox(
              height: rh(context: context, px: 48),
            ),
            Center(
              child: Text(
                "Keep the ball in the\nrange for longer",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                  height: 1.29,
                  letterSpacing: -1,
                ),
              ),
            ),
            const Spacer(),
            _buildButton(context),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    if (isExhale) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You breathed air out\nInstead of In",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: 1.29,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_inhale_screen_exhale.png",
              ),
            ),
            _buildButton(context),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    if (isTimeout) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You took too long to\ninhale.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: 1.29,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_exhale_timeout.png",
              ),
            ), // Use your timeout image here
            _buildButton(context),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    // Generic fallback so you NEVER get a blank screen
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Something went wrong.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 25),
              fontWeight: FontWeight.w600,
              height: 1.29,
              letterSpacing: -1,
            ),
          ),
          SizedBox(
            height: rh(context: context, px: 25),
          ),
          Text(
            text.isEmpty ? "Don’t worry—let’s give it another try." : text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 15),
              fontWeight: FontWeight.w400,
              height: 1.30,
              letterSpacing: -0.30,
            ),
          ),
          SizedBox(height: rh(context: context, px: 37)),
          const Expanded(child: SizedBox()),
          _buildButton(context),
          SizedBox(
            height: rh(context: context, px: 20),
          ),
        ],
      ),
    );
  }

  // Helper widget to keep code clean
  Widget _buildButton(BuildContext context) {
    return SizedBox(
      height: rh(context: context, px: 61),
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onStartAgain,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF308BF9),
              padding:
                  EdgeInsets.symmetric(vertical: rh(context: context, px: 16)),
              elevation: 0),
          child: Text(
            "Start Again",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0.30),
          )),
    );
  }
}

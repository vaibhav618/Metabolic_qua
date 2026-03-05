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

  bool _isExhaleCase(String t) {
    final s = t.toLowerCase();
    return s.contains("exhale");
  }

  bool _isDroppedCase(String t) {
    return t.trim() == "Inhale dropped to 0";
  }

  // 🚨 ADDED: Check for disconnect
  bool _isDisconnectedCase(String t) {
    return t.toLowerCase().contains("disconnect");
  }

  @override
  Widget build(BuildContext context) {
    final isExhale = _isExhaleCase(text);
    final isDropped = _isDroppedCase(text);
    final isDisconnected = _isDisconnectedCase(text);

    // 🚨 ADDED: Dedicated Disconnected Screen
    if (isDisconnected) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Connection Lost",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(
              height: rh(context: context, px: 25),
            ),
            Text(
              text.isEmpty ? "Device disconnected. Please reconnect." : text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                height: rh(context: context, px: 1.30),
                letterSpacing: rh(context: context, px: -0.30),
              ),
            ),
            const Expanded(child: SizedBox()),
            _buildButton(context, isDisconnected: true), // Will show "Go Back"
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

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
                  height: rh(context: context, px: 1.29),
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
            ),
            const Spacer(),
            _buildButton(context, isDisconnected: false),
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
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_inhale_screen_exhale.png",
              ),
            ),
            _buildButton(context, isDisconnected: false),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    // 🚨 UNCOMMENTED: Fallback screen so any other errors (like timeout) don't result in a blank screen
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
              height: rh(context: context, px: 1.29),
              letterSpacing: rh(context: context, px: -1),
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
              height: rh(context: context, px: 1.30),
              letterSpacing: rh(context: context, px: -0.30),
            ),
          ),
          SizedBox(height: rh(context: context, px: 37)),
          Expanded(
            child: Container(),
          ),
          _buildButton(context, isDisconnected: false),
          SizedBox(
            height: rh(context: context, px: 20),
          ),
        ],
      ),
    );
  }

  // 🚨 ADDED: Helper widget to clean up repeated button code and handle text change
  Widget _buildButton(BuildContext context, {required bool isDisconnected}) {
    return SizedBox(
      height: rh(context: context, px: 61),
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () {
            onStartAgain();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF308BF9),
              padding:
                  EdgeInsets.symmetric(vertical: rh(context: context, px: 16)),
              elevation: 0),
          child: Text(
            isDisconnected
                ? "Go Back"
                : "Start Again", // Changes text automatically
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w700,
                height: rh(context: context, px: 1.0),
                letterSpacing: rh(context: context, px: 0.30)),
          )),
    );
  }
}

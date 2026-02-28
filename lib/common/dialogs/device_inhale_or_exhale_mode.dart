import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import '../../core/size/get_height.dart';

class DeviceInhaleOrExhaleMode extends StatelessWidget {
  final VoidCallback onOk;

  const DeviceInhaleOrExhaleMode({
    super.key,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(rh(context: context, px: 30)),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          rh(context: context, px: 20),
          rh(context: context, px: 42),
          rh(context: context, px: 20),
          rh(context: context, px: 26),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            rh(context: context, px: 16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Device Restart Required",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 24),
                fontWeight: FontWeight.w600,
                letterSpacing: rh(context: context, px: -0.48),
              ),
            ),

            SizedBox(height: rh(context: context, px: 22)),

            Text(
              "It looks like the Respyr device is still in Inhale/Exhale mode from the previous session. Please restart the device using the power button, then reconnect and start a new reading.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                letterSpacing: rh(context: context, px: -0.30),
              ),
            ),

            SizedBox(height: rh(context: context, px: 32)),

            SizedBox(
              height: rh(context: context, px: 60),
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308BF9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      rh(context: context, px: 50),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 50),
                  ),
                ),
                child: Text(
                  "Got it",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: rh(context: context, px: 15),
                    fontWeight: FontWeight.w700,
                    height: 1.10,
                    letterSpacing: rh(context: context, px: 0.30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

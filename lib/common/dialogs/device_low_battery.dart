import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceLowBattery extends StatelessWidget {
  final String message;
  final VoidCallback onOk;

  const DeviceLowBattery({
    super.key,
    required this.message,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 42, 20, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Low Battery",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.48,
              ),
            ),
            Image.asset("assets/images/device_connection/new_device_low_battery.png"),

            const SizedBox(height: 59),
            Text(
              "Please charge the device\n and take your test",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.30,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF308BF9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 50
                  )
                ),
                child:  Text("Got it",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.10,
                    letterSpacing: 0.30,
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

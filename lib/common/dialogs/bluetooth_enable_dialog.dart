import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../../core/size/get_height.dart'; // Import the rh() function

Future<void> showBluetoothEnableDialog({
  required BuildContext context,
  required VoidCallback onButtonPressed,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rh(context: context, px: 20)),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rh(context: context, px: 20)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: rh(context: context, px: 13),
          vertical: rh(context: context, px: 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/device_connection/bluetooth_disconnected.svg",
              width: rh(context: context, px: 280),
              height: rh(context: context, px: 280),
            ),
            Text(
              'Turn on bluetooth',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 10)),
            Text(
              'To connect your device to the app, make\nsure your bluetooth is on',
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 12),
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: rh(context: context, px: -0.24),
              ),
            ),
            SizedBox(height: rh(context: context, px: 40)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Platform.isIOS
                    ? null // Disable button on iOS
                    : () {
                  onButtonPressed();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 17)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: const Color(0xFF308BF9),
                ),
                child: Text(
                  Platform.isIOS
                      ? 'Turn on from settings' // Text for iOS
                      : 'Turn on bluetooth', // Regular text for Android
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
    ),
  );
}

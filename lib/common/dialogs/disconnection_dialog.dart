import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/size/get_height.dart';

Future<void> showDeviceDisconnectedBox({
  required BuildContext context,
  required VoidCallback onButtonPressed,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rh(context: context, px: 15)),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rh(context: context, px: 15)),
        ),
        padding: EdgeInsets.only(
          top: rh(context: context, px: 30),
          left: rh(context: context, px: 20),
          right: rh(context: context, px: 20),
          bottom: rh(context: context, px: 30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Device Disconnected",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 20),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.10),
              ),
            ),
            SizedBox(height: rh(context: context, px: 20)),
            Text(
              "Please try connecting back respyr device to your phone and try again",
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: rh(context: context, px: 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: const Color(0xFF308BF9),
                  padding: EdgeInsets.symmetric(
                    vertical: rh(context: context, px: 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      rh(context: context, px: 8),
                    ),
                  ),
                ),
                child: Text(
                  "Try again",
                  style: GoogleFonts.mulish(
                    color: Colors.white,
                    fontSize: rh(context: context, px: 12),
                    fontWeight: FontWeight.w600,
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

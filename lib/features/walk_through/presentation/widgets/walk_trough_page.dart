import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';

class WalkTroughPage extends StatelessWidget {
  final String image;
  final String title;
  final String desc;

  const WalkTroughPage({
    super.key,
    required this.image,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(image, width: double.infinity),
        SizedBox(height: rh(context: context, px: 38)),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 20),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 20),
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
            ),
            SizedBox(height: rh(context: context, px: 12)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 50),
              ),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w300,
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

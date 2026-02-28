import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

void showImproperExhale({
  required BuildContext context,
  required VoidCallback tryAgainButtonClicked,
  required VoidCallback needHelpButtonCancel,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjust height based on content
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/device_connection/improper.svg",
                ),
                const SizedBox(height: 29.61),
                Text(
                  "Improper Exhale",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your results ',
                        style: GoogleFonts.mulish(
                          color: const Color(0xFF535359),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.40,
                        ),
                      ),
                      TextSpan(
                        text: 'lacks accuracy',
                        style: GoogleFonts.mulish(
                          color: const Color(0xFF535359),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' due to low exhale. Please try again and make sure to exhale with full capacity.',
                        style: GoogleFonts.mulish(
                          color: const Color(0xFF535359),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.40,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 85), // Add spacing before buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tryAgainButtonClicked,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: const Color(0xFF308BF9),
                    ),
                    child: Text(
                      "Try Again (recommended)",
                      style: GoogleFonts.mulish(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Visibility(
                  visible: false,
                  child: Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFD9D9D9)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "If not able to exhale properly",
                            style: GoogleFonts.mulish(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              needHelpButtonCancel();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              "Help",
                              style: GoogleFonts.mulish(
                                color: const Color(0xFF308BF9),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Input decoration builder
InputDecoration buildInputDecoration({
  required String hintText,
  String? prefixIcon,
  bool obscure = true,
  VoidCallback? onSuffixTap,
  String? errorText,
  Widget? suffixIcon,
  bool readOnly = false,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
  );

  final noBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w300,
      color: const Color(0xFF737373),
    ),

    filled: true,
    fillColor: const Color(0xFFF8F8F8),
    prefixIcon:
        prefixIcon != null
            ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                prefixIcon,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            )
            : null,
    suffixIcon: suffixIcon,

    enabledBorder: readOnly ? noBorder : border,
    focusedBorder: readOnly ? noBorder : border,
    border: readOnly ? noBorder : border,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    errorText: errorText,
    errorStyle: GoogleFonts.mulish(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFDF2F32),
    ),
  );
}

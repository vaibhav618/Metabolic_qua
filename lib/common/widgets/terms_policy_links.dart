import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';
import '../../../../common/screens/app_webview_screen.dart';
import '../../features/webview/utils/urls.dart'; // adjust path if needed

class TermsPolicyWidgets {

  Widget termsPolicyFooter(BuildContext context) {
    final greyTextStyle = GoogleFonts.poppins(
      color: const Color(0xFFA1A1A1),
      fontSize: rh(context: context, px: 12),
      fontWeight: FontWeight.w500,
      letterSpacing: -0.72,
    );

    final linkTextStyle = greyTextStyle.copyWith(
      color: const Color(0xFF308BF9),
      decoration: TextDecoration.underline,
      decorationColor: const Color(0xFF308BF9),
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: rh(context: context, px: 3),
        runSpacing: rh(context: context, px: 2),
        children: [
          Text(
            "By continuing, you agree to our ",
            style: greyTextStyle,
          ),

          /// ✅ Privacy Policy
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  AppWebViewScreen(
                    url: WebViewUrls.privacyPolicy,
                    title: "Privacy Policy",
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Privacy policy",
              style: linkTextStyle,
            ),
          ),

          Text(
            " and ",
            style: greyTextStyle,
          ),

          /// ✅ Terms & Conditions
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  AppWebViewScreen(
                    url: WebViewUrls.termsAndConditions,
                    title: "Terms & Conditions",
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Terms and Conditions",
              style: linkTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

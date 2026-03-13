import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/qua_profile/presentation/screens/qua_profile.dart';
import 'package:respyr_dietitian/features/science/presentation/reference_screen.dart';
import 'package:go_router/go_router.dart';
import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../client-dashboard/extras/logout.dart';
import '../../../../../common/screens/app_webview_screen.dart';
import '../../../../../core/size/get_height.dart';
import '../../../../support/presentation/screens/support.dart'
    show SupportScreen;
import '../../../../webview/utils/urls.dart';

class DashboardMenuScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const DashboardMenuScreen({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    final s = rh(context: context, px: 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "General",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15 * s,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * s),
                child: SizedBox(height: 10 * s),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17 * s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Account",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 34 * s,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -2.04,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuaProfile(
                                clientProfileModel: clientProfileModel),
                          ),
                        );
                      },
                      icon: const Icon(Icons.keyboard_arrow_right),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuaProfile(clientProfileModel: clientProfileModel),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15 * s),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * s,
                      vertical: 30 * s,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoBlock(
                          label: "Name",
                          value: clientProfileModel.profileName,
                          s: s,
                        ),
                        SizedBox(height: 25 * s),
                        _InfoBlock(
                          label: "Email",
                          value: clientProfileModel.email,
                          s: s,
                        ),
                        SizedBox(height: 25 * s),
                        _InfoBlock(
                          label: "Reference ID",
                          value: clientProfileModel.dietitianId,
                          s: s,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17 * s),
                child: Text(
                  "Legal",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34 * s,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * s),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 10 * s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppWebViewScreen(
                                  url: WebViewUrls.privacyPolicy,
                                  title: "Privacy Policy",
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * s,
                              horizontal: 10 * s,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Privacy Policy",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppWebViewScreen(
                                  url: WebViewUrls.termsAndConditions,
                                  title: "Terms and Conditions",
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * s,
                              horizontal: 10 * s,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Terms and Conditions",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17 * s),
                child: Text(
                  "Resource",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34 * s,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * s),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 10 * s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppWebViewScreen(
                                  url: WebViewUrls.research,
                                  title: "Research",
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * s,
                              horizontal: 10 * s,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Science",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReferenceScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * s,
                              horizontal: 10 * s,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "References",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17 * s),
                child: Text(
                  "Support",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34 * s,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * s),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 10 * s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SupportScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * s,
                              horizontal: 10 * s,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Support",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ==========================================
              // NEW SECTION: PRACTICE TEST
              // ==========================================
              SizedBox(height: 30 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17 * s),
                child: Text(
                  "Practice Test",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34 * s,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * s),
                child: Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15 * s),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * s,
                    vertical: 10 * s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            context.push(
                              '/practice-flow_shell', // 👈 Using the exact string from your logs
                              extra: clientProfileModel,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * s,
                              horizontal: 10 * s,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Practice on Respyr Device",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15 * s,
                                    fontWeight: FontWeight.w400,
                                    height: 1.10,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ==========================================
              SizedBox(height: 50 * s),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 17 * s,
                  vertical: 17 * s,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52 * s,
                  child: OutlinedButton(
                    onPressed: () {
                      Logout().show(
                        context,
                        isLoggingOut: (bool isLoggingOut) {},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDA5747),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: const Color(0xFFE5E7EB),
                        width: 1 * s,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * s),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * s,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/images/icons/ic_logout.svg",
                          width: 18 * s,
                          height: 18 * s,
                        ),
                        SizedBox(width: 10 * s),
                        Text(
                          "Logout",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFDA5747),
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final double s;

  const _InfoBlock({
    required this.label,
    required this.value,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15 * s,
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: -0.30,
          ),
        ),
        SizedBox(height: 2 * s),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12 * s,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }
}

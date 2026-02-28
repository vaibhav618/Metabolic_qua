import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';

import 'package:respyr_dietitian/features/menu/presentation/pages/profile.dart';

import '../../../../client-dashboard/data/bloc/client_bloc.dart';
import '../../../../client-dashboard/data/bloc/client_state.dart';
import '../../../../client-dashboard/extras/logout.dart';
import '../../../../client-dashboard/presentation/screens/client_overall_plan_screen.dart';
import '../../../../common/dialogs/floating_message.dart';
import '../../../../routes/app_routes.dart';

import '../../../dashboard/bloc/dashboard_bloc.dart';
import '../../../dashboard/bloc/dashboard_event.dart';
import '../../../dashboard/bloc/dashboard_state.dart';
import '../../../profile_info/data/model/dietician_detail_model.dart';
import '../../../webview/presentation/screens/webview_screen.dart';
import '../../../webview/utils/urls.dart';

class Settings extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel? dietitianDetailModel;
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;

  const Settings({
    super.key,
    required this.clientProfileModel,
    this.dietitianDetailModel,
    required this.activeData,
    required this.completedData,
    required this.canceledData,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool value;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    value = widget.clientProfileModel.isNotificationEnabled == 1;

    // 🔥 Fetch dietitian link status once when Settings opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardBloc = context.read<DashboardBloc>();
      dashboardBloc.add(
        CheckDietitianLinkStatus(
          widget.clientProfileModel.profileId.toString(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FA),
          surfaceTintColor: const Color(0xFFF5F7FA),
          title: Text(
            "Settings",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.30,
            ),
          ),
        ),
        body: BlocListener<ClientBloc, ClientState>(
          listener: (context, state) {
            if (state is ClientNotificationUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Notifications ${state.isEnabled ? "enabled" : "disabled"}",
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is ClientNotificationUpdateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to update notifications"),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() => value = !value);
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionTitle("Account"),
                  const SizedBox(height: 10),
                  _buildAccountSection(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("General"),
                  const SizedBox(height: 10),
                  _buildGeneralSection(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Help Center"),
                  const SizedBox(height: 10),
                  _buildHelpCenterSection(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("About"),
                  const SizedBox(height: 10),
                  _buildAboutSection(),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 54),
                  _buildAppVersion(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------- SECTIONS ---------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 34,
          fontWeight: FontWeight.w400,
          letterSpacing: -2.04,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildProfileRow(),
              const SizedBox(height: 26),
              _buildInfoRow("Email", widget.clientProfileModel.email),
              const SizedBox(height: 26),
              _buildConsultantInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.2,
                letterSpacing: -0.30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.clientProfileModel.profileName,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
                height: 1.2,
              ),
            )
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: widget.clientProfileModel.profileImage.isNotEmpty
                ? Image.network(
              widget.clientProfileModel.profileImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/icons/default2.png",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
                : Image.asset(
              "assets/images/icons/default2.png",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: -0.30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            height: 1.2,
          ),
        )
      ],
    );
  }

  // ----------------- CONSULTANT INFO ------------------

  Widget _buildConsultantInfo(BuildContext context) {
    // 1️⃣ Get dashboard bloc state
    final dashState = context.watch<DashboardBloc>().state;

    String? linkStatus;
    String? dietitianName;
    if (dashState is DashboardReady) {
      linkStatus = dashState.dietitianLinkStatus;
      dietitianName = dashState.dietitianLinkData?["dietitian_name"];
    }

    // 2️⃣ Is dietitian actually linked to client?
    final hasDietitian = widget.dietitianDetailModel != null &&
        widget.dietitianDetailModel!.name != "NA";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Consultant Linked",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: -0.30,
          ),
        ),
        const SizedBox(height: 10),


        if (!hasDietitian) ...[

          if (linkStatus == "PENDING" || linkStatus == "REJECTED") ...[

            RichText(
                text: TextSpan(
                  text:dietitianName
                )
            ),

          ] else ...[
            Text(
              "Not Linked",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
            ),
          ]
        ]


        else ...[
          Row(
            children: [
              Text(
                widget.dietitianDetailModel!.name,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 12,
                width: 1.5,
                color: const Color(0xFF535359),
              ),
              const SizedBox(width: 10),
              Text(
                "Active",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF3EAF58),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ----------------- GENERAL SECTION ------------------

  Widget _buildGeneralSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildProfileSettings(),
              const SizedBox(height: 26),
              _buildYourPlans(),
              const SizedBox(height: 26),
              _buildNotifications(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSettings() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Profile(
              clientProfileModel: widget.clientProfileModel,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile Settings",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.2,
              letterSpacing: -0.30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourPlans() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.activeData.isNotEmpty) {
          if (widget.dietitianDetailModel == null) {
            FloatingMessage.show(context, message: "Dietitian not linked");
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientOverallPlanScreen(
                activeData: widget.activeData.first,
                completedData: [],
                canceledData: [],
                clientProfileModel: widget.clientProfileModel,
                dietitianDetailModel: widget.dietitianDetailModel!,
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Plans",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.2,
              letterSpacing: -0.30,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Your Plans",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 12,
                width: 1.5,
                color: const Color(0xFF535359),
              ),
              const SizedBox(width: 10),
              Text(
                widget.activeData.isNotEmpty ? "Active" : "Not active",
                style: GoogleFonts.poppins(
                  color: widget.activeData.isNotEmpty
                      ? const Color(0xFF3EAF58)
                      : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.push(
          AppRoutes.notificationScreen,
          extra: widget.clientProfileModel,
        );
      },
      child: Visibility(
        visible: true, // currently hidden as per your earlier code
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notifications",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    letterSpacing: -0.30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Daily diet and test reminders",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                    height: 1.2,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- HELP CENTER ------------------

  Widget _buildHelpCenterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon'),
                    ),
                  );
                },
                child: _buildMenuItem("FAQ"),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon'),
                    ),
                  );
                },
                child: _buildMenuItem("Report An Issue"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- ABOUT SECTION ------------------

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WebViewScreen(url: WebViewUrls.privacyPolicy),
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: _buildMenuItem("Privacy Policy"),
                ),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WebViewScreen(url: WebViewUrls.termsAndConditions),
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: _buildMenuItem("Terms of Service"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.30,
      ),
    );
  }

  // ----------------- LOGOUT & VERSION ------------------

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: TextButton(
        onPressed: () {
          Logout().show(context, isLoggingOut: (bool isLoggingOut) {
            setState(() {
              this.isLoggingOut = isLoggingOut;
            });
          });
        },
        child: Text(
          "Logout",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.10,
            letterSpacing: -0.30,
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        "Respyr Dietician 1.0",
        style: GoogleFonts.poppins(
          color: const Color(0xFFA0A8B2),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
        ),
      ),
    );
  }
}

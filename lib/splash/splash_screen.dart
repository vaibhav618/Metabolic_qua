import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client-dashboard/data/model/client_profile_model.dart';
import '../client_login_manager/client_login_manager.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(const Duration(seconds: 3), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenWalkthrough =
          prefs.getBool('has_seen_walkthrough') ?? false;

      if (!mounted) return;

      if (!hasSeenWalkthrough) {
        context.go(AppRoutes.walThroughScreen);
        return;
      }

      final ClientProfileModel? loadedProfile =
      await ClientLoginManager().loadClientProfile();

      if (!mounted) return;

      if (loadedProfile != null) {
        context.go(AppRoutes.clientDashboard, extra: loadedProfile);
      } else {
        context.go(AppRoutes.signInOptions);
      }
    } catch (e, stacktrace) {
      debugPrint('Error in splash navigation: $e\n$stacktrace');
      if (mounted) {
        context.go(AppRoutes.signInOptions);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF308BF9),
      body: Center(
        child: SvgPicture.asset("assets/images/icons/ic_logo_splash.svg"),
      ),
    );
  }
}

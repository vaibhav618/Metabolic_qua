import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../client_login_manager/client_login_manager.dart';
import '../../../../common/dialogs/floating_message.dart';
import '../../../../common/widgets/terms_policy_links.dart';
import '../../../../core/size/get_height.dart';
import '../../../../routes/app_routes.dart';
import '../../../profile_info/presentation/cubit/profile_cubit.dart';
import '../../data/services/check_profile_client.dart';
import '../../data/services/download_network_image_service.dart';
import '../../data/services/sign_in_with_google_service.dart';

class SignInOptions extends StatefulWidget {
  const SignInOptions({super.key});

  @override
  State<SignInOptions> createState() => _SignInOptionsState();
}

class _SignInOptionsState extends State<SignInOptions> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  bool get _isAnyTaskLoading => _isGoogleLoading || _isAppleLoading;

  static const _googleButtonColor = Color(0xFF252525);
  static const _emailBorderColor = Color(0xFFC7C6CE);
  static const _titleColor = Color(0xFF252525);

  bool _resetDoneOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<ProfileCubit>().clearProfileData();
      await _resetAllSessionsOnce();
    });
  }

  Future<void> _resetAllSessionsOnce() async {
    if (_resetDoneOnce) return;
    _resetDoneOnce = true;
    await _resetAllSessions();
  }

  Future<void> _resetAllSessions() async {
    try {
      await ClientLoginManager().clearClientProfile();
    } catch (_) {}

    try {
      await signOutGoogle();
    } catch (_) {}

    try {
      final g = GoogleSignIn();
      await g.signOut();
      await g.disconnect();
    } catch (_) {}

    try {
      if (Platform.isIOS) {
        const channel = MethodChannel('auth_session_clear');
        await channel.invokeMethod('clearAppleAuthSession');
      }
    } catch (_) {}
  }

  Future<void> _handleEmailSignIn() async {
    if (_isAnyTaskLoading) return;
    await _resetAllSessions();
    if (!mounted) return;
    context.push(AppRoutes.signInWithEmail);
  }

  Future<void> _handleGoogleSignInPressed() async {
    if (_isAnyTaskLoading) return;
    setState(() => _isGoogleLoading = true);

    try {
      await _resetAllSessions();

      final user = await handleGoogleSignIn();

      if (!mounted) return;

      if (user == null) {
        FloatingMessage.show(
          context,
          message: "Sign in canceled",
          type: FloatingMessageType.error,
        );
        return;
      }

      final clientProfile = await checkClientProfile(userEmail: user.email);

      if (!mounted) return;

      if (clientProfile != null) {
        bool isSaved = await ClientLoginManager().saveClientProfile(clientProfile);
        if (isSaved && mounted) {
          context.go(AppRoutes.clientDashboard, extra: clientProfile);
        } else if (mounted) {
          FloatingMessage.show(
            context,
            message: "Failed to save client profile.",
            type: FloatingMessageType.error,
          );
        }
      } else {
        String localPath = await downloadAndCacheImage(
          user.photoUrl ?? "assets/images/icons/default2.png",
        );

        if (mounted) {
          context.push(
            AppRoutes.dietitianScreen,
            extra: {
              "enteredEmail": user.email,
              "profileImage": localPath,
              "profileName": user.displayName,
            },
          );
        }
      }
    } catch (_) {
      if (mounted) {
        FloatingMessage.show(
          context,
          message: "Google sign-in failed. Please try again.",
          type: FloatingMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignInPressed() async {
    if (_isAnyTaskLoading) return;
    setState(() => _isAppleLoading = true);

    try {
      await _resetAllSessions();

      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        FloatingMessage.show(
          context,
          message: "Apple Sign-in is not available on this device.",
          type: FloatingMessageType.error,
        );
        return;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (!mounted) return;

      final email = credential.email;
      final id = credential.userIdentifier;
      print(id);
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((e) => (e ?? '').trim().isNotEmpty).join(' ').trim();

      final Map<String, String> nonNullableUserData = {
        "apple_user_id": credential.userIdentifier ?? "",
        "email": email?.trim() ?? "",
        "full_name": fullName.isNotEmpty ? fullName : "Apple User",
      };

      final response = await storeAppleUserData(nonNullableUserData);

      if (!mounted) return;

      if (response.isNotEmpty && response["status"] == "success") {
        if (response["message"] == "User exists") {
          final clientProfile = await checkClientProfile(
            userEmail: response["data"]["email"],
          );

          if (clientProfile != null && mounted) {
            bool isSaved = await ClientLoginManager().saveClientProfile(clientProfile);
            if (isSaved) {
              context.push(AppRoutes.clientDashboard, extra: clientProfile);
            }
          }
        } else {
          context.push(
            AppRoutes.dietitianScreen,
            extra: {
              "enteredEmail": nonNullableUserData["email"],
              "profileImage": "assets/images/icons/default2.png",
              "profileName": nonNullableUserData["full_name"],
            },
          );
        }
      } else {
        FloatingMessage.show(
          context,
          message: "Failed to store user data. Please try again.",
          type: FloatingMessageType.error,
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (!e.code.toLowerCase().contains("canceled")) {
        FloatingMessage.show(
          context,
          message: "Apple sign-in failed.",
          type: FloatingMessageType.error,
        );
      }
    } catch (_) {
      if (mounted) {
        FloatingMessage.show(
          context,
          message: "An unexpected error occurred.",
          type: FloatingMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  Future<Map<String, dynamic>> storeAppleUserData(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse("https://humorstech.com/dietitian/api/app/get_apple_user.php"),
        body: jsonEncode(userData),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("API Error: $e");
      return {};
    }
  }

  Widget _buildCustomButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    bool isLoading = false,
    BorderSide? borderSide,
    Widget? leading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 50)),
            side: borderSide ?? BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            vertical: rh(context: context, px: 20),
          ),
        ),
        child: isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: textColor,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: leading ?? const SizedBox(width: 24),
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.30,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 17),
            vertical: rh(context: context, px: 25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
              SizedBox(height: rh(context: context, px: 18)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 4)),
                child: Text(
                  "Sign in",
                  style: GoogleFonts.poppins(
                    color: _titleColor,
                    fontSize: rh(context: context, px: 34),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              SizedBox(height: rh(context: context, px: 30)),
              _buildCustomButton(
                context: context,
                text: "Continue with Email",
                onPressed: _isAnyTaskLoading ? null : _handleEmailSignIn,
                backgroundColor: Colors.white,
                textColor: _titleColor,
                borderSide: const BorderSide(width: 1, color: _emailBorderColor),
              ),
              SizedBox(height: rh(context: context, px: 20)),
              _buildCustomButton(
                context: context,
                text: "Continue with Google",
                isLoading: _isGoogleLoading,
                onPressed: _isAnyTaskLoading ? null : _handleGoogleSignInPressed,
                backgroundColor: _googleButtonColor,
                textColor: Colors.white,
                leading: Image.asset(
                  "assets/images/icons/ic_google.png",
                  width: rh(context: context, px: 24),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
              Visibility(
                visible: Platform.isIOS,
                child: _buildCustomButton(
                  context: context,
                  text: "Continue with Apple",
                  isLoading: _isAppleLoading,
                  onPressed: _isAnyTaskLoading ? null : _handleAppleSignInPressed,
                  backgroundColor: _googleButtonColor,
                  textColor: Colors.white,
                  leading: SvgPicture.asset(
                    "assets/images/icons/ic_apple1.svg",
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 26,
                  ),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
              TermsPolicyWidgets().termsPolicyFooter(context),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "For lifestyle tracking only.\nNot for medical use or diagnosis.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: rh(context: context, px: 25)),
            ],
          ),
        ),
      ),
    );
  }
}

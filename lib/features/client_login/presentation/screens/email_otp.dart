import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../client_login_manager/client_login_manager.dart';
import '../../../../common/dialogs/floating_message.dart';
import '../../../../common/widgets/terms_policy_links.dart';
import '../../../../routes/app_routes.dart';
import '../../../profile_info/presentation/widgets/profile_bottom_navigation.dart';
import '../widgets/otp_view.dart';

// Import your Bloc files here
import '../../bloc/otp_bloc.dart';
import '../../bloc/otp_event.dart';
import '../../bloc/otp_state.dart';

class EmailOtp extends StatelessWidget {
  final String enteredEmail;
  final int initialOtp;

  const EmailOtp({
    super.key,
    required this.enteredEmail,
    required this.initialOtp,
  });

  // Keep your original masking logic
  String maskEmail(String email) {
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${'*' * username.length}@$domain';
    }

    const visibleStart = 1;
    final visibleEnd = username.length > 4 ? 1 : 0;
    final maskedCount = username.length - visibleStart - visibleEnd;

    final maskedUsername = username.substring(0, visibleStart) +
        ('*' * maskedCount) +
        (visibleEnd > 0 ? username.substring(username.length - visibleEnd) : '');

    return '$maskedUsername@$domain';
  }

  @override
  Widget build(BuildContext context) {
    // Original Styles preserved exactly
    final TextStyle errorStyle = GoogleFonts.poppins(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    return BlocProvider(
      create: (context) => OtpBloc(initialOtp)..add(StartTimer()),
      child: BlocConsumer<OtpBloc, OtpState>(
        listener: (context, state) async {
          if (state.isSuccess) {
            FloatingMessage.show(context, message: 'OTP verified successfully!', type: FloatingMessageType.success);

            if (state.profile != null) {
              bool isSaved = await ClientLoginManager().saveClientProfile(state.profile);
              context.go(AppRoutes.clientDashboard, extra: state.profile);
              if(!isSaved) return;
            } else {
              context.go(
                AppRoutes.dietitianScreen,
                extra: {
                  "enteredEmail": enteredEmail,
                  "profileImage": "NA",
                  "profileName": "NA",
                },
              );

            }
          }
        },
        builder: (context, state) {
          final bool hasError = state.errorText != null;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "OTP",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2.04,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OtpTextField(
                          numberOfFields: 4,
                          alignment: Alignment.centerLeft,
                          borderColor: hasError ? Colors.red : const Color(0xFFF0F0F0),
                          focusedBorderColor: hasError ? Colors.red : const Color(0xFFF0F0F0),
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(10),
                          fillColor: const Color(0xFFF0F0F0),
                          filled: false,
                          textStyle: GoogleFonts.poppins(
                              color: hasError ? Colors.red : const Color(0xFF535359)),
                          fieldHeight: 60,
                          fieldWidth: 60,
                          showFieldAsBox: true,
                          onCodeChanged: (code) {
                            context.read<OtpBloc>().add(OtpInputChanged(code));
                          },
                          onSubmit: (String code) {
                            context.read<OtpBloc>().add(OtpInputChanged(code));
                          },
                        ),
                      ],
                    ),
                    if (hasError) ...[
                      const SizedBox(height: 5),
                      Text(state.errorText!, style: errorStyle),
                    ],
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "An OTP has been sent to\n",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.30,
                            ),
                          ),
                          TextSpan(
                            text: maskEmail(enteredEmail),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: (state.secondsRemaining > 0)
                                ? (state.secondsRemaining / 60)
                                : 0.0,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: (state.canResend && !state.isResending)
                              ? () => context.read<OtpBloc>().add(ResendOtpRequested(enteredEmail))
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFFF0F0F0),
                            backgroundColor: const Color(0xFF308BF9),
                          ),
                          child: Text(
                            state.canResend
                                ? "Resend OTP"
                                : "Resend available in ${state.secondsRemaining} sec",
                            style: GoogleFonts.poppins(
                              color: (state.canResend && !state.isResending)
                                  ? Colors.white
                                  : const Color(0xFFB9B9B9),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                              letterSpacing: -0.30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TermsPolicyWidgets().termsPolicyFooter(context),
                    const SizedBox(height: 10),
                    ProfileBottomNavigation(
                      onBack: () => Navigator.pop(context),
                      onNext: state.isVerifying ? null : () => context.read<OtpBloc>().add(VerifyOtpRequested(enteredEmail)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
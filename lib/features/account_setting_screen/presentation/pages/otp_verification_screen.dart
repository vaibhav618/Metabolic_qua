import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../cubit/otp_cubit.dart';
import '../cubit/otp_state.dart';
import 'change_password_screen.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit()..startResendTimer(),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView();

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state.isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(
                  'Change Password',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                leading: BackButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'An OTP has been sent to ',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.30,
                            ),
                          ),
                          TextSpan(
                            text: '****356@gmail.com',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildOtpInput(context, state),

                    if (state.error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 80),
                        child: Text(
                          state.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 30),

                    _buildResendOtpRow(context, state),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              bottomNavigationBar: BlocBuilder<OtpCubit, OtpState>(
                builder:
                    (context, state) =>
                        _buildOtpValidationButton(context, state),
              ),
            ),
            if (state.isLoading)
              Container(
                color: Colors.black.withAlpha(74),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOtpValidationButton(BuildContext context, OtpState state) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom + 5;
    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset > 5 ? bottomInset : 20,
        left: 16,
        right: 16,
      ),
      width: double.infinity,

      child: ElevatedButton(
        onPressed:
            (!state.isLoading && state.otp.length == 4)
                ? () => context.read<OtpCubit>().verifyOtp()
                : null,

        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor:
              (state.otp.length == 4) ? Colors.blue : Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),

        child: Text(
          'Next',
          style: GoogleFonts.poppins(
            color:
                (state.otp.length == 4)
                    ? Colors.white
                    : const Color(0xFF959595),

            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.10,
            letterSpacing: 0.30,
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context, OtpState state) {
    return Pinput(
      length: 4,
      controller: _otpController,
      focusNode: _otpFocusNode,

      keyboardType: TextInputType.number,
      onChanged: (value) => context.read<OtpCubit>().updateOtp(value),
      defaultPinTheme: PinTheme(
        width: 52,
        height: 52,
        textStyle: GoogleFonts.roboto(fontSize: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFF7F7F7),
          border: Border.all(
            color:
                state.error.isNotEmpty ? Colors.red : const Color(0xFFDADADA),
          ),
        ),
      ),
    );
  }

  Widget _buildResendOtpRow(BuildContext context, OtpState state) {
    final bool isButtonEnabled = state.resendSeconds == 0;
    final double progressValue = state.resendSeconds / 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors
                          .blue, // You can replace with AppColor.primaryBlueColor
                    ),
                    backgroundColor: Color(0xFFDAEBFF),
                  ),
                ),
              ),
              Text(
                '${state.resendSeconds}',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 8,
          child: ElevatedButton(
            onPressed:
                isButtonEnabled
                    ? () => context.read<OtpCubit>().resendOtp()
                    : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  isButtonEnabled ? Colors.blue : Colors.blue.withAlpha(74),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            child: Text(
              'Resend OTP',
              style: GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isButtonEnabled ? Colors.white : const Color(0xFF959595),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

  // BlocProvider(
  //   create: (_) => OtpCubit(OtpRepository()), // Injecting real repo
  //   child: OtpVerificationScreen(),
  // )

  // listener: (context, state) {
  //   if (state.isVerified) {
  //     Navigator.push(...); // navigate or show dialog
  //   }
  // },
  // builder: (context, state) {
  //   if (state.isLoading) return CircularProgressIndicator();
  //   return YourOtpUI(...);
  // }

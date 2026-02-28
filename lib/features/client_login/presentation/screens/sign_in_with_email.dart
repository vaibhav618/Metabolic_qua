import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/widgets/terms_policy_links.dart';
import '../../../../core/size/get_height.dart';
import '../../../profile_info/presentation/widgets/profile_bottom_navigation.dart';
import '../../../../common/dialogs/floating_message.dart';
import '../../bloc/sign_in_bloc.dart';
import '../../bloc/sign_in_event.dart';
import '../../bloc/sign_in_state.dart';
import 'email_otp.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(),
      child: BlocListener<SignInBloc, SignInState>(
        listenWhen: (prev, curr) =>
        prev.isSuccess != curr.isSuccess ||
            prev.errorText != curr.errorText,
        listener: (context, state) {
          if (state.isSuccess) {
            FloatingMessage.show(
              context,
              message: "OTP sent to ${state.email}",
              type: FloatingMessageType.success,
            );

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => EmailOtp(
                  enteredEmail: state.email,
                  initialOtp: state.otp!,
                ),
                transitionDuration: Duration.zero,
              ),
            );
          }

          // ✅ FIX: show ALL error messages (not only "Connection")
          if (state.errorText != null) {
            FloatingMessage.show(
              context,
              message: state.errorText!,
              type: FloatingMessageType.error,
            );
          }
        },
        child: BlocBuilder<SignInBloc, SignInState>(
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 13),
                    vertical: rh(context: context, px: 25),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 4),
                            ),
                            child: SvgPicture.asset(
                              "assets/images/icons/ic_logo_blue.svg",
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 18)),
                          Text(
                            "Email",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: rh(context: context, px: 34),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 25)),

                          // Input Container
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: rh(context: context, px: 10),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 10),
                              ),
                              border: Border.all(
                                color: state.errorText != null
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/icons/ic_email.svg",
                                  colorFilter: ColorFilter.mode(
                                    state.errorText == null
                                        ? const Color(0xFF535359)
                                        : Colors.red,
                                    BlendMode.srcIn,
                                  ),
                                  width: rh(context: context, px: 24),
                                ),
                                SizedBox(width: rh(context: context, px: 10)),
                                Expanded(
                                  child: TextFormField(
                                    controller: emailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: "Enter email address",
                                      border: InputBorder.none,
                                      counterText: "",
                                    ),
                                    onChanged: (val) => context
                                        .read<SignInBloc>()
                                        .add(EmailChanged(val)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (state.errorText != null)
                            Text(
                              state.errorText!,
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: rh(context: context, px: 12),
                              ),
                            ),

                          // Domain Chips (still hidden)
                          if (state.filteredDomains.isNotEmpty)
                            Visibility(
                              visible: false,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: rh(context: context, px: 20),
                                ),
                                child: SizedBox(
                                  height: rh(context: context, px: 36),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: state.filteredDomains
                                        .map(
                                          (domain) => Padding(
                                        padding:
                                        const EdgeInsets.only(right: 10),
                                        child: ActionChip(
                                          label: Text(domain),
                                          onPressed: () => context
                                              .read<SignInBloc>()
                                              .add(DomainSelected(domain)),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Loading spinner at the center when OTP is being sent
                      if (state.isOtpSending)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TermsPolicyWidgets().termsPolicyFooter(context),
                    ProfileBottomNavigation(
                      onBack: () => Navigator.pop(context),
                      onNext: state.isOtpSending
                          ? null
                          : () => context
                          .read<SignInBloc>()
                          .add(ValidateAndSendOtp()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/text_input_decoration.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/cubit/account_setting_cubit.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/cubit/account_setting_state.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/pages/otp_verification_screen.dart';
import 'package:respyr_dietitian/common/widgets/profile_avatar.dart';

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountSettingCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Account Setting',
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.30,
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: BlocBuilder<AccountSettingCubit, AccountSettingState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  ProfileAvatar(),
                  SizedBox(height: 40),
                  // Name
                  TextFormField(
                    readOnly: true,
                    initialValue: state.name,
                    decoration: buildInputDecoration(
                      hintText: "Name",
                      prefixIcon: "assets/images/common/profile_name_icon.svg",
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    readOnly: true,
                    initialValue: state.email,
                    decoration: buildInputDecoration(
                      hintText: "Email",
                      prefixIcon: "assets/images/common/profile_mail_icon.svg",
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mobile
                  TextFormField(
                    readOnly: true,
                    initialValue: state.mobileNumber,
                    decoration: buildInputDecoration(
                      hintText: "Mobile Number",
                      prefixIcon:
                          "assets/images/common/profile_number_icon.svg",
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OtpVerificationScreen(),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        SvgPicture.asset(
                          "assets/images/common/profile_change_pass_icon.svg",
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Change Password',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

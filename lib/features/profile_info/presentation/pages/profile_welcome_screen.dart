import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart' as law;

import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../client_login_manager/client_login_manager.dart';
import '../../../../common/bottom_sheets/help_bottom_sheet.dart';
import '../cubit/create_profile_cubit.dart';
import '../cubit/create_profile_state.dart';
import '../cubit/profile_cubit.dart';

class ProfileWelcomeScreen extends StatefulWidget {
  const ProfileWelcomeScreen({super.key});

  @override
  State<ProfileWelcomeScreen> createState() => _ProfileWelcomeScreenState();
}

class _ProfileWelcomeScreenState extends State<ProfileWelcomeScreen> {
  double _circleBottom = -400;
  bool _profileCreated = false;
  bool isProfileCreationErrorOccurred=false;

  @override
  void initState() {
    super.initState();

    // Animate the blue circle after build
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        setState(() => _circleBottom = -150);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_profileCreated) {
      final profileState = context.read<ProfileCubit>().state;

      // Make sure required data is available
      if (profileState.age != null && profileState.height != null && profileState.weight != null ) {
        final dietitianId = profileState.dietitianId ?? "NA";
        final phoneNo = profileState.phoneNo;
        final email = profileState.email;
        final clientName = profileState.name;
        final age = profileState.age!;
        final height = profileState.height!;
        final weight = profileState.weight!;
        final region = profileState.location;
        final location = profileState.location;
        final gender = profileState.gender;
        final password = "1234"; // Replace if you have actual password

        final profileImagePath = profileState.profileImagePath ?? 'assets/images/icons/default2.png';

        // Call API to create profile
        context.read<CreateProfileCubit>().createProfile(
          dietitianId: dietitianId!,
          phoneNo: phoneNo,
          email: email,
          profileName: clientName,
          age: age,
          gender: gender, // Replace with actual gender if available
          height: height,
          weight: weight,
          region: region,
          location: location,
          password: password,
          profileImagePath: profileImagePath, imageIsAvailable: profileImagePath=="assets/images/icons/default2.png"? false :true,
        );

        _profileCreated = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    final loader = law.LoadingAnimationWidget.staggeredDotsWave(
      color: Colors.blue,
      size: 50,
    );


    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          actionsPadding: EdgeInsets.symmetric(horizontal: 20),
          actions: [
            Visibility(
              visible: isProfileCreationErrorOccurred,
              child: ElevatedButton(
                  onPressed: () {
                    showHelpBottomSheet(
                      context,
                      supportEmail: "support@respyr.in",
                      whatsappNumberE164: "+919876543210",
                      emailSubject: "Dietitian app – help",
                      emailBody: "Hi team,\n\nI need help with ...\n\nThanks!",
                      whatsappMessage: "Hi! I need help with the app.",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      backgroundColor: Colors.white),
                  child: Text(
                    "Help?",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.10,
                      letterSpacing: 0.30,
                    ),
                  )),
            )
          ],
        ),
        body: SafeArea(
          child: BlocListener<CreateProfileCubit, CreateProfileState>(
              listener: (BuildContext context, CreateProfileState state) {
          
                if (state is CreateProfileFailure) {
                  setState(() {
                    isProfileCreationErrorOccurred = true;
                  });
                }
          
              },
              child: BlocBuilder<CreateProfileCubit, CreateProfileState>(
          
                builder: (BuildContext context, CreateProfileState state) {
          
          
          
                  print(state);
          
          
          
          
                  if (state is CreateProfileLoading) {
                    return SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            loader,
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Please hold on while we create your profile",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF535359),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }
          
                  if (state is CreateProfileFailure) {
          
          
          
                    return SafeArea(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                Text(
                                  "Oh No!",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: "Profile creation failed ",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF535359),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.30,
                                          )),
                                      TextSpan(
                                          text:
                                          "Status code: ${state.statusCode} ${state.error}. Please try again. If this occurs repeatedly, contact our team for further assistance.",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF535359),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.24,
                                          )),
                                    ])),
                                Spacer(),
                                SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          elevation: 0,
                                          backgroundColor: const Color(0xFF308BF9),
                                        ),
                                        child: Text(
                                          "Try again",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            height: 1.10,
                                            letterSpacing: 0.30,
                                          ),
                                        ))),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ));
                  }
          
                  if (state is CreateProfileSuccess) {
          
          
          
          
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          bottom: _circleBottom,
                          right: -150,
                          child: Container(
                            width: 400,
                            height: 400,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2F80ED),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 30,
                            right: 30,
                            child: InkWell(
                              onTap: () async {
          
          
                                bool isSaved = await ClientLoginManager().saveClientProfile(state.profile);
                                if (isSaved) {
                                  context.go(
                                    AppRoutes.clientDashboard,
                                    extra: state.profile,
                                  );
                                } else {
          
                                }
          
          
          
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Go to dashboard',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.10,
                                      letterSpacing: 0.30,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )),
                        _buildWelcomeUI(context)
                      ],
                    );
                  }
          
                  return const Center(child: CircularProgressIndicator());
                },
          
              )),
        ));
  }

  Widget _buildWelcomeUI(BuildContext context) {
    final profileState = context.read<ProfileCubit>().state;
    final cubit = context.read<ProfileCubit>();
    final bmi = cubit.getBMI();
    final bmr = cubit.getBMR();

    final profileImagePath = profileState.profileImagePath;
    final hasValidImage = profileImagePath != null &&
        profileImagePath.isNotEmpty &&
        File(profileImagePath).existsSync();

    final clientName = profileState.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 64,
              backgroundImage: hasValidImage
                  ? NetworkImage(profileImagePath)
                  : const AssetImage('assets/images/icons/default2.png') as ImageProvider,
              onBackgroundImageError: (_, __) {
                // You can handle logging here if needed
              },
              child: !hasValidImage
                  ? const Icon(Icons.person, size: 96, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome $clientName!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 34,
              fontWeight: FontWeight.w400,
              letterSpacing: -2.04,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your profile has been created',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.30,
            ),
          ),
          const SizedBox(height: 30),
          if (bmi != null && bmr != null) ...[
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Current BMI',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(text: '${bmi.toStringAsFixed(1)}kg/m'),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Transform.translate(
                                offset: const Offset(1, -3),
                                child: Text(
                                  '2',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    color: Color(0xFFC7C6CE),
                    width: 2,
                    thickness: 1,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Current BMR',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      Text(
                        '${bmr.toStringAsFixed(0)} kcal',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              "Missing profile data to calculate BMI/BMR.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class DietitianDetailScreen extends StatelessWidget {
  final String enteredEmail;
  final String imageUrlPath;
  final String profileName;
  const DietitianDetailScreen({super.key,  this.enteredEmail="NA",  this.imageUrlPath="NA",  this.profileName="NA"});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text(
                  'Is this your\nconsultant?',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2.04,
                  ),
                ),
              ),
              Spacer(),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 25),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF0F0F0),
                            shape: OvalBorder(),
                          ),
                          padding: EdgeInsets.all(1),
                          child: ClipOval(
                            child: state.dietitianImageUrl.isNotEmpty
                                ? Image.network(
                              state.dietitianImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Show default asset if network fails
                                return Image.asset(
                                  "assets/images/icons/default2.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                                : Image.asset(
                              "assets/images/icons/default2.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          state.dietitianName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),

                        Text(
                          'Dietitian',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          state.phoneNo,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.30,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Email address',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.20,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          state.dietitianEmail,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.30,
                          ),
                        ),
                        SizedBox(height: 60),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Color(0xFFC7C6CE)),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/common/closeicon.svg",
                                    height: 24,
                                    width: 24,
                                    colorFilter: ColorFilter.mode(
                                      Color(0xFFEA5455),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'No, incorrect',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1.10,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.go(AppRoutes.profileInfoScreen ,extra: {
                                  "stepCompleted": 1,
                                  "enteredEmail": enteredEmail,
                                  "profileImage": imageUrlPath,
                                  "profileName": profileName,
                                },);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Color(0xFFC7C6CE)),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/common/tick_icon.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Yes, correct',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1.10,
                                      letterSpacing: -0.30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
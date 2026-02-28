import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class GenderScreen extends StatelessWidget {
  final int stepCompleted;

  const GenderScreen({super.key, required this.stepCompleted});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final currentGender = cubit.state.gender;

    if (currentGender.isEmpty) {
      cubit.updateGender('Female'); // ✅ Set default if not selected yet
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top progress bar
            ProfileProgressBar(stepCompleted: stepCompleted),

            /// Gender content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'What’s your gender?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 34,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -2.04,
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// Gender Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGenderOption(
                              context,
                              "Female",
                              'assets/images/common/female_icon.svg',
                              state.gender,
                            ),
                            _buildGenderOption(
                              context,
                              "Male",
                              'assets/images/common/male_icon.svg',
                              state.gender,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return ProfileBottomNavigation(
              onBack: () {
                context.pop();
              },
              onNext: () {
                if (state.gender.isNotEmpty) {
                  // Proceed to next screen
                  // Navigator.push(...);
                  context.push(AppRoutes.ageScreen, extra: stepCompleted + 1);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select your gender')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    String genderLabel,
    String image,
    String selectedGender,
  ) {
    final isSelected = selectedGender == genderLabel;
    return GestureDetector(
      onTap: () => context.read<ProfileCubit>().updateGender(genderLabel),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: MediaQuery.of(context).size.height * 0.26,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF308BF9) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Color(0xFF308BF9) : const Color(0xFFF0F0F0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              genderLabel,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Color(0xFF308BF9),
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SvgPicture.asset(
                image,
                width: MediaQuery.of(context).size.width * 0.16,
                height: MediaQuery.of(context).size.height * 0.16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

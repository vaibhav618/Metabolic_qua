import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class AgeScreen extends StatefulWidget {
  final int stepCompleted;
  const AgeScreen({super.key, required this.stepCompleted});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final TextEditingController ageController = TextEditingController();
  String? errorText;
  final FocusNode _ageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_ageFocusNode);
    });
  }

  @override
  void dispose() {
    ageController.dispose();
    _ageFocusNode.dispose();

    super.dispose();
  }

  bool _validateInput() {
    final cubit = context.read<ProfileCubit>();
    final input = ageController.text;
    final error = cubit.validateAgeInput(input);
    setState(() => errorText = error);
    return error == null;
  }

  void _onNextPressed(ProfileCubit cubit) {
    if (_validateInput()) {
      final age = int.parse(ageController.text.trim());
      cubit.updateAge(age);

      context.push(AppRoutes.heightScreen, extra: widget.stepCompleted + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileProgressBar(stepCompleted: widget.stepCompleted),
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
                            'What’s your Age?',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -2.04,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            height: 85,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    errorText != null
                                        ? Colors.red
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    focusNode: _ageFocusNode,
                                    controller: ageController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                      hintText: "Enter your age",
                                      hintStyle: GoogleFonts.poppins(
                                        color: const Color(0xFF535359),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        height: 1.10,
                                        letterSpacing: -0.30,
                                      ),
                                      counterText: "",
                                      disabledBorder: noBorder,
                                      enabledBorder: noBorder,
                                      border: noBorder,
                                    ),
                                    onChanged: (_) => _validateInput(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6E6E6),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'years',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF535359),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (errorText != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 10,
                              ),
                              child: Text(
                                errorText!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final cubit = context.read<ProfileCubit>();
          
              return ProfileBottomNavigation(
                onBack: () {
                  context.pop();
                },
                onNext: () => _onNextPressed(cubit),
              );
            },
          ),
        ),
      ),
    );
  }
}

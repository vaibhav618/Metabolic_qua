import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/utils/validators.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class HeightScreen extends StatefulWidget {
  final int stepCompleted;

  const HeightScreen({super.key, required this.stepCompleted});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  final TextEditingController heightController = TextEditingController();
  String? errorText;

  final FocusNode _heightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_heightFocusNode);
    });
  }

  @override
  void dispose() {
    heightController.dispose();
    _heightFocusNode.dispose();
    super.dispose();
  }

  void _validateAndProceed(BuildContext context, ProfileState state) {
    final cubit = context.read<ProfileCubit>();
    final input = heightController.text.trim();

    final error = Validators.validateHeight(input, state.heightUnit);

    setState(() => errorText = error);

    if (error != null) return;

    if (state.heightUnit == HeightUnit.cm) {
      final cm = double.parse(input);
      cubit.updateHeight(cm);
    } else {
      final parts = input.split('.');
      final feet = int.tryParse(parts[0]) ?? 0;
      final inches = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      cubit.updateHeightFromFeet(feet, inches);
    }
    context.push(AppRoutes.weightScreen, extra: widget.stepCompleted + 1);
  }

  bool _validateInput(ProfileState state) {
    final input = heightController.text.trim();
    final error = Validators.validateHeight(input, state.heightUnit);
    setState(() => errorText = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

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
                      final cubit = context.read<ProfileCubit>();
                      final isFeet = state.heightUnit == HeightUnit.feet;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24),
                          Text(
                            'How tall are you?',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -2.04,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        focusNode: _heightFocusNode,
                                        controller: heightController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        maxLength: isFeet ? 5 : 3,
                                        decoration: InputDecoration(
                                          hintText: "Enter your height",
                                          hintStyle: GoogleFonts.poppins(
                                            color: const Color(0xFF535359),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                            height: 1.10,
                                            letterSpacing: -0.30,
                                          ),
                                          counterText: "",
                                          border: noBorder,
                                          enabledBorder: noBorder,
                                          disabledBorder: noBorder,
                                          focusedBorder: noBorder,
                                        ),
                                        onChanged: (_) {
                                          _validateInput(state);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        cubit.updateHeightUnit(HeightUnit.cm);
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                            0.08,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              state.heightUnit == HeightUnit.cm
                                                  ? const Color(0xFF308BF9)
                                                  : const Color(0xFFE6E6E6),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'cm',
                                            style: GoogleFonts.poppins(
                                              color:
                                                  state.heightUnit ==
                                                          HeightUnit.cm
                                                      ? Colors.white
                                                      : const Color(0xFF535359),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        cubit.updateHeightUnit(HeightUnit.feet);
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                            0.08,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              state.heightUnit ==
                                                      HeightUnit.feet
                                                  ? const Color(0xFF308BF9)
                                                  : const Color(0xFFE6E6E6),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'feet',
                                            style: GoogleFonts.poppins(
                                              color:
                                                  state.heightUnit ==
                                                          HeightUnit.feet
                                                      ? Colors.white
                                                      : const Color(0xFF535359),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
              return ProfileBottomNavigation(
                onBack: () {
                  context.pop();
                },
                onNext: () {
                  FocusScope.of(context).unfocus(); // optional UX polish
                  _validateAndProceed(context, state);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

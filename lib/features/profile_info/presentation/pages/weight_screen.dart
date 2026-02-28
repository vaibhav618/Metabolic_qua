import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/utils/validators.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/weight_unit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class WeightScreen extends StatefulWidget {
  final int stepCompleted;

  const WeightScreen({super.key, required this.stepCompleted});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final TextEditingController weightController = TextEditingController();
  String? errorText;
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_weightFocusNode);
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  void _validateAndProceed(BuildContext context, ProfileState state) {
    if (_validateInput(state)) {
      final cubit = context.read<ProfileCubit>();
      final input = weightController.text.trim();
      final weightValue = double.parse(input);

      // Always convert to kg before storing
      if (state.weightUnit == WeightUnit.kg) {
        cubit.updateWeight(weightValue); // already in kg
      } else {
        cubit.updateWeightFromLbs(weightValue); // convert lbs → kg
      }

      context.push(AppRoutes.profileWelcomeScreen, extra: widget.stepCompleted + 1);
    }
  }

  bool _validateInput(ProfileState state) {
    final input = weightController.text.trim();
    final error = Validators.validateWeight(input, state.weightUnit);
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
                      final isKg = state.weightUnit == WeightUnit.kg;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One more to go!',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF535359),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.24,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'How much do you weigh?',
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
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        focusNode: _weightFocusNode,
                                        controller: weightController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        maxLength: isKg ? 5 : 6,
                                        decoration: InputDecoration(
                                          hintText: "Enter your weight",
                                          hintStyle: GoogleFonts.poppins(
                                            color: const Color(0xFF535359),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: -0.30,
                                          ),
                                          counterText: "",
                                          border: noBorder,
                                          enabledBorder: noBorder,
                                          focusedBorder: noBorder,
                                          disabledBorder: noBorder,
                                        ),
                                        onChanged: (_) {
                                          _validateInput(state);
                                        },
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        cubit.updateWeightUnit(WeightUnit.kg);
                                        weightController.clear();
                                        setState(() => errorText = null);
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                            0.08,
                                        decoration: BoxDecoration(
                                          color:
                                              isKg
                                                  ? const Color(0xFF308BF9)
                                                  : const Color(0xFFE6E6E6),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'kg',
                                            style: GoogleFonts.poppins(
                                              color:
                                                  isKg
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
                                        cubit.updateWeightUnit(WeightUnit.lbs);
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                            0.08,
                                        decoration: BoxDecoration(
                                          color:
                                              !isKg
                                                  ? const Color(0xFF308BF9)
                                                  : const Color(0xFFE6E6E6),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'lbs',
                                            style: GoogleFonts.poppins(
                                              color:
                                                  !isKg
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
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return ProfileBottomNavigation(
              onBack: () {
                context.pop();
              },
              onNext: () {
                FocusScope.of(context).unfocus();
                _validateAndProceed(context, state);
              },
            );
          },
        ),
      ),
    );
  }
}

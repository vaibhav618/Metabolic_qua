import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/text_input_decoration.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/pages/account_setting_screen.dart';
import 'package:respyr_dietitian/features/create_password_screen/presentation/cubit/create_password_cubit.dart';
import 'package:respyr_dietitian/features/create_password_screen/presentation/cubit/create_password_state.dart';

class CreatePasswordScreen extends StatelessWidget {
  final int stepCompleted;
  const CreatePasswordScreen({super.key, required this.stepCompleted});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePasswordCubit(),
      child: BlocListener<CreatePasswordCubit, CreatePasswordState>(
        listenWhen:
            (previous, current) =>
                !previous.submittedSuccessfully &&
                current.submittedSuccessfully,
        listener: (context, state) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (e) => AccountSettingScreen()),
          );
        },
        child: _CreatePasswordView(stepCompleted: stepCompleted),
      ),
    );
  }
}

class _CreatePasswordView extends StatefulWidget {
  final int stepCompleted;
  const _CreatePasswordView({required this.stepCompleted});

  @override
  State<_CreatePasswordView> createState() => _CreatePasswordViewState();
}

class _CreatePasswordViewState extends State<_CreatePasswordView> {
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final int totalStep = 5;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatePasswordCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocBuilder<CreatePasswordCubit, CreatePasswordState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Progress bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(totalStep, (index) {
                      final isFilled = index < widget.stepCompleted;
                      return Flexible(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(
                            right: index < totalStep - 1 ? 4.0 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isFilled ? Colors.black : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    'Create password',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34,

                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                  SizedBox(height: 30),

                  /// New password field
                  TextFormField(
                    obscureText: !_isNewPasswordVisible,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: buildInputDecoration(
                      hintText: "Enter new password",
                      prefixIcon:
                          "assets/images/common/password_enter_icon.svg",
                      errorText:
                          state.showErrors && !state.isSuccess
                              ? 'Password must meet all criteria'
                              : null,
                      obscure: !_isNewPasswordVisible,
                     // showSuffixIcon: true,
                      onSuffixTap: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    onChanged: cubit.updateNewPassword,
                  ),

                  const SizedBox(height: 8),

                  /// Show only failed validations
                  if ((state.showErrors || state.newPassword.isNotEmpty) &&
                      !(state.isSuccess && state.passwordMatch))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!state.hasMinLength)
                          _buildValidationItem("At least 6 characters", false),
                        if (!state.hasUppercase)
                          _buildValidationItem(
                            "At least one uppercase letter",
                            false,
                          ),
                        if (!state.hasNumber)
                          _buildValidationItem("At least one number", false),
                        if (!state.hasSpecialChar)
                          _buildValidationItem(
                            "At least one special character",
                            false,
                          ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  /// Confirm password field
                  TextFormField(
                    obscureText: !_isConfirmPasswordVisible,

                    decoration: buildInputDecoration(
                      hintText: "Re-enter new password",
                      prefixIcon:
                          "assets/images/common/password_reenter_icon.svg",
                      errorText:
                          state.showErrors && !state.passwordMatch
                              ? 'Passwords do not match'
                              : null,
                      obscure: !_isConfirmPasswordVisible,
                      //showSuffixIcon: true,
                      onSuffixTap: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    onChanged: cubit.updateConfirmPassword,
                  ),

                  const SizedBox(height: 30),

                  if (state.submittedSuccessfully)
                    const Text(
                      "Password changed successfully!",
                      style: TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<
        CreatePasswordCubit,
        CreatePasswordState
      >(builder: (context, state) => _passwordValidationButton(context, state)),
    );
  }

  Widget _passwordValidationButton(
    BuildContext context,
    CreatePasswordState state,
  ) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom + 5;
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 5 ? bottomInset : 30,
        left: 26,
        right: 26,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_outlined,
              size: 26,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<CreatePasswordCubit>();

                cubit.submit();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF308BF9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 13,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Text(
                    "Finish up",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,

                      fontWeight: FontWeight.w400,
                      height: 1.10,
                      letterSpacing: -1.08,
                    ),
                  ),
                  Spacer(),
                  const Icon(
                    Icons.chevron_right_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationItem(String label, bool valid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.cancel,
            color: valid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: valid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

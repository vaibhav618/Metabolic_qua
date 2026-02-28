import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/text_input_decoration.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/cubit/change_password_cubit.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/cubit/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChangePasswordCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// New password field
                TextFormField(
                  obscureText: !_isNewPasswordVisible,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: buildInputDecoration(
                    hintText: "Enter new password",
                    prefixIcon: "assets/images/common/password_enter_icon.svg",
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
                   // showSuffixIcon: true,
                    onSuffixTap: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
      bottomNavigationBar: BlocBuilder<
        ChangePasswordCubit,
        ChangePasswordState
      >(builder: (context, state) => _passwordValidationButton(context, state)),
    );
  }

  Widget _passwordValidationButton(
    BuildContext context,
    ChangePasswordState state,
  ) {
    final cubit = context.read<ChangePasswordCubit>();
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
            (state.isSuccess && state.passwordMatch) ? cubit.submit : null,

        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),

        child: Text(
          'Update',
          style: GoogleFonts.poppins(
            color:
                (state.isSuccess && state.passwordMatch)
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

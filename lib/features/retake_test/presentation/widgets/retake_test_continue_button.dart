// lib/features/retake_test/presentation/widgets/retake_test_continue_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/retake_test_cubit.dart';
import '../../bloc/retake_test_state.dart';
import '../theme/retake_test_tokens.dart';

class RetakeTestContinueButton extends StatelessWidget {
  const RetakeTestContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RetakeTestCubit, RetakeTestState, bool>(
      selector: (state) => state.isButtonEnabled,
      builder: (context, enabled) {
        return SafeArea(
          child: Padding(
            padding: RetakeTestTokens.ctaPadding,
            child: SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                enabled: enabled,
                label: 'Continue',
                child: ElevatedButton(
                  onPressed:
                  enabled ? () => context.read<RetakeTestCubit>().submit() : null,
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const WidgetStatePropertyAll(
                      RetakeTestTokens.ctaInnerPadding,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          RetakeTestTokens.bottomRadius,
                        ),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                        if (states.contains(WidgetState.disabled)) {
                          return RetakeTestTokens.ctaDisabled;
                        }
                        return RetakeTestTokens.ctaEnabled;
                      },
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

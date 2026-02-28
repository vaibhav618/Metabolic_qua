import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/domain/data/practice_ste_data.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/domain/enums/practice_test.dart';
import '../../../../../core/size/get_height.dart';

class PracticeMenu extends StatelessWidget {
  final bool isStepCompleted;
  final bool enabled;
  final VoidCallback onItemClicked;
  final PracticeTestSteps practiceTestStep;

  const PracticeMenu({
    super.key,
    required this.isStepCompleted,
    required this.enabled,
    required this.onItemClicked,
    required this.practiceTestStep,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = enabled ? const Color(0xFF252525) : const Color(0xFFA1A1A1);
    final arrowColor = enabled ? const Color(0xFF252525) : const Color(0xFFA1A1A1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onItemClicked : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: rh(context: context, px: 12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: rh(context: context, px: 5),
                  children: [
                    Text(
                      practiceTestStep.title,
                      style: GoogleFonts.poppins(
                        color: titleColor,
                        fontSize: rh(context: context, px: 18),
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.72,
                      ),
                    ),
                    if (isStepCompleted)
                      Text(
                        "Completed",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF3EAF58),
                          fontSize: rh(context: context, px: 15),
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.30,
                        ),
                      )
                    else
                      Text(
                        practiceTestStep.subtitle,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA1A1A1),
                          fontSize: rh(context: context, px: 12),
                          fontWeight: FontWeight.w400,
                          height: 1.30,
                          letterSpacing: -0.24,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: rh(context: context, px: 24),
                color: arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


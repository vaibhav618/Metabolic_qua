import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget goalItem({
  required String goalName,      // e.g. "Weight", "Muscle Mass", "Height"
  required String currentStat,   // e.g. "68"
  required String targetStat,    // e.g. "80"
  required String unit,          // e.g. "kg", "cm", "L"
}) {
  // ---- Parse safely ----
  final double curr = double.tryParse(currentStat) ?? 0;
  final double target = double.tryParse(targetStat) ?? 0;

  // ---- Determine goal direction from current & target ----
  // target > current  → need to increase (e.g. weight gain, height gain)
  // target < current  → need to decrease (e.g. weight loss, body fat %, BP)
  // target == current → already at target
  final double diffRaw = target - curr;           // +ve → increase, -ve → decrease
  final double absDiff = (diffRaw).abs();

  final String absDiffText =
  absDiff % 1 == 0 ? absDiff.toStringAsFixed(0) : absDiff.toStringAsFixed(1);

  bool isIncreaseGoal = diffRaw > 0;
  bool isDecreaseGoal = diffRaw < 0;

  // ---- Completion logic ----
  bool isTargetCompleted;
  if (diffRaw == 0) {
    // Exactly at target
    isTargetCompleted = true;
  } else if (isIncreaseGoal) {
    // Need to increase → completed when current >= target
    isTargetCompleted = curr >= target;
  } else if (isDecreaseGoal) {
    // Need to decrease → completed when current <= target
    isTargetCompleted = curr <= target;
  } else {
    // Fallback
    isTargetCompleted = false;
  }

  // ---- Dynamic progress message ----
  String progressMessage;

  if (isTargetCompleted) {
    // If overshoot (e.g. target 80, current 82 in increase goal)
    if (isIncreaseGoal && curr > target) {
      final over = curr - target;
      final overText =
      over % 1 == 0 ? over.toStringAsFixed(0) : over.toStringAsFixed(1);
      progressMessage =
      "Amazing! You’ve crossed your target by $overText $unit. You can now focus on maintaining it.";
    } else if (isDecreaseGoal && curr < target) {
      final over = target - curr;
      final overText =
      over % 1 == 0 ? over.toStringAsFixed(0) : over.toStringAsFixed(1);
      progressMessage =
      "Amazing! You’ve gone $overText $unit below your target. You can now focus on maintaining it.";
    } else {
      progressMessage =
      "Congratulations! You’ve achieved your target stat.";
    }
  } else {
    if (isIncreaseGoal) {
      // Need to increase
      progressMessage =
      "You need to gain $absDiffText $unit to reach your target of $targetStat $unit.";
    } else if (isDecreaseGoal) {
      // Need to decrease
      progressMessage =
      "You need to lose $absDiffText $unit to reach your target of $targetStat $unit.";
    } else {
      // diffRaw == 0 already handled, this is just extra safety
      progressMessage =
      "You are at $currentStat $unit. Target is $targetStat $unit.";
    }
  }

  // ---- Optional: small direction label under goal name ----
  String goalDirectionLabel;
  if (isIncreaseGoal) {
    goalDirectionLabel = "Goal: Increase this stat";
  } else if (isDecreaseGoal) {
    goalDirectionLabel = "Goal: Decrease this stat";
  } else {
    goalDirectionLabel = "Goal: Maintain this stat";
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Goal name
      Text(
        goalName,
        style: GoogleFonts.poppins(
          color: const Color(0xFF535359),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.10,
          letterSpacing: -0.24,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        goalDirectionLabel,
        style: GoogleFonts.poppins(
          color: const Color(0xFF738298),
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.20,
        ),
      ),
      const SizedBox(height: 20),

      // Current vs Target row
      Row(
        children: [
          statItem(
            message: currentStat,
            headingText: "Current stat",
            unit: unit,
          ),
          const Spacer(),
          const Expanded(
            flex: 3,
            child: SizedBox(
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const Spacer(),
          statItem(
            message: targetStat,
            headingText: "Target stat",
            unit: unit,
          ),
        ],
      ),
      const SizedBox(height: 10),

      // Achievement / status card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: ShapeDecoration(
          color: isTargetCompleted
              ? const Color(0xFFD0F3D8) // green-ish
              : const Color(0xFFF2D1CD), // red-ish
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  currentStat,
                  style: GoogleFonts.poppins(
                    color: isTargetCompleted
                        ? const Color(0xFF0B8226)
                        : const Color(0xFF7E190C),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.26,
                    letterSpacing: -0.40,
                  ),
                ),
                Text(
                  "Current stat",
                  style: GoogleFonts.poppins(
                    color: isTargetCompleted
                        ? const Color(0xFF0B8226)
                        : const Color(0xFF7E190C),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.20,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                progressMessage,
                style: GoogleFonts.poppins(
                  color: isTargetCompleted
                      ? const Color(0xFF0B8226)
                      : const Color(0xFF7E190C),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.20,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
    ],
  );
}

// Reusable stat item (Current / Target)
Column statItem({
  required String message,
  required String headingText,
  required String unit,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$message $unit",
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.26,
          letterSpacing: -0.40,
        ),
      ),
      Text(
        headingText,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.20,
        ),
      ),
    ],
  );
}

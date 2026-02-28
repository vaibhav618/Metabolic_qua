import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/widgets/weight_pogress_bar.dart';

class WeightProgressBadgeCurrent extends StatelessWidget {
  final double initialWeight;
  final double currentWeight;
  final double targetedWeight;

  const WeightProgressBadgeCurrent({
    super.key,
    required this.initialWeight,
    required this.currentWeight,
    required this.targetedWeight,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ detect goal type
    final bool isLossGoal = targetedWeight < initialWeight;
    final bool isGainGoal = targetedWeight > initialWeight;

    // ✅ achieved delta (kg moved towards target)
    final double achievedKg = isLossGoal
        ? (initialWeight - currentWeight).clamp(0, double.infinity)
        : isGainGoal
        ? (currentWeight - initialWeight).clamp(0, double.infinity)
        : 0;

    // ✅ total goal delta
    final double totalGoal = isLossGoal
        ? (initialWeight - targetedWeight).clamp(0, double.infinity)
        : isGainGoal
        ? (targetedWeight - initialWeight).clamp(0, double.infinity)
        : 0;

    final String verb = isGainGoal ? "Gain" : "Lose";

    // ✅ Extracted milestone steps from your badge list
    // These are cumulative steps: 0.5, 1, 2, 5, 10, and final goal.
    final List<_WeightBadgeModel> badges = _buildStepBadges(
      verb: verb,
      totalGoal: totalGoal,
    );

    // ✅ pick current / next badge (first not achieved)
    final _WeightBadgeModel currentBadge = badges.firstWhere(
          (b) => achievedKg < b.stepKg,
      orElse: () => badges.last,
    );

    // ✅ range start = previous milestone
    final int idx = badges.indexOf(currentBadge);
    final double rangeStartKg = (idx <= 0) ? 0 : badges[idx - 1].stepKg;
    final double rangeEndKg = currentBadge.stepKg;

    return _WeightProgressCard(
      title: currentBadge.title,
      description: currentBadge.description,
      currentValueKg: achievedKg,
      rangeStartKg: rangeStartKg,
      rangeEndKg: rangeEndKg,
    );
  }

  List<_WeightBadgeModel> _buildStepBadges({
    required String verb,
    required double totalGoal,
  }) {
    // If no goal, just show kickoff
    if (totalGoal <= 0) {
      return [
        _WeightBadgeModel(
          title: "Kickoff King",
          description: "Log your weight for the first time to begin your journey.",
          stepKg: 0,
        ),
      ];
    }

    // Base steps from your description
    final List<_WeightBadgeModel> base = [
      _WeightBadgeModel(
        title: "Kickoff King",
        description: "Log your weight for the first time to begin your journey.",
        stepKg: 0,
      ),
      _WeightBadgeModel(
        title: "Mini Drop Badge",
        description: "$verb 0.5 kg to unlock your first progress badge.",
        stepKg: 0.5,
      ),
      _WeightBadgeModel(
        title: "Weight Slayer",
        description: "$verb 1 kg to complete your first major milestone.",
        stepKg: 1,
      ),
      _WeightBadgeModel(
        title: "Momentum Master",
        description: "$verb 2 kg to build strong, consistent momentum.",
        stepKg: 2,
      ),
      _WeightBadgeModel(
        title: "Cutting Champion",
        description: "$verb 5 kg to reach a significant transformation checkpoint.",
        stepKg: 5,
      ),
      _WeightBadgeModel(
        title: "Transformation Titan",
        description: "$verb 10 kg to unlock your major transformation badge.",
        stepKg: 10,
      ),
    ];

    // Keep only milestones up to totalGoal
    final List<_WeightBadgeModel> filtered =
    base.where((b) => b.stepKg <= totalGoal).toList();

    // Always add final goal step (Mission Accomplished)
    final bool hasGoalStep =
        filtered.isNotEmpty && (filtered.last.stepKg == totalGoal);

    if (hasGoalStep) {
      // Replace last step title/desc with mission accomplished
      final last = filtered.removeLast();
      filtered.add(
        _WeightBadgeModel(
          title: "Mission Accomplished",
          description: "Reach your target weight to complete your mission.",
          stepKg: last.stepKg,
        ),
      );
    } else {
      filtered.add(
        _WeightBadgeModel(
          title: "Mission Accomplished",
          description: "Reach your target weight to complete your mission.",
          stepKg: totalGoal,
        ),
      );
    }

    // Ensure kickoff is always there
    if (filtered.isEmpty) {
      filtered.insert(
        0,
        _WeightBadgeModel(
          title: "Kickoff King",
          description: "Log your weight for the first time to begin your journey.",
          stepKg: 0,
        ),
      );
    }

    return filtered;
  }
}

class _WeightProgressCard extends StatelessWidget {
  final String title;
  final String description;

  final double currentValueKg;
  final double rangeStartKg;
  final double rangeEndKg;

  const _WeightProgressCard({
    required this.title,
    required this.description,
    required this.currentValueKg,
    required this.rangeStartKg,
    required this.rangeEndKg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFFCAD2DD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset("assets/images/icons/ic_badge.svg"),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF252525),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF535359),
            ),
          ),
          const SizedBox(height: 18),

          ExactProgressBar(
            currentValueKg: currentValueKg,
            rangeStartKg: rangeStartKg,
            rangeEndKg: rangeEndKg,
            showValueText: false,
          ),
        ],
      ),
    );
  }
}

class _WeightBadgeModel {
  final String title;
  final String description;

  /// cumulative milestone step: 0.5, 1, 2, 5, 10, goal
  final double stepKg;

  _WeightBadgeModel({
    required this.title,
    required this.description,
    required this.stepKg,
  });
}

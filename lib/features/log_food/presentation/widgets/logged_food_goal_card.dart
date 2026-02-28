import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/widgets/linear_progress.dart';
import '../../../../common/widgets/ring_progress.dart';

Widget loggedFoodGoalCard({
  required DietPlanStrategyModel dietPlanStrategyModel,
  required Map<String, double> total,
}) {
  String asIntOr1dp(num v) => (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);

  /// Safe % helper: guards divide-by-zero and clamps 0..100
  double pct(num consumed, num target) {
    if (target == 0 || target.isNaN) return 0;
    final p = (consumed.toDouble() / target.toDouble()) * 100.0;
    if (p.isNaN || p.isInfinite) return 0;
    return p.clamp(0, 100);
  }

  // Read totals safely (support both 'fiber' and 'fibre')
  final double kcal   = (total['kcal'] ?? 0).toDouble();
  final double protein= (total['protein'] ?? 0).toDouble();
  final double carbs  = (total['carbs'] ?? 0).toDouble();
  final double fat    = (total['fat'] ?? 0).toDouble();
  final double fiber  = (total['fiber'] ?? total['fibre'] ?? 0).toDouble();

  // Rounded ints for progress numerators (UI numbers remain from doubles via asIntOr1dp)
  final int caloriesInteger = kcal.round();
  final int proteinInteger  = protein.round();
  final int carbsInteger    = carbs.round();
  final int fatInteger      = fat.round();
  final int fibreInteger    = fiber.round();

  // Targets (tolerate nulls)
  final int calTarget   = (dietPlanStrategyModel.caloriesTarget );
  final int proteinTarget  = (dietPlanStrategyModel.proteinTarget  );
  final int carbsTarget = (dietPlanStrategyModel.carbsTarget   );
  final int fatTarget   = (dietPlanStrategyModel.fatTarget     );
  final int fiberTarget = (dietPlanStrategyModel.fiberTarget );

  // Individual percentages (0..100)
  final double caloriesPercentage = pct(caloriesInteger, calTarget);
  final double proteinPercentage  = pct(proteinInteger,  proteinTarget);
  final double carbsPercentage    = pct(carbsInteger,    carbsTarget);
  final double fibrePercentage    = pct(fibreInteger,    fiberTarget);
  final double fatPercentage      = pct(fatInteger,      fatTarget);

  // Scientifically balanced weighted total (0..100)
  double calculateTotalNutritionPercent({
    required double caloriesPercent,
    required double proteinPercent,
    required double carbsPercent,
    required double fatPercent,
    required double fiberPercent,
  }) {
    const weights = {
      'calories': 0.35,
      'protein' : 0.25,
      'carbs'   : 0.20,
      'fat'     : 0.15,
      'fiber'   : 0.05,
    };

    final total = (caloriesPercent * weights['calories']!) +
        (proteinPercent * weights['protein']!) +
        (carbsPercent * weights['carbs']!) +
        (fatPercent * weights['fat']!) +
        (fiberPercent * weights['fiber']!);

    return total.clamp(0, 100);
  }

  final double totalPercentage = calculateTotalNutritionPercent(
    caloriesPercent: caloriesPercentage,
    proteinPercent: proteinPercentage,
    carbsPercent: carbsPercentage,
    fatPercent: fatPercentage,
    fiberPercent: fibrePercentage,
  );

  return Card(
    color: Colors.white,
    elevation: 0.5,
    child: Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 32, left: 6, right: 6),
      child: Column(
        children: [
          // ---- TOP GOAL CARD (dynamic total %) ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: ShapeDecoration(
              color: const Color(0xFF252525),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              spacing: 15,
              children: [
                AnimatedRingProgress(
                  progress: (totalPercentage / 100.0),
                  size: 50,
                  strokeWidth: 5,
                  startAngle: -90,
                  roundCaps: true,
                  trackColor: const Color(0xFFD9D9D9),
                  progressColor: const Color(0xFF3FAF58),
                  gapDegrees: 0,
                  center: SvgPicture.asset(
                    'assets/images/icons/ic_trophy.svg',
                    width: 24,
                    color: Colors.white,
                  ),
                  shadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                      color: Color(0x22000000),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Text(
                      "Daily Goal",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.10,
                        letterSpacing: -0.24,
                      ),
                    ),
                    Text(
                      "${totalPercentage.toStringAsFixed(0)}% completed",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.26,
                        letterSpacing: -0.36,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---- CALORIES RING ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 15,
              children: [
                Center(
                  child: AnimatedRingProgress(
                    progress: (caloriesPercentage / 100.0),
                    size: 50,
                    strokeWidth: 5,
                    startAngle: -90,
                    roundCaps: true,
                    backgroundColor: Colors.white,
                    trackColor: const Color(0xFFD9D9D9),
                    progressColor: const Color(0xFFFF9900),
                    gapDegrees: 0,
                    center: SvgPicture.asset('assets/images/icons/ic_calories.svg', width: 24),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Text(
                      "Calories",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                        letterSpacing: -0.24,
                      ),
                    ),
                    Text(
                      "${asIntOr1dp(kcal)} kcal / $calTarget Kcal",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.26,
                        letterSpacing: -0.36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(color: const Color(0xFFD9D9D9), height: 1, width: double.infinity),
          ),
          const SizedBox(height: 28),

          // ---- PROTEIN & FIBER ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              spacing: 50,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Protein",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedLinearCapsProgress(
                          progress: (proteinPercentage / 100.0),
                          height: 6,
                          trackColor: const Color(0xFFDADADA),
                          progressColor: const Color(0xFF2EAD4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${asIntOr1dp(protein)} g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.36,
                        ),
                      ),
                      Text(
                        "out of $proteinTarget g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.20,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Fibre",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedLinearCapsProgress(
                          progress: (fibrePercentage / 100.0),
                          height: 6,
                          trackColor: const Color(0xFFDADADA),
                          progressColor: const Color(0xFF2EAD4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${asIntOr1dp(fiber)} g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.36,
                        ),
                      ),
                      Text(
                        "out of $fiberTarget g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.20,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---- FAT & CARBS ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              spacing: 50,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Fat",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedLinearCapsProgress(
                          progress: (fatPercentage / 100.0),
                          height: 6,
                          trackColor: const Color(0xFFDADADA),
                          progressColor: const Color(0xFF2EAD4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${asIntOr1dp(fat)} g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.36,
                        ),
                      ),
                      Text(
                        "out of $fatTarget g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.20,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Carbs",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF535359),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedLinearCapsProgress(
                          progress: (carbsPercentage / 100.0),
                          height: 6,
                          trackColor: const Color(0xFFDADADA),
                          progressColor: const Color(0xFF2EAD4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${asIntOr1dp(carbs)} g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.36,
                        ),
                      ),
                      Text(
                        "out of $carbsTarget g",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.20,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

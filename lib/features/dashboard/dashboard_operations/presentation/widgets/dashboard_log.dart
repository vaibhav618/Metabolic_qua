import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/ring_progress.dart';
import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../tracking/water_tracking/presentation/screens/water_tracking.dart';
import '../../../../tracking/weight_tracking/presentation/screens/weight_tracking.dart';
import '../../bloc/dashboard_operation_bloc.dart';
import '../../bloc/dashboard_operation_state.dart';
import '../sheets/update_water_intake_sheet.dart';
import '../sheets/update_weight_sheet.dart';

class DashboardLog extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const DashboardLog({super.key, required this.clientProfileModel});




  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 30,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Logging",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: BlocBuilder<DashboardOperationBloc, DashboardOperationState>(
            builder: (context, state) {



              if (state is! DashboardOperationLoaded) {
                // You can show shimmer/loader here if you want
                return const SizedBox.shrink();
              }


              final double waterMl = state.waterIntake;
              final double waterTargetMl = state.targetWaterMl;
              final double waterProgress = (state.waterProgressPercent / 100).clamp(0.0, 1.0);
              final double waterLitres = waterMl / 1000.0;
              final double waterTargetLitres = waterTargetMl / 1000.0;

              const int glassSizeMl = 250;
              final int consumedGlasses =
              (waterMl / glassSizeMl).floor(); // 250ml per glass
              final int targetGlasses =
              waterTargetMl > 0 ? (waterTargetMl / glassSizeMl).round() : 0;

              final double currentWeight = state.currentWeight;
              final double targetWeight = state.targetedWeight;
              final double weightProgress = ((state.currentWeight / state.targetedWeight)  * 100 ) / 100;



              return IntrinsicHeight(
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<DashboardOperationBloc>(),
                                child: WaterTracking(
                                  clientProfileModel: clientProfileModel,
                                  targetWaterInML: state.targetWaterMl,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFE1E6ED),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(18, 18, 8, 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RingProgress(
                                progress: waterProgress,
                                size: 45,
                                strokeWidth: 4,
                                progressColor: const Color(0xFF308BF9),
                                trackColor: const Color(0xFFD9D9D9),
                                center: SvgPicture.asset(
                                  "assets/images/icons/ic_water.svg",
                                  width: 24,
                                ),
                                startAngle: -90,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Water Intake",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              const SizedBox(height: 31),

                              // e.g. 2.4L
                              Text(
                                "${waterLitres.toStringAsFixed(1)}L",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: -0.60,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // e.g. "5 of 8 glasses"
                              Text(
                                targetGlasses > 0
                                    ? "$consumedGlasses of $targetGlasses glasses"
                                    : "$consumedGlasses glasses",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFA1A1A1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 17,
                                      vertical: 7,
                                    ),
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFD9D9D9),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Goal : ${waterTargetLitres.toStringAsFixed(1)}L',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                            letterSpacing: -0.18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      showUpdateWaterIntakeSheet(
                                        context: context,
                                        clientProfile: clientProfileModel,
                                      );
                                    },
                                    style: IconButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF308BF9),
                                        width: 2,
                                      ),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(25000),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      color: Color(0xFF308BF9),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------- WEIGHT CARD ----------------
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeightTracking(
                                clientProfile: clientProfileModel,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFE1E6ED),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(18, 18, 8, 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RingProgress(
                                progress: weightProgress,
                                size: 45,
                                strokeWidth: 4,
                                progressColor: const Color(0xFFB388EB),
                                trackColor: const Color(0xFFD9D9D9),
                                center: SvgPicture.asset(
                                  "assets/images/icons/ic_weight.svg",
                                  width: 24,
                                ),
                                startAngle: -90,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Current Weight",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              const SizedBox(height: 31),

                              // e.g. "66.0 kg"
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 5,
                                children: [
                                  Text(
                                    currentWeight.toStringAsFixed(0),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0,
                                      letterSpacing: -0.60,

                                    ),
                                    textHeightBehavior: const TextHeightBehavior(
                                      leadingDistribution: TextLeadingDistribution.even,
                                    ),

                                  ),
                                  Text("Kg",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.0,
                                        letterSpacing: -0.24,
                                      ),
                                      textHeightBehavior: const TextHeightBehavior(
                                        leadingDistribution: TextLeadingDistribution.even,
                                      )

                                  )
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Subtitle: "Target: 68.0 kg"
                              Text(
                                "Target: ${targetWeight.toStringAsFixed(1)} kg",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFA1A1A1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 17,
                                      vertical: 7,
                                    ),
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFD9D9D9),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Goal : ${targetWeight.toStringAsFixed(0)} Kg",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400,
                                            height: 1,
                                            letterSpacing: -0.18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      showWeightUpdateBottomSheet(
                                        context: context,
                                        clientProfile: clientProfileModel,
                                      );
                                    },
                                    style: IconButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF308BF9),
                                        width: 2,
                                      ),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(25000),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      color: Color(0xFF308BF9),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

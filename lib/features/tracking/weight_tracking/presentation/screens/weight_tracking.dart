import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../common/dialogs/floating_message.dart';

import '../../../../dashboard/dashboard_operations/bloc/dashboard_operation_bloc.dart';
import '../../../../dashboard/dashboard_operations/bloc/dashboard_operation_event.dart';
import '../../../../dashboard/dashboard_operations/bloc/dashboard_operation_state.dart';

import '../../bloc/weight_log_bloc.dart';
import '../../bloc/weight_log_event.dart';
import '../../bloc/weight_log_state.dart';
import '../../data/repository/weight_log_repository.dart';

import '../widgets/weight_chart.dart';
import '../widgets/weight_log_history_card.dart';

class WeightTracking extends StatefulWidget {
  final ClientProfileModel clientProfile;

  const WeightTracking({
    super.key,
    required this.clientProfile,
  });

  @override
  State<WeightTracking> createState() => _WeightTrackingState();
}

class _WeightTrackingState extends State<WeightTracking> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 🔹 Weight history bloc
        BlocProvider(
          create: (_) => WeightLogBloc(
            repository: WeightLogRepository(),
          )..add(LoadWeightLogs(widget.clientProfile.profileId)),
        ),

        // 🔹 DashboardOperationBloc – now API-based (fetches currentWeight + targetWeight)
        BlocProvider(
          create: (_) => DashboardOperationBloc(
            profileId: widget.clientProfile.profileId,
            dietPlanId: 0, // or actual diet plan id if you have it
            date: DateTime.now().toIso8601String().split('T').first, // "YYYY-MM-DD"
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7FA),
          elevation: 0,
          title: Text(
            "Weight tracker",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 15,
            ),
          ),
        ),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              /// ✅ weight saved
              BlocListener<DashboardOperationBloc, DashboardOperationState>(
                listenWhen: (prev, curr) {
                  if (prev is DashboardOperationLoaded &&
                      curr is DashboardOperationLoaded) {
                    return prev.lastWeightLogSaveSuccess == false &&
                        curr.lastWeightLogSaveSuccess == true;
                  }
                  return curr is DashboardOperationLoaded &&
                      curr.lastWeightLogSaveSuccess == true;
                },
                listener: (context, state) {
                  if (state is DashboardOperationLoaded &&
                      state.lastWeightLogSaveSuccess) {
                    FloatingMessage.show(
                      context,
                      message: "Weight updated successfully",
                      type: FloatingMessageType.success,
                    );

                    context.read<WeightLogBloc>().add(
                      LoadWeightLogs(widget.clientProfile.profileId),
                    );
                  }
                },
              ),

              /// ✅ delete
              BlocListener<WeightLogBloc, WeightLogState>(
                listener: (context, state) {
                  if (state is WeightLogDeleted) {
                    FloatingMessage.show(
                      context,
                      message: "Weight log deleted",
                      type: FloatingMessageType.success,
                    );

                    context.read<WeightLogBloc>().add(
                      LoadWeightLogs(widget.clientProfile.profileId),
                    );
                  }
                },
              ),
            ],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// TOP SECTION – log today’s weight
                  Builder(
                    builder: (context) {
                      return BlocBuilder<DashboardOperationBloc,
                          DashboardOperationState>(
                        buildWhen: (previous, current) =>
                        current is DashboardOperationLoaded,
                        builder: (context, opState) {
                          if (opState is! DashboardOperationLoaded) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 11),
                            child: Container(
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 21),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Log Weight",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF252525),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Today",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFA1A1A1),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    spacing: 0,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          context
                                              .read<DashboardOperationBloc>()
                                              .add(DecrementWeight());
                                        },
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Color(0xFF252525),
                                        ),
                                        style: IconButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF252525),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 19,
                                          vertical: 31,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          spacing: 10,
                                          children: [
                                            Text(
                                              opState.currentWeight.toString(),
                                              style: GoogleFonts.poppins(
                                                color:
                                                const Color(0xFF252525),
                                                fontSize: 28,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "Kg",
                                              style: GoogleFonts.poppins(
                                                color:
                                                const Color(0xFF252525),
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          context
                                              .read<DashboardOperationBloc>()
                                              .add(IncrementWeight());
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          color: Color(0xFF252525),
                                        ),
                                        style: IconButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF252525),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 36),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<DashboardOperationBloc>()
                                            .add(
                                          SubmitWeightLog(
                                            profileId: widget
                                                .clientProfile.profileId,
                                            currentWeight:
                                            opState.currentWeight,
                                            targetWeight:
                                            opState.targetedWeight,
                                            loggedBy: "client",
                                            loggedById: widget
                                                .clientProfile.profileId,
                                            notes:
                                            "Weight logged manually",
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF308BF9),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(25000),
                                        ),
                                      ),
                                      child: Text(
                                        opState.isWeightLogSaving
                                            ? "Saving..."
                                            : "Log",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// HISTORY + CHART
                  BlocBuilder<WeightLogBloc, WeightLogState>(
                    buildWhen: (p, c) =>
                    c is WeightLogLoaded ||
                        c is WeightLogLoading ||
                        c is WeightLogDeleted ||
                        c is WeightLogError,
                    builder: (context, state) {
                      if (state is WeightLogError) {
                        return Text(
                          state.message,
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        );
                      }

                      if (state is WeightLogLoaded) {
                        final logs = state.logs;

                        // 🔹 take FIRST value as latest (recents first)
                        double latestWeight;
                        if (logs.isNotEmpty) {
                          latestWeight = logs.first.weightKg;
                        } else {
                          latestWeight = double.tryParse(
                              widget.clientProfile.weight) ??
                              0;
                        }

                        // sync latest to top +/- area
                        context.read<DashboardOperationBloc>().add(
                          UpdateCurrentWeight(newWeight: latestWeight),
                        );

                        if (logs.isEmpty) {
                          return WeightLogHistoryCard(
                            logs: [],
                            onDelete: null,
                          );
                        }

                        final allWeights =
                        logs.map((e) => e.weightKg).toList();
                        final allDates = logs.map((e) {
                          final d = e.logDate;
                          final t = e.logTime.isNotEmpty
                              ? e.logTime
                              : "00:00:00";
                          return DateTime.tryParse("$d $t") ??
                              DateTime.now();
                        }).toList();

                        final latest = logs.first; // first = most recent

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Column(
                            children: [
                              WeightMiniChart(
                                allWeights: allWeights.reversed.toList(),
                                allDates: allDates.reversed.toList(),
                                targetWeight: latest.targetWeight,
                                weightChangeType: latest.weightChangeType,
                              ),
                              const SizedBox(height: 30),
                              WeightLogHistoryCard(
                                logs: logs,
                                onDelete: (logId) {
                                  context.read<WeightLogBloc>().add(
                                    DeleteWeightLog(
                                      id: logId,
                                      profileId: widget
                                          .clientProfile.profileId,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

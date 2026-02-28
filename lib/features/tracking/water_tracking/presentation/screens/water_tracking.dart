import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../../common/dialogs/floating_message.dart';
import '../../../../../common/widgets/water_progress.dart';
import '../../../../dashboard/dashboard_operations/bloc/dashboard_operation_bloc.dart';
import '../../../../dashboard/dashboard_operations/bloc/dashboard_operation_event.dart';
import '../../../../dashboard/dashboard_operations/bloc/dashboard_operation_state.dart';
import '../../bloc/water_log_bloc.dart';
import '../../bloc/water_log_event.dart';
import '../../bloc/water_log_state.dart';
import '../../data/repository/water_log_repository.dart';
import '../widgets/water_bar_chart.dart';

class WaterTracking extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final double targetWaterInML;

  const WaterTracking({
    super.key,
    required this.clientProfileModel,
    required this.targetWaterInML,
  });

  @override
  State<WaterTracking> createState() => _WaterTrackingState();
}

class _WaterTrackingState extends State<WaterTracking> {
  late final WaterLogRepository _repository;
  late final ScrollController _dayScrollController;
  bool _didCenterOnce = false;

  // Keys for each day item so we can center them without fixed width
  List<GlobalKey> _dayItemKeys = [];

  @override
  void initState() {
    super.initState();
    _repository = WaterLogRepository(
      baseUrl: 'https://humorstech.com/dietitian/api/app/',
    );
    _dayScrollController = ScrollController();
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  void _scrollDayToCenter(int index) {
    if (index < 0 || index >= _dayItemKeys.length) return;

    final contextItem = _dayItemKeys[index].currentContext;
    if (contextItem == null) return;

    Scrollable.ensureVisible(
      contextItem,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      alignment: 0.5, // 0 = left, 0.5 = center, 1 = right
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WaterLogBloc>(
          create: (_) => WaterLogBloc(repository: _repository)
            ..add(
              LoadWaterLog(
                profileId: widget.clientProfileModel.profileId,
                targetWaterInML: widget.targetWaterInML,
              ),
            ),
        ),

        BlocProvider<DashboardOperationBloc>(
          create: (_) => DashboardOperationBloc(
            profileId: widget.clientProfileModel.profileId,
            dietPlanId: 0, // or pass actual dietPlanId if needed
            date: null,    // backend will treat as today
          ),
        ),
      ],

      child: BlocListener<DashboardOperationBloc, DashboardOperationState>(
        listenWhen: (previous, current) {
          if (previous is DashboardOperationLoaded &&
              current is DashboardOperationLoaded) {
            return previous.lastWaterLogSaveSuccess !=
                current.lastWaterLogSaveSuccess ||
                previous.errorMessage != current.errorMessage;
          }
          return false;
        },
        listener: (listenerContext, dashState) {
          if (dashState is DashboardOperationLoaded) {
            if (dashState.lastWaterLogSaveSuccess) {
              FloatingMessage.show(
                context,
                message: "Water intake logged",
                type: FloatingMessageType.success,
              );

              final waterBloc = listenerContext.read<WaterLogBloc>();

              waterBloc.add(
                LoadWaterLog(
                  profileId: widget.clientProfileModel.profileId,
                  targetWaterInML: widget.targetWaterInML,
                  showLoader: false, // 👈 keep UI smooth
                ),
              );

              listenerContext
                  .read<DashboardOperationBloc>()
                  .add(ResetWaterLocal());
            } else if (dashState.errorMessage != null &&
                dashState.errorMessage!.isNotEmpty) {
              FloatingMessage.show(
                context,
                message: dashState.errorMessage!,
                type: FloatingMessageType.error,
              );
            }
          }
        },

        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F7FA),
            surfaceTintColor: const Color(0xFFF5F7FA),
            title: Row(
              children: [
                Text(
                  "Water tracking",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                    letterSpacing: -0.30,
                  ),
                )
              ],
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<WaterLogBloc, WaterLogState>(
              builder: (context, state) {
                if (state is WaterChartLoading ||
                    state is WaterChartInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WaterChartError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                if (state is WaterChartLoaded) {
                  final allDays = state.days;
                  final selectedIndex = state.selectedIndex;

                  // For disabling future dates & chart filter
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  // Ensure keys length matches days length
                  if (_dayItemKeys.length != allDays.length) {
                    _dayItemKeys = List.generate(
                      allDays.length,
                          (_) => GlobalKey(),
                    );
                  }

                  if (!_didCenterOnce &&
                      selectedIndex >= 0 &&
                      allDays.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollDayToCenter(selectedIndex);
                    });
                    _didCenterOnce = true;
                  }

                  final selectedDay = (selectedIndex >= 0 &&
                      selectedIndex < allDays.length)
                      ? allDays[selectedIndex]
                      : null;

                  // ---- Filter out future dates for chart ----
                  final pastOrTodayDays = allDays.where((d) {
                    final date = d.date;
                    final dateOnly =
                    DateTime(date.year, date.month, date.day);
                    return !dateOnly.isAfter(today); // keep <= today
                  }).toList();

                  final last7Days = pastOrTodayDays.length > 7
                      ? pastOrTodayDays
                      .sublist(pastOrTodayDays.length - 7)
                      : pastOrTodayDays;

                  return Column(
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 11),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 16),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: SizedBox(
                            height: 64,
                            child: ListView.separated(
                              controller: _dayScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: allDays.length,
                              itemBuilder: (context, index) {
                                final date = allDays[index].date;

                                final dayNum = date.day
                                    .toString()
                                    .padLeft(2, '0');

                                const shortDays = [
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat",
                                  "Sun"
                                ];
                                final shortDay =
                                shortDays[date.weekday - 1];

                                final dateOnly = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                );
                                final bool isFuture =
                                dateOnly.isAfter(today);

                                final bool isDisabled = isFuture;
                                final bool isSelected =
                                    !isDisabled &&
                                        index == selectedIndex;

                                Color textColor;
                                if (isDisabled) {
                                  textColor =
                                  const Color(0xFFB0B0B0);
                                } else {
                                  textColor = isSelected
                                      ? Colors.white
                                      : const Color(0xFF252525);
                                }

                                return GestureDetector(
                                  key: _dayItemKeys[index],
                                  onTap: () {
                                    if (isDisabled) return;
                                    context
                                        .read<WaterLogBloc>()
                                        .add(
                                      SelectWaterLogDay(index),
                                    );
                                    _scrollDayToCenter(index);
                                  },
                                  child: Opacity(
                                    opacity: isDisabled ? 0.4 : 1.0,
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: isSelected
                                            ? const Color(0xFF308BF9)
                                            : Colors.transparent,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                        ),
                                      ),
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dayNum,
                                            style:
                                            GoogleFonts.poppins(
                                              color: textColor,
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.w600,
                                              height: 1.26,
                                              letterSpacing: -0.30,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            shortDay,
                                            style:
                                            GoogleFonts.poppins(
                                              color: textColor,
                                              fontSize: 10,
                                              fontWeight:
                                              FontWeight.w400,
                                              letterSpacing: -0.20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) =>
                              const SizedBox(width: 0),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 20,
                            ),
                            child: Column(
                              spacing: 20,
                              children: [
                                if (selectedDay != null) ...[
                                  Builder(
                                    builder: (_) {
                                      // glass size in ml
                                      const int glassSizeMl = 250;

                                      final double targetLitersForDay =
                                      (selectedDay.targetLiters > 0
                                          ? selectedDay.targetLiters
                                          : (state.targetWaterInML /
                                          1000.0));

                                      final int targetMlForDay =
                                      (targetLitersForDay * 1000)
                                          .round();

                                      // from API for that day (history)
                                      final int
                                      apiConsumedMlForDay =
                                      (selectedDay.consumedLiters *
                                          1000)
                                          .round();

                                      final selectedDate =
                                          selectedDay.date;
                                      final selectedDateOnly =
                                      DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                      );

                                      final bool isTodaySelected =
                                          selectedDateOnly.year ==
                                              today.year &&
                                              selectedDateOnly.month ==
                                                  today.month &&
                                              selectedDateOnly.day ==
                                                  today.day;

                                      // how many glasses target
                                      final double targetedGlasses =
                                          targetMlForDay /
                                              glassSizeMl;

                                      return BlocBuilder<
                                          DashboardOperationBloc,
                                          DashboardOperationState>(
                                        builder:
                                            (dashContext, dashState) {
                                          if (dashState
                                          is! DashboardOperationLoaded) {
                                            return const SizedBox
                                                .shrink();
                                          }

                                          final double baseMl =
                                          apiConsumedMlForDay
                                              .toDouble();

                                          final double addedMl =
                                          isTodaySelected
                                              ? dashState
                                              .waterIntake
                                              : 0.0;

                                          final double
                                          currentConsumedMl =
                                              baseMl + addedMl;

                                          final double
                                          consumedGlasses =
                                              currentConsumedMl /
                                                  glassSizeMl;

                                          final bool isSaving =
                                              dashState
                                                  .isWaterLogSaving;

                                          // conditions
                                          final bool canIncrement =
                                              isTodaySelected &&
                                                  !isSaving;
                                          final bool canDecrement =
                                              isTodaySelected &&
                                                  !isSaving &&
                                                  currentConsumedMl >=
                                                      glassSizeMl;

                                          return Container(
                                            width: double.infinity,
                                            decoration:
                                            BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(18),
                                            ),
                                            child: Column(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                const SizedBox(
                                                    height: 21),
                                                Text(
                                                  "1 Glass (${glassSizeMl}ml)",
                                                  style: GoogleFonts
                                                      .poppins(
                                                    color: const Color(
                                                        0xFF252525),
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight
                                                        .w400,
                                                    height: 1.75,
                                                    letterSpacing:
                                                    -0.24,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 10),
                                                Text(
                                                  isTodaySelected
                                                      ? "Today"
                                                      : "History",
                                                  style: GoogleFonts
                                                      .poppins(
                                                    color: const Color(
                                                        0xFFA1A1A1),
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight
                                                        .w400,
                                                    height: 1,
                                                    letterSpacing:
                                                    -0.24,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 24),

                                                // +/- + glass
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  spacing: 43,
                                                  children: [
                                                    // − button
                                                    IconButton(
                                                      onPressed:
                                                      canDecrement
                                                          ? () {
                                                        // 1) update local UI
                                                        dashContext
                                                            .read<
                                                            DashboardOperationBloc>()
                                                            .add(
                                                          DecrementWater(),
                                                        );

                                                        // 2) send -1 glass log
                                                        dashContext
                                                            .read<
                                                            DashboardOperationBloc>()
                                                            .add(
                                                          InsertWaterLog(
                                                            profileId: widget.clientProfileModel.profileId,
                                                            consumedMl: -glassSizeMl,
                                                            targetedMl: targetMlForDay,
                                                            loggedBy: 'dietitian',
                                                            loggedById: "dieticianId", // TODO: actual dietician id
                                                            notes: null,
                                                          ),
                                                        );
                                                      }
                                                          : null,
                                                      style: IconButton
                                                          .styleFrom(
                                                        side:
                                                        const BorderSide(
                                                          color: Color(
                                                              0xFF252525),
                                                          width: 2,
                                                        ),
                                                        minimumSize:
                                                        Size.zero,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              25000),
                                                        ),
                                                      ),
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 4,
                                                      ),
                                                      icon: const Icon(
                                                        Icons.remove,
                                                        color: Color(
                                                            0xFF252525),
                                                      ),
                                                    ),

                                                    // glass display
                                                    SimpleWaterGlass(
                                                      height: 80,
                                                      width: 64,
                                                      targetMl:
                                                      targetMlForDay
                                                          .toDouble(),
                                                      consumedMl:
                                                      currentConsumedMl,
                                                    ),

                                                    // + button
                                                    IconButton(
                                                      onPressed:
                                                      canIncrement
                                                          ? () {
                                                        // 1) update local UI
                                                        dashContext
                                                            .read<
                                                            DashboardOperationBloc>()
                                                            .add(
                                                          IncrementWater(),
                                                        );

                                                        // 2) send +1 glass log
                                                        dashContext
                                                            .read<
                                                            DashboardOperationBloc>()
                                                            .add(
                                                          InsertWaterLog(
                                                            profileId: widget.clientProfileModel.profileId,
                                                            consumedMl: glassSizeMl,
                                                            targetedMl: targetMlForDay,
                                                            loggedBy: 'dietitian',
                                                            loggedById: "dieticianId", // TODO: actual dietician id
                                                            notes: null,
                                                          ),
                                                        );
                                                      }
                                                          : null,
                                                      style: IconButton
                                                          .styleFrom(
                                                        side:
                                                        const BorderSide(
                                                          color: Color(
                                                              0xFF252525),
                                                          width: 2,
                                                        ),
                                                        minimumSize:
                                                        Size.zero,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              25000),
                                                        ),
                                                      ),
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 4,
                                                      ),
                                                      icon: const Icon(
                                                        Icons.add,
                                                        color: Color(
                                                            0xFF252525),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(
                                                    height: 40),

                                                // glasses progress
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    spacing: 10,
                                                    children: [
                                                      Row(
                                                        children:
                                                        List.generate(
                                                          targetedGlasses
                                                              .toInt(),
                                                              (index) {
                                                            return Expanded(
                                                              child:
                                                              Container(
                                                                margin:
                                                                const EdgeInsets.only(right: 4),
                                                                height:
                                                                5,
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: index + 1 <= consumedGlasses.toInt()
                                                                      ? const Color(0xFF308BF9)
                                                                      : const Color(0xFFF0F0F0),
                                                                  borderRadius:
                                                                  BorderRadius.circular(8),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      RichText(
                                                        text:
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: consumedGlasses
                                                                  .toStringAsFixed(
                                                                  1),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                color: const Color(
                                                                    0xFF308BF9),
                                                                fontSize:
                                                                17,
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                height:
                                                                1.24,
                                                                letterSpacing:
                                                                -0.34,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                              " out of ${targetedGlasses.toStringAsFixed(1)} glasses",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                color: const Color(
                                                                    0xFFA1A1A1),
                                                                fontSize:
                                                                17,
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                height:
                                                                1.24,
                                                                letterSpacing:
                                                                -0.34,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(
                                                    height: 40),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],

                                // ------------- Last 7 days chart -------------
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Analysis',
                                              style:
                                              GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight.w400,
                                                height: 1.75,
                                                letterSpacing: -0.24,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Last 7 days',
                                              style:
                                              GoogleFonts.poppins(
                                                color: const Color(
                                                    0xFFA1A1A1),
                                                fontSize: 10,
                                                fontWeight:
                                                FontWeight.w400,
                                                height: 2.10,
                                                letterSpacing: -0.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        height: 1,
                                      ),
                                      const SizedBox(height: 8),

                                      // Chart
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 11,
                                          vertical: 12,
                                        ),
                                        child: SizedBox(
                                          height: 150,
                                          width: double.infinity,
                                          child: last7Days.isEmpty
                                              ? Center(
                                            child: Text(
                                              'No water data found',
                                              style: GoogleFonts
                                                  .poppins(
                                                color:
                                                const Color(
                                                    0xFFA1A1A1),
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                              : WaterBarChart(
                                            days: last7Days,
                                            targetWaterInML: state
                                                .targetWaterInML,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

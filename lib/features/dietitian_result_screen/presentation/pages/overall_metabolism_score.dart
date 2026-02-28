import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../core/size/get_height.dart';
import '../../../../routes/app_routes.dart';
import '../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';
import '../../../bluetooth_device_connectivity/domain/params/result_screen_params.dart';

class OverallMetabolismScore extends StatefulWidget {
  final GeneratingResultModel result;
  final ClientProfileModel clientProfileModel;

  const OverallMetabolismScore({
    super.key,
    required this.result,
    required this.clientProfileModel,
  });

  @override
  State<OverallMetabolismScore> createState() => _OverallMetabolismScoreState();
}

class _OverallMetabolismScoreState extends State<OverallMetabolismScore> {

  String _formatDttm(String? dttm) {

    print(dttm);
    if (dttm == null || dttm.isEmpty) return '';

    try {
      // If the datetime string includes microseconds, we need to remove them or adjust the format
      // Replace microseconds part if present (e.g., ".030819") by removing or truncating it
      final formattedDate = dttm.split('.').first; // Remove microseconds part
      final date = DateTime.parse(formattedDate).toLocal();

      // Return the formatted date using DateFormat
      return DateFormat('d MMM yyyy, h:mma').format(date);
    } catch (_) {
      return dttm ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final double horizontalPadding = isSmallScreen
        ? rh(context: context, px: 16.0)
        : rh(context: context, px: 20.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await navToDashboard(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFF0F6FD),
          surfaceTintColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                navToDashboard(context);
              },
              icon: const Icon(Icons.close),
            )
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0F6FD),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.7552],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: rh(context: context, px: 110),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RepaintBoundary(child: _buildHeaderSection(isSmallScreen)),
                        RepaintBoundary(child: _buildMainContentSection(screenSize)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: rh(context: context, px: 12),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        context.push(
                          AppRoutes.overallResultScreen,
                          extra: ResultScreenParams(
                            result: widget.result,
                            clientProfileModel: widget.clientProfileModel,
                          ),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF308BF9),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(rh(context: context, px: 50)),
                        ),
                        padding: EdgeInsets.all(rh(context: context, px: 16)),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_right,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> navToDashboard(BuildContext context) async {
    bool didCancel = false;
    if (context.mounted) {
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
    }
    return didCancel;
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/images/icons/ic_test_check.svg"),
                SizedBox(width: rh(context: context, px: 5)),
                Text(
                  "Completed",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3EAF58),
                    fontSize: isSmallScreen
                        ? rh(context: context, px: 10)
                        : rh(context: context, px: 12),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
            SizedBox(height: rh(context: context, px: 11),),
            Flexible(
              child: Text(
                _formatDttm(widget.result.dateTime.toString()),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: isSmallScreen
                      ? rh(context: context, px: 10)
                      : rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                  letterSpacing: -0.24,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          "Metabolism Score",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: isSmallScreen
                ? rh(context: context, px: 28)
                : rh(context: context, px: 34),
            fontWeight: FontWeight.w400,
            letterSpacing: -2.04,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentSection(Size screenSize) {
    final bool isSmallScreen = screenSize.width < 360;
    final double scoreFontSize =
    isSmallScreen ? rh(context: context, px: 80.0) : rh(context: context, px: 100.0);
    final double zoneFontSize =
    isSmallScreen ? rh(context: context, px: 20.0) : rh(context: context, px: 25.0);

    final dailyFocusTitle = widget.result.respyrResponse.dayFocus?.title ?? "";
    final dailyFocusNote = widget.result.respyrResponse.dayFocus?.note ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildScoreDisplay(scoreFontSize),
        _buildZoneText(zoneFontSize),
        SizedBox(height: rh(context: context, px: 48)),
        RepaintBoundary(
          child: MetabolismScale(
            value: widget.result.respyrResponse.fatLossMetabolismScore.score,
          ),
        ),
        SizedBox(height: rh(context: context, px: 37)),
        Text(
          widget.result.respyrResponse.fatLossMetabolismScore
              .scientificInterpretation.title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 25),
            fontWeight: FontWeight.w600,
            letterSpacing: rh(context: context, px: -1),
          ),
        ),
        SizedBox(height: rh(context: context, px: 15)),
        Text(
          widget.result.respyrResponse.fatLossMetabolismScore
              .scientificInterpretation.text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            height: rh(context: context, px: 1.30),
            letterSpacing: rh(context: context, px: -0.24),
          ),
        ),
        SizedBox(height: rh(context: context, px: 40)),
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F7FA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rh(context: context, px: 10)),
            ),
          ),
          padding: EdgeInsets.all(rh(context: context, px: 15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/images/icons/ic_icons.svg"),
              SizedBox(height: rh(context: context, px: 15)),
              Text(
                dailyFocusTitle,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 18),
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -0.72,
                ),
              ),
              SizedBox(height: rh(context: context, px: 20)),
              Text(
                dailyFocusNote,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: rh(context: context, px: 1.30),
                  letterSpacing: rh(context: context, px: -0.30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.result.respyrResponse.fatLossMetabolismScore.score
              .toStringAsFixed(0),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            letterSpacing: -2,
            height: 1.0,
          ),
        ),
        SizedBox(width: rh(context: context, px: 2)),
        Text(
          "%",
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: fontSize * 0.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.40,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Color getZoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case "focus":
        return const Color(0xFFE48326);
      case "moderate":
        return const Color(0xFFFFBF2D);
      case "optimal":
        return const Color(0xFF3FAF58);
      default:
        return Colors.grey;
    }
  }

  Widget _buildZoneText(double fontSize) {
    return RichText(
      text: TextSpan(
        text: "You're Score is ",
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: rh(context: context, px: 18),
          fontWeight: FontWeight.w600,
          letterSpacing: -0.72,
        ),
        children: [
          TextSpan(
            text: widget.result.respyrResponse.fatLossMetabolismScore.zone,
            style: GoogleFonts.poppins(
              color: getZoneColor(
                  widget.result.respyrResponse.fatLossMetabolismScore.zone),
              fontSize: rh(context: context, px: 18),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.72,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationText(double fontSize) {
    return Text(
      widget.result.respyrResponse.fatLossMetabolismScore.clientInterpretation
          .toString(),
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: const Color(0xFF535359),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.30,
        letterSpacing: -0.24,
      ),
    );
  }
}



class MetabolismScale extends StatelessWidget {
  final double value;

  const MetabolismScale({super.key, required this.value});

  String getStatus(double v) {
    final clamped = v.clamp(0.0, 100.0);
    if (clamped <= 69.9) return "Poor";
    if (clamped <= 79.9) return "Fair";
    return "Good";
  }

  Color getStatusColor(double v) {
    final clamped = v.clamp(0.0, 100.0);
    if (clamped <= 69.9) return const Color(0xFFE48326);
    if (clamped <= 79.9) return const Color(0xFFFFBF2D);
    return const Color(0xFF3EAF58);
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 54;
    final double clampedValue = value.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8),
          child: Text(
            'Metabolism Scale',
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: -0.20,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double indicatorX =
                constraints.maxWidth * (clampedValue / 100.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 70,
                          child: Container(
                            height: barHeight,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE48326),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Container(
                            height: barHeight,
                            color: const Color(0xFFFFBF2D),
                          ),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(
                            height: barHeight,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3EAF58),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: indicatorX - 2.5,
                      top: 20,
                      bottom: 0,
                      child: Container(
                        width: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 14,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Align(
                        alignment: const Alignment(-1, 0),
                        child: Text(
                          '0',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment((2 * 0.70) - 1, 0),
                        child: Text(
                          '70',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment((2 * 0.80) - 1, 0),
                        child: Text(
                          '80',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(1, 0),
                        child: Text(
                          '100',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            height: 1.10,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}



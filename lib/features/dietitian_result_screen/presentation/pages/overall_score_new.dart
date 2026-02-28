import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';

import '../../../../core/size/get_height.dart';
import '../../../../routes/app_routes.dart';
import '../../../bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import '../../../bluetooth_device_connectivity/presentation/widgets/metabolism_scale.dart';

class OverallScoreNew extends StatefulWidget {
  final TestResultResponse testResultResponse;
  final ClientProfileModel clientProfileModel;

  const OverallScoreNew({
    super.key,
    required this.testResultResponse,
    required this.clientProfileModel,
  });

  @override
  State<OverallScoreNew> createState() => _OverallScoreNewState();
}

class _OverallScoreNewState extends State<OverallScoreNew> {
  @override
  void initState() {
    super.initState();
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '';

    try {
      final dt = DateTime.parse(dateTime);
      final local = dt.toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(local);
    } catch (_) {
      return dateTime;
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
          backgroundColor: const Color(0xFFF0F6FD),
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
                // ✅ Scroll content
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
                        RepaintBoundary(
                            child: _buildHeaderSection(isSmallScreen)),
                        RepaintBoundary(
                            child: _buildMainContentSection(screenSize)),
                      ],
                    ),
                  ),
                ),

                // ✅ Bottom CTA button
                Positioned(
                  bottom: rh(context: context, px: 12),
                  left: 0,
                  right: 0,
                  child: Visibility(
                      visible: false,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            context.push(
                              AppRoutes.overallResultScreen,
                              extra: ResultScreenParamsNew(
                                result: widget.testResultResponse,
                                clientProfileModel: widget.clientProfileModel,
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF308BF9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 50),
                              ),
                            ),
                            padding:
                                EdgeInsets.all(rh(context: context, px: 16)),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
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
            SizedBox(height: rh(context: context, px: 11)),
            Flexible(
              child: Text(
                formatDateTime(widget.testResultResponse.dateTime.toString()),
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
          "Fat-Use\nPattern Trend",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: isSmallScreen
                ? rh(context: context, px: 28)
                : rh(context: context, px: 34),
            fontWeight: FontWeight.w400,
            letterSpacing: -2.04,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentSection(Size screenSize) {
    final bool isSmallScreen = screenSize.width < 360;

    final double scoreFontSize = isSmallScreen
        ? rh(context: context, px: 80.0)
        : rh(context: context, px: 100.0);

    final double zoneFontSize = isSmallScreen
        ? rh(context: context, px: 20.0)
        : rh(context: context, px: 25.0);

    final dailyFocusTitle =
        widget.testResultResponse.respyrResponse.dayFocus?.title ?? "";
    final dailyFocusNote =
        widget.testResultResponse.respyrResponse.dayFocus?.note ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildScoreDisplay(scoreFontSize),
        _buildZoneText(zoneFontSize),
        SizedBox(height: rh(context: context, px: 48)),
        RepaintBoundary(
          child: MetabolismScale(
            value: widget.testResultResponse.fatLossMetabolismScore,
            // value: 100,
          ),
        ),
        SizedBox(height: rh(context: context, px: 37)),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: rh(context: context, px: 28),
          ),
          child: Column(
            spacing: rh(context: context, px: 15),
            children: [
              Text(
                widget.testResultResponse.respyrResponse.fatUsePatternTrend
                    .clientInterpretation.title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 20),
                  fontWeight: FontWeight.w600,
                  letterSpacing: rh(context: context, px: -1),
                ),
              ),
              Text(
                widget.testResultResponse.respyrResponse.fatUsePatternTrend
                    .clientInterpretation.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 12),
                  fontWeight: FontWeight.w400,
                  height: rh(context: context, px: 1.30),
                  letterSpacing: rh(context: context, px: -0.24),
                ),
              ),
            ],
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
          widget.testResultResponse.fatLossMetabolismScore.toStringAsFixed(0),
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
    final String isNeeds =
        widget.testResultResponse.respyrResponse.fatUsePatternTrend.zone ==
                "Focus"
            ? "Needs to"
            : "is";

    return RichText(
      text: TextSpan(
        text: "You're Trend $isNeeds ",
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: rh(context: context, px: 18),
          fontWeight: FontWeight.w600,
          letterSpacing: -0.72,
        ),
        children: [
          TextSpan(
            text: widget
                .testResultResponse.respyrResponse.fatUsePatternTrend.zone,
            style: GoogleFonts.poppins(
              color: getZoneColor(
                widget
                    .testResultResponse.respyrResponse.fatUsePatternTrend.zone,
              ),
              fontSize: rh(context: context, px: 18),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.72,
            ),
          ),
        ],
      ),
    );
  }
}

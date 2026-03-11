import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🚨 NEW IMPORT
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/metabolism_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/bloc/metabolism_event.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/data/repository/metabolism_score_repository.dart';

import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/pages/plan_for_today_screen.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/live_graph/models/graph_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/live_graph/widgets/progress_graph.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart'; // 🚨 NEW IMPORT

class ScoreChartScreen extends StatefulWidget {
  final Color domeColor;
  final TestResultResponse testResultResponse;
  final ClientProfileModel
      clientProfileModel; // 🚨 ADDED: Required for API history call

  const ScoreChartScreen({
    super.key,
    required this.domeColor,
    required this.testResultResponse,
    required this.clientProfileModel,
  });

  @override
  State<ScoreChartScreen> createState() => _ScoreChartScreenState();
}

class _ScoreChartScreenState extends State<ScoreChartScreen> {
  late final MetabolismBloc _metabolismBloc;

  @override
  void initState() {
    super.initState();

    // 🚨 Initialize the same Bloc used by the Qua Dashboard
    final repository = MetabolismRepository();
    _metabolismBloc = MetabolismBloc(repository);

    // Fetch historical data for this user
    _metabolismBloc.add(
      FetchMetabolismData(
        widget.clientProfileModel.dietitianId.toString(),
        widget.clientProfileModel.profileId.toString(),
      ),
    );
  }

  @override
  void dispose() {
    _metabolismBloc.close();
    super.dispose();
  }

  Color _getShadowColor(double currentScore) {
    final int strictScore = currentScore.toInt();
    if (strictScore < 70) return const Color(0xFFF8BB82);
    if (strictScore < 80) return const Color(0xFFFFEAB9);
    return const Color(0xFFE8FFED);
  }

  @override
  Widget build(BuildContext context) {
    final double liveScore = widget.testResultResponse.fatLossMetabolismScore;

    // SAFEGUARD RANGES
    double safeMinRange = widget.testResultResponse.minRange;
    double safeMaxRange = widget.testResultResponse.maxRange;

    if (safeMinRange > 0 && safeMinRange <= 1.0) safeMinRange *= 100;
    if (safeMaxRange > 0 && safeMaxRange <= 1.0) safeMaxRange *= 100;

    if (safeMinRange == 0 && safeMaxRange == 0) {
      safeMinRange = 60.0;
      safeMaxRange = 100.0;
    }

    final size = MediaQuery.of(context).size;
    final domeSize = size.width * 1.25;
    final shadowColor = _getShadowColor(liveScore);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. THE HERO DOME
          Positioned(
            top: -domeSize * 0.51,
            right: -domeSize * 0.51,
            child: Hero(
              tag: "Key",
              flightShuttleBuilder: (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final opacity = TweenSequence<double>([
                      TweenSequenceItem(
                          tween: Tween(begin: 1.0, end: 0.8), weight: 50),
                      TweenSequenceItem(
                          tween: Tween(begin: 0.8, end: 1.0), weight: 50),
                    ]).evaluate(animation);

                    return Opacity(
                      opacity: opacity,
                      child: toHeroContext.widget,
                    );
                  },
                );
              },
              child: CustomPaint(
                foregroundPainter:
                    _FigmaInnerShadowPainter(shadowColor: shadowColor),
                child: Container(
                  width: domeSize,
                  height: domeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.domeColor.withOpacity(0.6),
                        widget.domeColor
                      ],
                      stops: const [0.0, 0.2],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: Hero(
                      tag: "share_button",
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.share_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.14),

                  Text(
                    'Score Chart',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    widget.testResultResponse.respyrResponse.fatUsePatternTrend
                                .zone
                                .toLowerCase() ==
                            'focus'
                        ? 'You need to maintain score range!'
                        : 'Great! You are maintaining your score range!',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RECOMMENDED TREND RANGE',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.info,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${safeMinRange.toInt()}%-${safeMaxRange.toInt()}%',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. YOUR GRAPH (Live Data from Bloc)
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: BlocProvider.value(
                        value: _metabolismBloc,
                        child: BlocBuilder<MetabolismBloc, MetabolismState>(
                          builder: (context, state) {
                            if (state is MetabolismLoading) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF308BF9)));
                            }

                            if (state is MetabolismLoaded) {
                              // Get last 7 points, map to GraphModel
                              final history = state.scores.reversed.toList();
                              final displayData = history.length > 7
                                  ? history.sublist(history.length - 7)
                                  : history;

                              final List<GraphModel> myGraphData =
                                  displayData.map((e) {
                                return GraphModel(
                                    date: DateTime.parse(e.date),
                                    value: e.score.toDouble());
                              }).toList();

                              return ProgressGraph(
                                data: myGraphData,
                                minRange: safeMinRange,
                                maxRange: safeMaxRange,
                              );
                            }

                            return const Center(
                                child: Text("History not available"));
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  // 4. BOTTOM NAVIGATION
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF4A4A4A)),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 850),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        PlanForTodayScreen(
                                  domeColor: widget.domeColor,
                                  testResultResponse: widget.testResultResponse,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return Stack(
                                    children: [
                                      Container(color: Colors.white),
                                      FadeTransition(
                                        opacity: CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut),
                                        child: child,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF308BF9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaInnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  const _FigmaInnerShadowPainter({required this.shadowColor});
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.clipPath(Path()..addOval(rect));
    const double x = 12;
    const double y = -36;
    const double blur = 58.1;
    const double spread = -11;
    final double sigma = blur / 2.0;
    final Paint paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    final Rect holeRect = rect.translate(x, y).inflate(-spread);
    final Path shadowPath = Path()
      ..addRect(rect.inflate(blur * 2))
      ..addOval(holeRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(shadowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _FigmaInnerShadowPainter oldDelegate) =>
      oldDelegate.shadowColor != shadowColor;
}

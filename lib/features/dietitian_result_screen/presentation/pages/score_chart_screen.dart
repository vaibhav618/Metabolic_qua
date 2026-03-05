import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/live_graph/models/graph_model.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/live_graph/widgets/progress_graph.dart';

// IMPORTANT: Adjust these two import paths to match exactly where you saved your graph files!

class ScoreChartScreen extends StatelessWidget {
  final Color
      domeColor; // We pass the color so the Hero transition matches perfectly

  const ScoreChartScreen({super.key, required this.domeColor});

  @override
  Widget build(BuildContext context) {
    // YOUR DATA IS NOW HERE
    final List<GraphModel> myGraphData = [
      GraphModel(date: DateTime(2023, 8, 5), value: 65),
      GraphModel(date: DateTime(2023, 8, 6), value: 67),
      GraphModel(date: DateTime(2023, 8, 7), value: 90),
      GraphModel(date: DateTime(2023, 8, 8), value: 88),
      GraphModel(date: DateTime(2023, 8, 9), value: 77),
      GraphModel(date: DateTime(2023, 8, 10), value: 95),
    ];

    final size = MediaQuery.of(context).size;

    // We make this dome slightly larger so it creates that nice gentle curve
    // when pushed into the top right corner.
    final domeSize = size.width * 1.25;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. THE HERO DOME (Top Right)
          Positioned(
            top: -domeSize * 0.51, // Pushes it up off the screen
            right: -domeSize * 0.51, // Pushes it right off the screen
            child: Hero(
              tag: "Key", // MUST match the tag from the previous screen
              // =========================================================
              // CUSTOM FLIGHT SHUTTLE FOR OPACITY EFFECT
              // =========================================================
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
                    // This dips the opacity down to 30% in the middle of the flight.
                    // It creates the illusion that the dome is sinking deep into the
                    // background (behind the text) before landing in the corner!
                    final opacity = TweenSequence<double>([
                      TweenSequenceItem(
                        tween: Tween(begin: 1.0, end: 0.8),
                        weight: 50,
                      ),
                      TweenSequenceItem(
                        tween: Tween(begin: 0.8, end: 1.0),
                        weight: 50,
                      ),
                    ]).evaluate(animation);

                    return Opacity(
                      opacity: opacity,
                      child: toHeroContext.widget,
                    );
                  },
                );
              },

              // =========================================================
              child: Container(
                width: domeSize,
                height: domeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [domeColor.withOpacity(0.6), domeColor],
                    stops: const [0.0, 0.2],
                  ),
                ),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: Padding(
              // Applied global padding so everything aligns perfectly on the edges
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row (Share Button)
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
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
                        onPressed: () {
                          // Share action
                        },
                      ),
                    ),
                  ),

                  // CHANGED: Massively increased this spacing to push the text down to ~40% of the screen
                  SizedBox(height: size.height * 0.14),

                  // Text Content
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
                    'You need to maintain score range!',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Recommended Trend Range Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0), // Light grey background
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
                          '60%-100%',
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

                  // 3. YOUR GRAPH GOES HERE
                  // Expanded automatically takes up all remaining screen height without overflowing
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ProgressGraph(
                        data: myGraphData, // PASSED YOUR DATA HERE
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
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle next action
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF308BF9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
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

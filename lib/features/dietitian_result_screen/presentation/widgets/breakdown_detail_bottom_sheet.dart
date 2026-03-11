import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';

class BreakdownDetailBottomSheet extends StatefulWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String markerName;
  final String markerValue;
  final List<Map<String, dynamic>> subScores; // Passing title & trend data

  const BreakdownDetailBottomSheet({
    super.key,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.markerName,
    required this.markerValue,
    required this.subScores,
  });

  @override
  State<BreakdownDetailBottomSheet> createState() =>
      _BreakdownDetailBottomSheetState();
}

class _BreakdownDetailBottomSheetState
    extends State<BreakdownDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.9, // Takes up 90% of screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Main Scrollable Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 30),
                Text(
                  'Score Breakdown',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  widget.status,
                  style: GoogleFonts.poppins(
                    color: widget.statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Breath Marker Container
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF7F7F7),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'BREATH MARKER',
                //         style: GoogleFonts.poppins(
                //           color: const Color(0xFF666666),
                //           fontSize: 10,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.end,
                //         children: [
                //           Text(
                //             widget.markerName,
                //             style: GoogleFonts.poppins(
                //               color: const Color(0xFF666666),
                //               fontSize: 10,
                //             ),
                //           ),
                //           Text(
                //             widget.markerValue,
                //             style: GoogleFonts.poppins(
                //               color: const Color(0xFF252525),
                //               fontSize: 16,
                //               fontWeight: FontWeight.w600,
                //             ),
                //           ),
                //         ],
                //       )
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 20),

                // Expandable Sub-Scores
                ...widget.subScores.map((scoreData) {
                  final String subTitle = scoreData['title'];
                  final TrendDetail trend = scoreData['trend'];
                  return _SubScoreAccordion(
                    title: subTitle,
                    trend: trend,
                    statusColor: widget.statusColor,
                  );
                }).toList(),

                const SizedBox(height: 100), // Padding for the close button
              ],
            ),
          ),

          // Floating Close Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF252525),
                elevation: 0,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACCORDION WIDGET
// ============================================================================
class _SubScoreAccordion extends StatefulWidget {
  final String title;
  final TrendDetail trend;
  final Color statusColor;

  const _SubScoreAccordion({
    required this.title,
    required this.trend,
    required this.statusColor,
  });

  @override
  State<_SubScoreAccordion> createState() => _SubScoreAccordionState();
}

class _SubScoreAccordionState extends State<_SubScoreAccordion> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            onExpansionChanged: (expanded) =>
                setState(() => isExpanded = expanded),
            title: Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF252525),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trend
                          .whatIsThisScore, // Dynamic description from API
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF666666),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Big Score
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          widget.trend.score.toInt().toString().padLeft(2, '0'),
                          style: GoogleFonts.poppins(
                            fontSize: 70,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF252525),
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '%',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252525),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Segmented Bar Chart Mock
                    _ScoreBar(
                        score: widget.trend.score, color: widget.statusColor),

                    const SizedBox(height: 15),
                    Text(
                      'What are the different score ranges?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF308BF9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Score Meaning
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'SCORE MEANING',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF666666),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget
                                .trend.clientState, // Dynamic meaning from API
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Score Chart Placeholder (You will plug your graph here later)
                    Text(
                      'SCORE CHART',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF666666),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                          child: Text("Graph Component Goes Here")),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
      ],
    );
  }
}

// Custom widget to draw the segmented lines
class _ScoreBar extends StatelessWidget {
  final double score;
  final Color color;

  const _ScoreBar({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    int totalBars = 50;
    int filledBars = (score / 100 * totalBars).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('60', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('80', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('100', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalBars, (index) {
            return Container(
              width: 4,
              height: 25,
              decoration: BoxDecoration(
                color: index < filledBars ? color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Text(
          score >= 80
              ? 'Good'
              : score >= 60
                  ? 'Fair'
                  : 'Poor',
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

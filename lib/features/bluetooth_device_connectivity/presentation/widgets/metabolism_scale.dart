import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MetabolismScale extends StatelessWidget {
  final double value;

  const MetabolismScale({super.key, required this.value});

  double _indicatorX(double width, double v) {
    final val = v.clamp(0.0, 100.0);

    const seg = 1 / 3;

    if (val <= 69.9) {
      final t = val / 69.9;
      return width * (t * seg);
    }

    if (val <= 79.9) {
      final t = (val - 70.0) / (79.9 - 70.0);
      return width * (seg + (t * seg));
    }

    final t = (val - 80.0) / (100.0 - 80.0);
    return width * ((2 * seg) + (t * seg));
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 54;

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
            final double indicatorX = _indicatorX(constraints.maxWidth, value);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Row(
                        children: [
                          Expanded(
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
                            child: Container(
                              height: barHeight,
                              color: const Color(0xFFFFBF2D),
                            ),
                          ),
                          Expanded(
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
                        alignment: const Alignment(-1 + (2 * (1 / 3)), 0),
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
                        alignment: const Alignment(-1 + (2 * (2 / 3)), 0),
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

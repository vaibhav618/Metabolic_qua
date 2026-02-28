import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExactProgressBar extends StatelessWidget {
  /// Overall achieved delta in kg (ex: 1.3 kg lost or gained)
  final double currentValueKg;

  /// Range start (previous badge requirement, ex: 1.0)
  final double rangeStartKg;

  /// Range end (next badge requirement, ex: 2.0)
  final double rangeEndKg;

  final double height;
  final bool showValueText;

  const ExactProgressBar({
    super.key,
    required this.currentValueKg,
    required this.rangeStartKg,
    required this.rangeEndKg,
    this.height = 10,
    this.showValueText = false,
  });

  String _fmtKg(double v) {
    final bool isInt = (v % 1) == 0;
    return isInt ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final double start = rangeStartKg.clamp(0, double.infinity);
    final double end = math.max(rangeEndKg, start + 0.0001); // avoid 0 span
    final double cur = currentValueKg.clamp(0, double.infinity);

    final double p = ((cur - start) / (end - start)).clamp(0.0, 1.0);

    return Column(
      children: [
        if (showValueText) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${_fmtKg(cur)} / ${_fmtKg(end)} kg",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.20,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                // Track
                Container(color: const Color(0xFFD9D9D9)),

                // Progress
                LayoutBuilder(
                  builder: (context, c) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: c.maxWidth * p,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 2),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF2F86FF),
                            Color(0xFF1F6FE5),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Inner highlight + shade
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55, 1.0],
                          colors: [
                            Colors.white.withOpacity(0.55),
                            Colors.transparent,
                            Colors.black.withOpacity(0.18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Glossy right edge
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: math.max(6, height * 0.55),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.00),
                            Colors.white.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_fmtKg(start)}kg",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.20,
              ),
            ),
            Text(
              "${_fmtKg(end)}kg",
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

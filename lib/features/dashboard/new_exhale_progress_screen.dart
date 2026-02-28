import 'dart:math';
import 'package:flutter/material.dart';

enum BreathMode { inhale, exhale }

class ExhaleProgressRing extends StatelessWidget {
  /// inhale: 0 -> -100 (0, -10, -50, -100)
  /// exhale: 0 -> 100  (0, 10, 50, 100)
  final double progress;

  /// threshold still 0.0 -> 1.0
  final double threshold;

  final BreathMode mode; // inhale=grow, exhale=shrink

  final double size;
  final double ringStroke;
  final double minDotSize;
  final double thresholdRingSize;
  final double thresholdRingStroke;
  final Duration duration;
  final Curve curve;

  final Color ringColor;
  final Color backgroundColor;
  final Color progressColor;
  final Color thresholdMetColor;
  final Color thresholdNotMetColor;

  final double dashLength;
  final double dashGap;


  const ExhaleProgressRing({
    super.key,
    required this.progress,
    this.threshold = 0.6,
    this.mode = BreathMode.inhale,
    this.size = 254,
    this.ringStroke = 5,
    this.minDotSize = 20,
    this.thresholdRingSize = 127,
    this.thresholdRingStroke = 3,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOutCubic,
    this.ringColor = const Color(0xFFE1E6ED),
    this.backgroundColor = const Color(0xFFF5F7FA),
    this.progressColor = const Color(0xFF3A8DFF),
    this.thresholdMetColor = const Color(0xFF3EAF58),
    this.thresholdNotMetColor = const Color(0xFFBFE6C7),
    this.dashLength = 10,
    this.dashGap = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Convert incoming progress to 0..100 value
    final double raw0to100 =
    (mode == BreathMode.inhale) ? progress.abs() : progress;

    final double clamped0to100 = raw0to100.clamp(0.0, 100.0);

    // normalize 0..100 -> 0..1
    final double p = (clamped0to100 / 100).clamp(0.0, 1.0);

    // Dot sizing
    final double maxDotSize = size - (ringStroke * 2) - 2;

    // inhale: grow (min -> max)
    // exhale: shrink (max -> min)
    final double effectiveProgress =
    (mode == BreathMode.inhale) ? p : (1.0 - p);

    final double dotSize =
        minDotSize + (maxDotSize - minDotSize) * effectiveProgress;

    final Color thresholdColor =
    p >= threshold ? thresholdMetColor : thresholdNotMetColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dotted ring
          CustomPaint(
            size: Size(size, size),
            painter: DottedCirclePainter(
              color: ringColor,
              strokeWidth: ringStroke,
              dashLength: dashLength,
              dashGap: dashGap,
            ),
          ),

          // Background fill
          Container(
            width: size - (ringStroke * 2),
            height: size - (ringStroke * 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
          ),

          // Threshold ring: ✅ visible only for EXHALE
          Visibility(
            visible:  mode == BreathMode.exhale,
            child: Container(
              width: thresholdRingSize,
              height: thresholdRingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: thresholdColor,
                  width: thresholdRingStroke,
                ),
              ),
            ),
          ),

          // Progress bubble
          AnimatedContainer(
            duration: duration,
            curve: curve,
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(0.50, -0.00),
                end: Alignment(0.50, 1.00),
                colors: [Color(0xFF308BF9), Color(0xFF8EC1FF)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  DottedCirclePainter({
    required this.color,
    this.strokeWidth = 6,
    this.dashLength = 10,
    this.dashGap = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final circumference = 2 * pi * radius;
    final step = dashLength + dashGap;
    final count = (circumference / step).floor();

    for (int i = 0; i < count; i++) {
      final startAngle = (i * step) / radius - pi / 2;
      final sweepAngle = dashLength / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DottedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap;
  }
}

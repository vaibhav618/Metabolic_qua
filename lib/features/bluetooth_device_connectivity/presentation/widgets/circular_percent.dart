import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularPercent extends StatelessWidget {
  final double percent; // 0..100
  final double size; // diameter
  final double stroke; // ring thickness
  final Color color;
  final Color bgColor;
  final Widget? child;

  const CircularPercent({
    super.key,
    required this.percent,
    this.size = 120,
    this.stroke = 10,
    this.color = Colors.blue,
    this.bgColor = const Color(0xFFE6E6E6),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 🚨 THE FIX: Removed TweenAnimationBuilder.
    // Now it instantly draws the exact percentage the parent gives it!
    final double target = percent.clamp(0.0, 100.0);
    final value = target / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CirclePainter(
          value: value,
          color: color,
          bg: bgColor,
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color bg;
  final double stroke;

  _CirclePainter({
    required this.value,
    required this.color,
    required this.bg,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final trackPaint = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.bg != bg ||
        oldDelegate.stroke != stroke;
  }
}

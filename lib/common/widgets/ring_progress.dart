import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Drop this whole file into your project (e.g., ring_progress.dart),
/// then see the example usage at the bottom.

class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.progress,        // 0.0 - 1.0
    this.size = 120,
    this.strokeWidth = 12,
    this.startAngle = -90,         // degrees; -90 = top
    this.clockwise = true,
    this.roundCaps = true,
    this.trackColor = const Color(0xFFE5E7EB), // light grey
    this.progressColor = const Color(0xFFFF9900),
    this.progressGradient,         // optional SweepGradient
    this.backgroundColor,          // optional inner fill
    this.shadow,                   // optional drop shadow
    this.center,                   // optional center widget (icon, text, etc.)
    this.gapDegrees = 0,           // optional fixed gap in the ring (0 = full ring)
  });

  /// Progress 0..1
  final double progress;

  /// Widget size (width & height)
  final double size;

  /// Ring thickness
  final double strokeWidth;

  /// Where the arc begins (in degrees)
  final double startAngle;

  /// Direction of sweep
  final bool clockwise;

  /// Rounded arc ends
  final bool roundCaps;

  /// Ring remainder color
  final Color trackColor;

  /// Solid color for progress (ignored if [progressGradient] is given)
  final Color progressColor;

  /// Optional sweep gradient for the progress arc
  final SweepGradient? progressGradient;

  /// Optional inner background
  final Color? backgroundColor;

  /// Optional shadow under the arc
  final List<BoxShadow>? shadow;

  /// Center content (e.g., Icon or Text)
  final Widget? center;

  /// Optional permanent gap in the ring, in degrees (e.g., 30 for a donut with a gap)
  final double gapDegrees;

  @override
  Widget build(BuildContext context) {
    // Container to allow optional shadow + background
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: shadow,
      ),
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          startAngle: startAngle,
          clockwise: clockwise,
          roundCaps: roundCaps,
          trackColor: trackColor,
          progressColor: progressColor,
          progressGradient: progressGradient,
          gapDegrees: gapDegrees,
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startAngle,
    required this.clockwise,
    required this.roundCaps,
    required this.trackColor,
    required this.progressColor,
    required this.progressGradient,
    required this.gapDegrees,
  });

  final double progress;
  final double strokeWidth;
  final double startAngle;
  final bool clockwise;
  final bool roundCaps;
  final Color trackColor;
  final Color progressColor;
  final SweepGradient? progressGradient;
  final double gapDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Prepare angles
    final startRad = _deg2rad(startAngle);
    final totalSweep = _deg2rad(360 - gapDegrees.clamp(0, 359.999));
    final sweepDirection = clockwise ? 1.0 : -1.0;
    final progressSweep = totalSweep * progress * sweepDirection;

    // Base track (remainder)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundCaps ? StrokeCap.round : StrokeCap.butt
      ..color = trackColor;

    // Draw track as the visible ring path (with the fixed gap if any)
    final trackStart = startRad;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      trackStart,
      totalSweep,
      false,
      trackPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundCaps ? StrokeCap.round : StrokeCap.butt
      ..color = progressColor;

    // Apply sweep gradient if provided
    if (progressGradient != null) {
      final shader = SweepGradient(
        colors: progressGradient!.colors,
        stops: progressGradient!.stops,
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(startRad),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      progressPaint.shader = shader;
    }

    // Draw progress over the track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.progress != progress ||
        old.strokeWidth != strokeWidth ||
        old.startAngle != startAngle ||
        old.clockwise != clockwise ||
        old.roundCaps != roundCaps ||
        old.trackColor != trackColor ||
        old.progressColor != progressColor ||
        old.progressGradient != progressGradient ||
        old.gapDegrees != gapDegrees;
  }

  double _deg2rad(double d) => d * math.pi / 180.0;
}

/// Convenience wrapper with smooth animation on progress changes.
class AnimatedRingProgress extends StatelessWidget {
  const AnimatedRingProgress({
    super.key,
    required this.progress,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    // pass through props
    this.size = 120,
    this.strokeWidth = 12,
    this.startAngle = -90,
    this.clockwise = true,
    this.roundCaps = true,
    this.trackColor = const Color(0xFFE5E7EB),
    this.progressColor = const Color(0xFFFF9900),
    this.progressGradient,
    this.backgroundColor,
    this.shadow,
    this.center,
    this.gapDegrees = 0,
  });

  final double progress;
  final Duration duration;
  final Curve curve;

  final double size;
  final double strokeWidth;
  final double startAngle;
  final bool clockwise;
  final bool roundCaps;
  final Color trackColor;
  final Color progressColor;
  final SweepGradient? progressGradient;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;
  final Widget? center;
  final double gapDegrees;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: duration,
      curve: curve,
      builder: (_, value, __) {
        return RingProgress(
          progress: value,
          size: size,
          strokeWidth: strokeWidth,
          startAngle: startAngle,
          clockwise: clockwise,
          roundCaps: roundCaps,
          trackColor: trackColor,
          progressColor: progressColor,
          progressGradient: progressGradient,
          backgroundColor: backgroundColor,
          shadow: shadow,
          center: center,
          gapDegrees: gapDegrees,
        );
      },
    );
  }
}

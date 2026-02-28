import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A highly-customizable circular percentage indicator.
/// - [percent] takes 0..100 (clamped).
/// - Supports gradient progress, rounded caps, start angle, clockwise, glow, etc.
class CircularPercent extends StatefulWidget {
  /// 0..100
  final double percent;

  /// Diameter of the circle.
  final double size;

  /// Thickness of the progress ring.
  final double stroke;

  /// Background track thickness (defaults to [stroke]).
  final double? backgroundStroke;

  /// Solid color for progress if [gradient] is null.
  final Color color;

  /// Gradient for progress arc (overrides [color] when set).
  final Gradient? gradient;

  /// Background track color.
  final Color trackColor;

  /// Start angle in degrees (0° is at 3 o’clock; default -90° = 12 o’clock).
  final double startAngle;

  /// Draw progress clockwise (default) or counter-clockwise.
  final bool clockwise;

  /// Rounded arc ends?
  final bool roundedCaps;

  /// Optional glow around the progress arc.
  final bool glow;
  final double glowBlurSigma;

  /// Center content. If null and [showPercentText]=true, it shows % text.
  final Widget? center;

  /// Show default percent text in center (ignored if [center] is not null).
  final bool showPercentText;

  /// Text style for percent text.
  final TextStyle? textStyle;

  /// Prefix/Suffix around percent text (e.g., '', '%', 'pts').
  final String prefix;
  final String suffix;

  /// Number of decimal places in percent text.
  final int decimals;

  /// Animate changes?
  final bool animate;

  /// Animate from last value (keeps state).
  final bool animateFromLast;

  /// Animation config.
  final Duration duration;
  final Curve curve;

  final Widget child;

  const CircularPercent({
    super.key,
    required this.percent,
    this.size = 120,
    this.stroke = 10,
    this.backgroundStroke,
    this.color = Colors.blue,
    this.gradient,
    this.trackColor = const Color(0xFFE6E6E6),
    this.startAngle = -90, // top
    this.clockwise = true,
    this.roundedCaps = true,
    this.glow = false,
    this.glowBlurSigma = 2.0,
    this.center,
    this.showPercentText = true,
    this.textStyle,
    this.prefix = '',
    this.suffix = '%',
    this.decimals = 0,
    this.animate = true,
    this.animateFromLast = true,
    this.duration = const Duration(milliseconds: 1600),
    this.curve = Curves.easeOutCubic,
    this.child  = const SizedBox.shrink(),
  });

  @override
  State<CircularPercent> createState() => _CircularPercentState();
}

class _CircularPercentState extends State<CircularPercent>
    with SingleTickerProviderStateMixin {
  late double _last; // 0..1
  late AnimationController _ctrl;
  late Animation<double> _anim;

  double get _clamped => (widget.percent.clamp(0, 100)) / 100;

  @override
  void initState() {
    super.initState();
    _last = _clamped;
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant CircularPercent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _clamped;
    if (widget.animate) {
      final begin = widget.animateFromLast ? _last : 0.0;
      _ctrl.duration = widget.duration;
      _anim = Tween<double>(begin: begin, end: target)
          .animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));
      _ctrl.forward(from: 0);
    } else {
      _anim = AlwaysStoppedAnimation(target);
    }
    _last = target;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgStroke = widget.backgroundStroke ?? widget.stroke;

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final value = widget.animate ? _anim.value : _clamped;

          return CustomPaint(
            painter: _CirclePainter(
              value: value,
              stroke: widget.stroke,
              backgroundStroke: bgStroke,
              color: widget.color,
              gradient: widget.gradient,
              trackColor: widget.trackColor,
              startAngleDeg: widget.startAngle,
              clockwise: widget.clockwise,
              roundedCaps: widget.roundedCaps,
              glow: widget.glow,
              glowBlurSigma: widget.glowBlurSigma,
            ),
            child: Center(
              child: widget.child ),
         
          );
        },
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double value; // 0..1
  final double stroke;
  final double backgroundStroke;
  final Color color;
  final Gradient? gradient;
  final Color trackColor;
  final double startAngleDeg;
  final bool clockwise;
  final bool roundedCaps;
  final bool glow;
  final double glowBlurSigma;

  _CirclePainter({
    required this.value,
    required this.stroke,
    required this.backgroundStroke,
    required this.color,
    required this.gradient,
    required this.trackColor,
    required this.startAngleDeg,
    required this.clockwise,
    required this.roundedCaps,
    required this.glow,
    required this.glowBlurSigma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - stroke / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = backgroundStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final startRad = _deg2rad(startAngleDeg);
    final sweep = (clockwise ? 1 : -1) * (2 * math.pi * value);

    final progRect = Rect.fromCircle(center: center, radius: radius);
    final progPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt;

    if (gradient != null) {
      progPaint.shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: _effectiveColors(gradient!),
        stops: _effectiveStops(gradient!),
        transform: GradientRotation(startRad),
      ).createShader(progRect);
    } else {
      progPaint.color = color;
    }

    if (glow) {
      progPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurSigma);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweep,
      false,
      progPaint,
    );
  }

  double _deg2rad(double d) => d * math.pi / 180.0;

  List<Color> _effectiveColors(Gradient g) {
    if (g is LinearGradient) return g.colors;
    if (g is RadialGradient) return g.colors;
    if (g is SweepGradient) return g.colors;
    return [color, color];
  }

  List<double>? _effectiveStops(Gradient g) {
    if (g is LinearGradient) return g.stops;
    if (g is RadialGradient) return g.stops;
    if (g is SweepGradient) return g.stops;
    return null;
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) {
    return old.value != value ||
        old.stroke != stroke ||
        old.backgroundStroke != backgroundStroke ||
        old.color != color ||
        old.gradient != gradient ||
        old.trackColor != trackColor ||
        old.startAngleDeg != startAngleDeg ||
        old.clockwise != clockwise ||
        old.roundedCaps != roundedCaps ||
        old.glow != glow ||
        old.glowBlurSigma != glowBlurSigma;
  }
}

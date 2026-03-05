import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArcRuler extends StatefulWidget {
  final double value; // 0..100
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  final Duration thumbAnimationDuration;
  final Curve thumbAnimationCurve;

  const ArcRuler({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.thumbAnimationDuration = const Duration(milliseconds: 600),
    this.thumbAnimationCurve = Curves.easeOutCubic,
  });

  @override
  State<ArcRuler> createState() => _ArcRulerState();
}

class _ArcRulerState extends State<ArcRuler>
    with SingleTickerProviderStateMixin {
  final double startAngle = 135;
  final double endAngle = 45;

  late AnimationController _controller;
  late Animation<double> _anim;
  double _shownValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          vsync: this,
          duration: widget.thumbAnimationDuration,
        )..addListener(() {
          setState(() => _shownValue = _anim.value);
        });

    _anim = AlwaysStoppedAnimation(widget.min);
    _animateFromZero(widget.value);
  }

  @override
  void didUpdateWidget(covariant ArcRuler oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.thumbAnimationDuration != widget.thumbAnimationDuration) {
      _controller.duration = widget.thumbAnimationDuration;
    }

    if (oldWidget.value != widget.value) {
      _animateFromZero(widget.value);
    }
  }

  void _animateFromZero(double target) {
    _controller.stop();
    _controller.reset();

    _anim =
        Tween<double>(
          begin: widget.min,
          end: target.clamp(widget.min, widget.max).toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.thumbAnimationCurve,
          ),
        );

    _controller.forward();
  }

  double _normalize(double deg) {
    deg %= 360;
    if (deg < 0) deg += 360;
    return deg;
  }

  double _valueFromTouch(Offset pos, Size size) {
    final w = size.width;

    final halfSpanDeg = (startAngle - endAngle).abs() / 2;
    final radius = (w / 2) / math.cos(halfSpanDeg * math.pi / 180);
    final y = radius * math.sin(halfSpanDeg * math.pi / 180);
    final center = Offset(w / 2, y);

    final dx = pos.dx - center.dx;
    final dy = center.dy - pos.dy;

    final touchDeg = _normalize(math.atan2(dy, dx) * 180 / math.pi);

    final spanDeg = endAngle - startAngle;
    double rel = touchDeg - startAngle;
    if (startAngle > endAngle && touchDeg > startAngle) rel -= 360;

    final ratio = (rel / spanDeg).clamp(0.0, 1.0);
    return widget.min + ratio * (widget.max - widget.min);
  }

  void _handlePan(Offset pos, Size size) {
    widget.onChanged(_valueFromTouch(pos, size));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final screenWidth = MediaQuery.of(context).size.width;

        const double baseScreenWidth = 375.0;
        const double baseCircleSize = 870.46;

        final double scaleFactor =
            baseCircleSize / baseScreenWidth; // 2.321226666...

        final double width = screenWidth * scaleFactor;
        final double height = width;

        return SizedBox(
          width: double.infinity,
          height: height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _handlePan(d.localPosition, Size(width, height)),
            onPanUpdate: (d) =>
                _handlePan(d.localPosition, Size(width, height)),
            child: CustomPaint(
              size: Size(width, height),
              painter: _ArcRulerPainter(
                value: _shownValue,
                min: widget.min,
                max: widget.max,
                startAngle: startAngle,
                endAngle: endAngle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArcRulerPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final double startAngle;
  final double endAngle;

  _ArcRulerPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.startAngle,
    required this.endAngle,
  });

  double _rad(double d) => d * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final spanDeg = endAngle - startAngle;
    final halfSpanDeg = (startAngle - endAngle).abs() / 2;

    final radius = (w / 2) / math.cos(_rad(halfSpanDeg));
    final y = radius * math.sin(_rad(halfSpanDeg));
    final center = Offset(w / 2, y);

    // ===== TICKS =====
    const int tickCount = 50; // CHANGED: Reduced from 100 to increase spacing
    const double tickLen = 4.0; // CHANGED: Reduced from 7 to make lines shorter

    final tickPaint = Paint()
      ..color = const Color(0xFFE1E6ED)
      ..strokeWidth =
          2.0 // CHANGED: Slightly thinner to match the new shorter height
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true;

    for (int i = 0; i <= tickCount; i++) {
      final t = i / tickCount;
      final a = startAngle + t * spanDeg;
      final r = _rad(a);

      final p1 = Offset(
        center.dx + radius * math.cos(r),
        center.dy - radius * math.sin(r),
      );

      final p2 = Offset(
        center.dx + (radius - tickLen) * math.cos(r),
        center.dy - (radius - tickLen) * math.sin(r),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }

    // ===== LABELS =====
    final labelStyle = GoogleFonts.inter(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final labelR = radius - 25;

    for (int i = 0; i <= 100; i += 10) {
      final t = i / 100;
      final a = startAngle + t * spanDeg;
      final r = _rad(a);

      final pos = Offset(
        center.dx + labelR * math.cos(r),
        center.dy - labelR * math.sin(r),
      );

      final tp = TextPainter(
        text: TextSpan(text: i.toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-r + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // ===== THUMB =====
    final ratio = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final thumbAngle = startAngle + ratio * spanDeg;
    final tr = _rad(thumbAngle);

    final thumbR = radius - (tickLen / 2);
    final thumbPos = Offset(
      center.dx + thumbR * math.cos(tr),
      center.dy - thumbR * math.sin(tr),
    );

    const double thumbRadius = 12;

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: thumbPos, radius: thumbRadius)),
      Colors.black.withOpacity(0.25),
      4,
      true,
    );

    final thumbPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(0.50, -0.00),
        end: Alignment(0.50, 1.00),
        colors: [Color(0xFF252525), Color(0xFF535359)],
      ).createShader(Rect.fromCircle(center: thumbPos, radius: thumbRadius));

    canvas.drawCircle(thumbPos, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcRulerPainter old) {
    return old.value != value;
  }
}

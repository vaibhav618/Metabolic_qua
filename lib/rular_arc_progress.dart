import 'dart:math' as math;
import 'package:flutter/material.dart';

class _RulerPainter extends CustomPainter {
  final double value;
  _RulerPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 🔑 Geometry tuned so endpoints stay inside canvas
    final center = Offset(w / 2, h * 1.65);
    final radius = w * 0.68;

    final startAngle = _deg(205);
    final endAngle   = _deg(-25);
    final sweep = _positiveSweep(startAngle, endAngle);

    final minorPaint = Paint()
      ..color = const Color(0xFFD7DCE3)
      ..strokeWidth = 4;

    final majorPaint = Paint()
      ..color = const Color(0xFFBFC6CF)
      ..strokeWidth = 4;

    const labelStyle = TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w400,
    );

    /// -------- ARC TICKS --------
    for (int i = 0; i <= 100; i++) {
      final t = i / 100;
      final a = startAngle + sweep * t;

      final isMajor = i % 10 == 0;
      final outer = _pt(center, radius, a);
      final inner = _pt(center, radius - (isMajor ? 10 : 6), a);

      canvas.drawLine(
        outer,
        inner,
        isMajor ? majorPaint : minorPaint,
      );
    }

    /// -------- LABELS (0–100 FULLY VISIBLE) --------
    for (int n = 0; n <= 100; n += 10) {
      final t = n / 100;
      final a = startAngle + sweep * t;
      final rawPos = _pt(center, radius - 44, a);

      _drawTextClamped(canvas, "$n", rawPos, size, labelStyle);
    }

    /// -------- KNOB --------
    final vt = value / 100;
    final va = startAngle + sweep * vt;
    final knobPos = _pt(center, radius - 2, va);
    canvas.drawCircle(knobPos, 12, Paint()..color = Colors.black);
  }

  /// ---- helpers ----
  static double _deg(double d) => d * math.pi / 180;

  static double _positiveSweep(double s, double e) =>
      e > s ? e - s : (math.pi * 2) - (s - e);

  static Offset _pt(Offset c, double r, double a) =>
      Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));

  /// ✅ prevents 0 / 100 clipping
  static void _drawTextClamped(
      Canvas canvas,
      String text,
      Offset pos,
      Size size,
      TextStyle style,
      ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    double x = pos.dx - tp.width / 2;
    double y = pos.dy - tp.height / 2;

    // clamp horizontally
    x = x.clamp(2.0, size.width - tp.width - 2);

    // clamp vertically
    y = y.clamp(2.0, size.height - tp.height - 2);

    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RulerScaleArc extends StatelessWidget {
  final double value;

  const RulerScaleArc({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100, // ✅ enough height for 0 & 100
      child: CustomPaint(
        painter: _RulerPainter(value.clamp(0, 100)),
      ),
    );
  }
}

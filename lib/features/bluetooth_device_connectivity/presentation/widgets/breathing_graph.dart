import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BreathingTargetGraph extends StatefulWidget {
  // ✅ changed: listenable reading
  final ValueListenable<double> reading;

  final double targetMin;
  final double targetMax;
  final double min;
  final double max;
  final double height;

  final bool hold;
  final int holdCounter;

  const BreathingTargetGraph({
    super.key,
    required this.reading,
    this.targetMin = 60,
    this.targetMax = 70,
    this.min = 0,
    this.max = 100,
    required this.height,
    this.hold = false,
    this.holdCounter = 0,
  });

  @override
  State<BreathingTargetGraph> createState() => _BreathingTargetGraphState();
}

class _BreathingTargetGraphState extends State<BreathingTargetGraph> {
  static const double _ratio = 136 / 452;
  double get _dynamicWidth => widget.height * _ratio;

  bool _isInSuccessZone(double val) =>
      val >= widget.targetMin && val <= widget.targetMax;

  @override
  Widget build(BuildContext context) {
    final double targetWidth = widget.hold ? 136 : _dynamicWidth;
    final double targetHeight = widget.hold ? 166 : widget.height;
    final double targetRadius = targetWidth / 2;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutBack,
        width: targetWidth,
        height: targetHeight,
        decoration: ShapeDecoration(
          color: const Color(0xFFF5F7FA),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 3,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: Color(0xFFE1E6ED),
            ),
            borderRadius: BorderRadius.circular(targetRadius),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: widget.hold ? _buildCounterView() : _buildGraphView(),
        ),
      ),
    );
  }

  Widget _buildCounterView() {
    return Center(
      key: const ValueKey("counter_view"),
      child: Text(
        "${widget.holdCounter}",
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1D1B20),
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildGraphView() {
    return CustomPaint(
      key: const ValueKey("graph_view"),
      size: Size(_dynamicWidth, widget.height),

      // ✅ repaint is driven by reading notifier (no rebuild needed)
      painter: _GraphPainter(
        repaint: widget.reading,
        min: widget.min,
        max: widget.max,
        targetMin: widget.targetMin,
        targetMax: widget.targetMax,
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final double min, max, targetMin, targetMax;
  final ValueListenable<double> repaint;

  _GraphPainter({
    required this.repaint,
    required this.min,
    required this.max,
    required this.targetMin,
    required this.targetMax,
  }) : super(repaint: repaint);

  bool _isInSuccessZone(double val) => val >= targetMin && val <= targetMax;

  @override
  void paint(Canvas canvas, Size size) {
    final value = repaint.value;
    final isInRange = _isInSuccessZone(value);

    _drawTargetMarkers(canvas, size, targetMin);
    _drawTargetMarkers(canvas, size, targetMax);
    _drawBall(canvas, size, value, isInRange);
  }

  void _drawTargetMarkers(Canvas canvas, Size size, double markerValue) {
    final double ballRadius = size.width * 0.22;
    final double innerPadding = size.width * 0.12;
    final double minY = innerPadding + ballRadius;
    final double maxY = size.height - innerPadding - ballRadius;
    final double travelHeight = maxY - minY;

    final double normalizedVal = (markerValue - min) / (max - min);
    final double yPos = maxY - (normalizedVal * travelHeight);

    final Paint paint = Paint()..color = const Color(0xFFE1E6ED);

    double dash = 10, gap = 16, start = -10;
    while (start < size.width + 10) {
      canvas.drawLine(
        Offset(start, yPos),
        Offset(start + dash, yPos),
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      start += dash + gap;
    }

    final Path leftArrow = Path()
      ..moveTo(-5, yPos)
      ..lineTo(-20, yPos - 10)
      ..lineTo(-20, yPos + 10)
      ..close();

    final Path rightArrow = Path()
      ..moveTo(size.width + 5, yPos)
      ..lineTo(size.width + 20, yPos - 10)
      ..lineTo(size.width + 20, yPos + 10)
      ..close();

    canvas.drawPath(leftArrow, paint..style = PaintingStyle.fill);
    canvas.drawPath(rightArrow, paint);
  }

  void _drawBall(Canvas canvas, Size size, double value, bool isInRange) {
    final double ballRadius = size.width * 0.22;
    final double innerPadding = size.width * 0.12;
    final double minY = innerPadding + ballRadius;
    final double maxY = size.height - innerPadding - ballRadius;

    final double normalizedVal = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final double yPos = maxY - (normalizedVal * (maxY - minY));

    final Color baseColor =
    isInRange ? const Color(0xFF3EAF58) : const Color(0xFF308BF9);
    final Color lightColor =
    isInRange ? const Color(0xFFA9F7BA) : const Color(0xFF8EC1FF);

    canvas.drawCircle(
      Offset(size.width / 2, yPos),
      ballRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [lightColor, baseColor],
          center: Alignment.bottomCenter,
          radius: 1.1,
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width / 2, yPos),
            radius: ballRadius,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) => false;
}

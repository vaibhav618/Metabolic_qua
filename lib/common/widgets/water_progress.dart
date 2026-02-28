import 'package:flutter/material.dart';

class SimpleWaterGlass extends StatefulWidget {
  final double targetMl;
  final double consumedMl;
  final double width;
  final double height;

  const SimpleWaterGlass({
    super.key,
    required this.targetMl,
    required this.consumedMl,
    this.width = 80,
    this.height = 100,
  });

  @override
  State<SimpleWaterGlass> createState() => _SimpleWaterGlassState();
}

class _SimpleWaterGlassState extends State<SimpleWaterGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _levelAnimation;

  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _setupAnimation();
  }

  @override
  void didUpdateWidget(SimpleWaterGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumedMl != widget.consumedMl ||
        oldWidget.targetMl != widget.targetMl) {
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    final double safeTarget = widget.targetMl <= 0 ? 1 : widget.targetMl;

    final double newLevel =
    (widget.consumedMl / safeTarget).clamp(0.0, 1.0); // 0–1

    _levelAnimation = Tween<double>(
      begin: _currentLevel,
      end: newLevel,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward(from: 0.0);
    _currentLevel = newLevel;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _GifStyleGlassPainter(_levelAnimation.value),
          );
        },
      ),
    );
  }
}

/// EXACT glass + water shape like GIF
class _GifStyleGlassPainter extends CustomPainter {
  final double level;

  _GifStyleGlassPainter(this.level);

  @override
  void paint(Canvas canvas, Size size) {
    final double topWidth = size.width * 0.82;
    final double bottomWidth = size.width * 0.52;

    final double topY = size.height * 0.08;
    final double bottomY = size.height * 0.92;

    final double topLeft = (size.width - topWidth) / 2;
    final double topRight = topLeft + topWidth;
    final double bottomLeft = (size.width - bottomWidth) / 2;
    final double bottomRight = bottomLeft + bottomWidth;

    final double centerX = size.width / 2;

    // SAME GIF COLORS
    const glassColor = Color(0xFFD4E6FF); // light blue
    const waterColor = Color(0xFF2F80FF); // full bright blue
    const topEllipseColor = Color(0xFFE2EEFF);

    // -------------- GLASS SHAPE --------------
    final Path glassPath = Path()
      ..moveTo(topLeft, topY)
      ..lineTo(topRight, topY)
      ..lineTo(bottomRight, bottomY)
      ..lineTo(bottomLeft, bottomY)
      ..close();

    final Paint glassPaint = Paint()..color = glassColor;
    canvas.drawPath(glassPath, glassPaint);

    // -------------- WATER LEVEL --------------
    final double waterTopY =
        bottomY - (bottomY - topY) * level.clamp(0, 1);

    canvas.save();
    canvas.clipPath(glassPath); // water stays inside glass shape

    final Rect waterRect = Rect.fromLTRB(
      0,
      waterTopY,
      size.width,
      bottomY,
    );

    final Paint waterPaint = Paint()..color = waterColor;
    canvas.drawRect(waterRect, waterPaint);

    canvas.restore();

    // -------------- TOP ELLIPSE --------------
    final Rect topOval = Rect.fromCenter(
      center: Offset(centerX, topY),
      width: topWidth,
      height: size.height * 0.12,
    );

    final Paint topOvalPaint = Paint()..color = topEllipseColor;
    canvas.drawOval(topOval, topOvalPaint);
  }

  @override
  bool shouldRepaint(_GifStyleGlassPainter oldDelegate) =>
      oldDelegate.level != level;
}

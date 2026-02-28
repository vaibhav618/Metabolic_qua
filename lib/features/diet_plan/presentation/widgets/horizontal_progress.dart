import 'package:flutter/material.dart';

class HorizontalPercent extends StatelessWidget {
  final double percent; // 0..100
  final double height;
  final Color color;
  final Color bgColor;
  final BorderRadiusGeometry borderRadius;
  final Duration duration;

  const HorizontalPercent({
    super.key,
    required this.percent,
    this.height = 12,
    this.color = const Color(0xFF3FAF58),
    this.bgColor = const Color(0xFFE6E6E6),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final value = (percent.clamp(0, 100)) / 100.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              // track
              Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // fill
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                height: height,
                width: maxW * value,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

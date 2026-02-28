import 'package:flutter/material.dart';

/// Simple, highly-customizable linear progress with rounded caps.
/// Expands to parent's width. Set a fixed height for pill look.
class LinearCapsProgress extends StatelessWidget {
  const LinearCapsProgress({
    super.key,
    required this.progress,          // 0.0..1.0
    this.height = 10,
    this.trackColor = const Color(0xFFD9D9D9),
    this.progressColor = const Color(0xFF2EAD4A),
    this.radius,                     // if null => height/2 (pill)
    this.progressGradient,           // optional LinearGradient
    this.background,                 // optional background decoration
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
  });

  final double progress;
  final double height;
  final Color trackColor;
  final Color progressColor;
  final double? radius;
  final LinearGradient? progressGradient;
  final BoxDecoration? background;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final r = Radius.circular(radius ?? height / 2);

    return Padding(
      padding: padding,
      child: Container(
        constraints: const BoxConstraints(minWidth: 0),
        width: double.infinity,
        height: height,
        decoration: background ??
            BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(r),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Track (remainder)
              Container(color: trackColor),

              // Progress fill
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressGradient == null ? progressColor : null,
                        gradient: progressGradient,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated wrapper for smooth progress changes.
class AnimatedLinearCapsProgress extends StatelessWidget {
  const AnimatedLinearCapsProgress({
    super.key,
    required this.progress,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.height = 10,
    this.trackColor = const Color(0xFFD9D9D9),
    this.progressColor = const Color(0xFF2EAD4A),
    this.radius,
    this.progressGradient,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
  });

  final double progress;
  final Duration duration;
  final Curve curve;

  final double height;
  final Color trackColor;
  final Color progressColor;
  final double? radius;
  final LinearGradient? progressGradient;
  final BoxDecoration? background;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: duration,
      curve: curve,
      builder: (_, value, __) {
        return LinearCapsProgress(
          progress: value,
          height: height,
          trackColor: trackColor,
          progressColor: progressColor,
          radius: radius,
          progressGradient: progressGradient,
          background: background,
          padding: padding,
        );
      },
    );
  }
}

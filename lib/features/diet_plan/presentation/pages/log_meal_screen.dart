import 'dart:math' as math;

import 'package:flutter/material.dart';


class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  bool isLogMealDetailsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN CONTENT
            Positioned.fill(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Color(0xFF252525)),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Log food",
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "07 July",
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF308BF9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.10,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.chevron_left_outlined),
                          Column(
                            children: [
                              Text(
                                "Wake up",
                                style: TextStyle(
                                  color: Color(0xFF252525),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "06:00-06:30AM",
                                style: TextStyle(
                                  color: Color(0xFF252525),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right_outlined),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Spacer(),
                            Visibility(
                              visible: !isLogMealDetailsVisible,
                              child: Container(
                                width: double.infinity,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF252525),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Row(
                                  children: [
                                    const CircularPercent(
                                      percent: 75,
                                      size: 67,
                                      stroke: 5,
                                      color: Color(0xFF3FAF58),
                                      bgColor: Color(0xFFD9D9D9),
                                      child: Icon(Icons.emoji_events,
                                          size: 32, color: Colors.white),
                                    ),
                                    const SizedBox(width: 22),
                                    const Expanded(
                                      child: _DailyGoalText(),
                                    ),
                                    InkWell(
                                      onTap: () => setState(() =>
                                      isLogMealDetailsVisible =
                                      !isLogMealDetailsVisible),
                                      child: Icon(isLogMealDetailsVisible ? Icons.close : Icons.keyboard_arrow_up_outlined, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // OVERLAY with pass-through when hidden
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isLogMealDetailsVisible, // taps pass to behind when hidden
                child: AnimatedOpacity(
                  opacity: isLogMealDetailsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Stack(
                    children: [
                      // Scrim (tap to close)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => isLogMealDetailsVisible = false),
                          child: Container(color: const Color(0x7F252525)),
                        ),
                      ),

                      // Bottom sheet
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: AnimatedSlide(
                            offset: isLogMealDetailsVisible
                                ? Offset.zero
                                : const Offset(0, 0.1),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // CARD: Calories + macros
                                    Container(
                                      width: double.infinity,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 24),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: const [
                                              CircularPercent(
                                                percent: 55,
                                                size: 67,
                                                stroke: 5,
                                                color: Color(0xFF3FAF58),
                                                bgColor: Color(0xFFD9D9D9),
                                                child: Icon(
                                                  Icons.local_fire_department,
                                                  size: 32,
                                                  color: Color(0xFF535359),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              _CaloriesInfo(),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: const [
                                              Expanded(
                                                child: _MacroBlock(
                                                  title: "Protein",
                                                  percent: 10,
                                                  current: "25g",
                                                  total: "100g",
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: _MacroBlock(
                                                  title: "Carbs",
                                                  percent: 100,
                                                  current: "250g",
                                                  total: "250g",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: const [
                                              Expanded(
                                                child: _MacroBlock(
                                                  title: "Fat",
                                                  percent: 50,
                                                  current: "30g",
                                                  total: "60g",
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: _MacroBlock(
                                                  title: "Fiber",
                                                  percent: 40,
                                                  current: "12g",
                                                  total: "30g",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // CARD: Daily Goal
                                    Container(
                                      width: double.infinity,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF252525),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      child: Row(
                                        children: [
                                          const CircularPercent(
                                            percent: 75,
                                            size: 67,
                                            stroke: 5,
                                            color: Color(0xFF3FAF58),
                                            bgColor: Color(0xFFD9D9D9),
                                            child: Icon(Icons.emoji_events,
                                                size: 32, color: Colors.white),
                                          ),
                                          const SizedBox(width: 22),
                                          const Expanded(
                                            child: _DailyGoalText(),
                                          ),
                                          InkWell(
                                            onTap: () => setState(() =>
                                            isLogMealDetailsVisible =
                                            !isLogMealDetailsVisible),
                                            child: Icon(isLogMealDetailsVisible ? Icons.close : Icons.keyboard_arrow_up_outlined, color: Colors.white),

                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Small UI pieces =======

class _CaloriesInfo extends StatelessWidget {
  const _CaloriesInfo();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF535359),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    const valueStyle = TextStyle(
      color: Color(0xFF252525),
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    const tiny = TextStyle(
      color: Color(0xFF252525),
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.2,
    );
    const tinyBold = TextStyle(
      color: Color(0xFF252525),
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Calories", style: labelStyle),
        const SizedBox(height: 8),
        const Text("1200 kcal", style: valueStyle),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: "out of ", style: tiny),
              TextSpan(text: "1800kcal", style: tinyBold),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroBlock extends StatelessWidget {
  final String title;
  final double percent;
  final String current;
  final String total;

  const _MacroBlock({
    required this.title,
    required this.percent,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF535359),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.10,
    );
    const valueStyle = TextStyle(
      color: Color(0xFF252525),
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.26,
    );
    const tiny = TextStyle(
      color: Color(0xFF252525),
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );
    const tinyBold = TextStyle(
      color: Color(0xFF252525),
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: labelStyle),
        const SizedBox(height: 12),
        const SizedBox(height: 4),
        // bar
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: HorizontalPercent(
            percent: percent,
            color: const Color(0xFFC9880F),
            bgColor: const Color(0xFFD9D9D9),
            height: 5,
          ),
        ),
        const SizedBox(height: 12),
        Text(current, style: valueStyle),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: "out of ", style: tiny),
              TextSpan(text: total, style: tinyBold),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyGoalText extends StatelessWidget {
  const _DailyGoalText();

  @override
  Widget build(BuildContext context) {
    const small = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.2,
    );
    const big = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Daily Goal", style: small),
        SizedBox(height: 12),
        Text("75% completed", style: big),
      ],
    );
  }
}

// ======= Widgets: HorizontalPercent & CircularPercent =======

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
              Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
    final value = (percent.clamp(0, 100)) / 100.0;
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

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (start at top, -90°)
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
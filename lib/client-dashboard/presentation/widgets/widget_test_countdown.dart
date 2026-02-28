import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestCountDowTimer extends StatefulWidget {
  final DateTime target;          // end time
  final VoidCallback? onDone;     // called when it hits 0

  const TestCountDowTimer({
    super.key,
    required this.target,
    this.onDone,
  });

  @override
  State<TestCountDowTimer> createState() => _CountdownRowState();
}

class _CountdownRowState extends State<TestCountDowTimer> {
  late Timer _timer;
  late Duration _remain;

  @override
  void initState() {
    super.initState();
    _remain = _calcRemain();
    _start();
  }

  Duration _calcRemain() {
    final now = DateTime.now();
    final diff = widget.target.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _calcRemain();
      if (mounted) {
        setState(() => _remain = next);
      }
      if (next == Duration.zero) {
        _timer.cancel();
        widget.onDone?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TestCountDowTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _timer.cancel();
      _remain = _calcRemain();
      _start();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parts = _toParts(_remain);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _timeCol("days", parts.days),
        _sep(),
        _timeCol("hrs", parts.hours),
        _sep(),
        _timeCol("mins", parts.mins),
        _sep(),
        _timeCol("secs", parts.secs),
      ],
    );
  }

  _Parts _toParts(Duration d) {
    final totalSecs = d.inSeconds;
    final days = totalSecs ~/ (24 * 3600);
    final hours = (totalSecs % (24 * 3600)) ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final secs = totalSecs % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return _Parts(days.toString().padLeft(2, '0'), two(hours), two(mins), two(secs));
  }

  Widget _timeCol(String label, String value) => Column(
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 8,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.16,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 25,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.50,
        ),
      ),
    ],
  );

  Widget _sep() => Text(
    ":",
    style: GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.40,
    ),
  );
}

class _Parts {
  final String days, hours, mins, secs;
  _Parts(this.days, this.hours, this.mins, this.secs);
}

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import '../../../../bluetooth_device_connectivity/presentation/widgets/circular_percent.dart';
import '../../bloc/practice_test_exhale_state.dart';

class PracticeTestExhaleStartCounterScreen extends StatelessWidget {
  final PracticeTestExhaleState state;
  const PracticeTestExhaleStartCounterScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final endsAt = state.startCounterEndsAtEpochMs;
    final totalMs = state.startCounterTotalMillis;

    if (endsAt <= 0 || totalMs <= 0) {
      return _layout(context, remainingMs: 0, percent: 0);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final startRemainingMs = (endsAt - now).clamp(0, totalMs);

    return TweenAnimationBuilder<int>(
      key: ValueKey<int>(endsAt),
      tween: IntTween(begin: startRemainingMs, end: 0),
      duration: Duration(milliseconds: startRemainingMs),
      builder: (context, remainingMs, _) {
        final percent = (remainingMs / totalMs).clamp(0.0, 1.0) * 100;

        return _layout(
          context,
          remainingMs: remainingMs,
          percent: percent,
        );
      },
    );
  }

  Widget _layout(
    BuildContext context, {
    required int remainingMs,
    required double percent,
  }) {
    final seconds = (remainingMs / 1000).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: rh(context: context, px: 25)),
        SizedBox(
          width: double.infinity,
          child: Text(
            "Starting in...",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 25),
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -1,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularPercent(
                    percent: percent,
                    stroke: rh(context: context, px: 4),
                    color: const Color(0xFF308BF9),
                  ),
                ),
                Text(
                  seconds.toString(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 60),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -3.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

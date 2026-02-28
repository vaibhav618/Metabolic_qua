import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../diet_plan/presentation/widgets/circular_progress.dart';
import '../cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';

class InhaleGettingStarted extends StatelessWidget {
  final BluetoothInhaleState state;
  const InhaleGettingStarted({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final int maxCount = state.startCountdownFrom == 0 ? 5 : state.startCountdownFrom;

    final double progress = (((maxCount - state.startCounter) / maxCount) * 100).clamp(0.0, 100.0);

    return Column(
      children: [
        Row(),
        Spacer(),
        Text(
          "Starting in...",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 34,
            fontWeight: FontWeight.w400,
            letterSpacing: -2.04,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CircularPercent(
                  percent: progress,
                  stroke: 4,
                  color: const Color(0xFF308BF9),
                )),
                Text(state.startCounter.toString(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 60,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -3.60,
                  ),
                )
              ],
            ),
          ),
        ),
        Spacer(flex:3 ,),
      ],
    );
  }
}

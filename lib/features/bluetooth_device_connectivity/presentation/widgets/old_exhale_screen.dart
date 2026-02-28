
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../dashboard/new_exhale_progress_screen.dart';
import '../cubit/bluetooth_exhale_cubit.dart/bluetooth_exhale_state.dart';



class OldExhaleScreen extends StatelessWidget {
  final BluetoothExhaleState state;
  final VoidCallback onCloseButtonPressed;
  const OldExhaleScreen({super.key, required this.state, required this.onCloseButtonPressed});

  @override
  Widget build(BuildContext context) {
    final double progress = ((10 - state.progress) / 10).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          children: [
            // SizedBox(
            //   height: 350,
            //   width: MediaQuery.of(context).size.width * 0.96,
            //   child: Image.asset(
            //     'assets/images/gif_images/exhale.gif',
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => onCloseButtonPressed,
                    icon: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: SvgPicture.asset(
                        "assets/images/common/closeicon.svg",
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.volume_up),
                  ),
                ],
              ),
            ),
            if (state.progress > 0.2 && state.progress < 0.49)
              Positioned(
                bottom: 50,
                left: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Having trouble with exhale?\t",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mulish(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF595959),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Try practice test",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mulish(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF308BF9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),



        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              children: [
                const TextSpan(
                  text: "Exhale into device until scale turns ",
                ),
                TextSpan(
                  text: "GREEN",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3EAF58),
                  ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: const Color(0xFFF3F3F3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.progress < 0.10
                        ? Colors.grey
                        : state.progress <
                        (state.thresholdPercentage ?? 1) / 120
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
            ),
            Positioned(
              left: ((state.thresholdPercentage ?? 0) / 120) *
                  MediaQuery.of(context).size.width,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.black),
            ),
          ],
        ),
        Text(
          _getInfoText(state),
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: state.progress < 0.10
                ? Colors.grey
                : state.progress <
                (state.thresholdPercentage ?? 1) / 120
                ? Colors.red
                : Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          children: [
            Text(
              "${state.secondsRemaining}",
              style: GoogleFonts.roboto(
                fontSize: 40,
                fontWeight: FontWeight.w400,
                color: state.secondsRemaining <= 10
                    ? Colors.red
                    : Colors.black,
              ),
            ),
            Text(
              'sec',
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: state.secondsRemaining <= 10
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
  String _getInfoText(BluetoothExhaleState state) {
    if (state.thresholdPercentage == null) return 'Start Exhaling...';

    final threshold = state.thresholdPercentage! / 120;
    final progress = state.progress;

    if (progress < 0.10) {
      return 'Start Exhaling...';
    } else if (progress < threshold) {
      return 'Exhale Harder';
    } else {
      return 'Keep Exhaling';
    }
  }
}

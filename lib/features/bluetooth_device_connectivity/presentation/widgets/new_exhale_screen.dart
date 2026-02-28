
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../dashboard/new_exhale_progress_screen.dart';
import '../cubit/bluetooth_exhale_cubit.dart/bluetooth_exhale_state.dart';



class NewExhaleScreen extends StatelessWidget {
  final BluetoothExhaleState state;
  final VoidCallback onCloseButtonPressed;
  const NewExhaleScreen({super.key, required this.state, required this.onCloseButtonPressed});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [


        Row(),
        Spacer(),
        Text(
          "Exhale",
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
                Positioned.fill(child:    ExhaleProgressRing(progress: state.progress, mode: BreathMode.exhale,)),
              ],
            ),
          ),
        ),
        Spacer(flex:3 ,),
        Spacer(),
        Column(
          children: [
            Text(
              "${state.secondsRemaining}",
              style: GoogleFonts.roboto(
                fontSize: 40,
                fontWeight: FontWeight.w400,
                height: 1.0,
                color: state.secondsRemaining <= 10
                    ? Colors.red
                    : Colors.black,
              ),
            ),
            Text(
              'sec',
              style: GoogleFonts.roboto(
                fontSize: 12,
                height: 1.0,
                fontWeight: FontWeight.w400,
                color: state.secondsRemaining <= 10
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10,)
      ],
    );
  }
}

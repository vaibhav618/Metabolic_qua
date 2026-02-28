import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/dashboard/new_exhale_progress_screen.dart';

import '../cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';

class InhaleView extends StatelessWidget {
  final BluetoothInhaleState state;
  const InhaleView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {

    if(state.inhaleFinished && state.holdStarted){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(),
          Spacer(),
          Text(
            "Hold",
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
                  Positioned.fill(child:    ExhaleProgressRing(progress: 100, mode: BreathMode.inhale,)),
                  Text(state.holdCounter.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
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

    if(!state.inhaleFinished){
      return Column(
        children: [
          Row(),
          Spacer(),
          Text(
            "Inhale",
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
                  Positioned.fill(child:    ExhaleProgressRing(progress: state.progress, mode: BreathMode.inhale,)),
                  // Text(state.perfectSamples.toString()),
                ],
              ),
            ),
          ),
          Spacer(flex:3 ,),
        ],
      );
    }


    if(state.holdFinished){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(),
          Spacer(),
          Text(
            "Hold",
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
                  Positioned.fill(child:ExhaleProgressRing(progress: 100, mode: BreathMode.inhale,)),
                ],
              ),
            ),
          ),
          Spacer(flex:3 ,),
        ],
      );
    }



    return SizedBox.shrink();
  }
}

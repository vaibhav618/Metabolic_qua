import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';

import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';
import 'new_inhale_screen.dart';
import 'new_start_test_counter_screen.dart';

enum InhaleView {
  loading,
  countdown,
  inhale,
  holdCompleted,
  failed,
}

Widget inhaleBody(BuildContext context, BluetoothInhaleCubitNewState state, InhaleView view, BreathingSettings breathSettings) {
  switch (view) {
    case InhaleView.failed:
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            state.inhaleFailReason,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );

    case InhaleView.countdown:return SafeArea(child: NewStartTestCounterScreen(state: state));

    case InhaleView.holdCompleted:
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Color(0xFF03A450)),
              const SizedBox(height: 16),
              Text(
                "Hold Completed",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Great! Proceeding to next step…",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );

    case InhaleView.inhale:
      return SafeArea(child: NewInhaleScreen(state: state, breathingSettings: breathSettings,));

    case InhaleView.loading:
      return const SizedBox.shrink();
  }
}
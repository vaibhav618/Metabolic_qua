import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';

class NewHoldScreen extends StatelessWidget {
  final BluetoothInhaleCubitNewState state;
  const NewHoldScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final total = 8;
    final remaining = (total - state.holdSeconds).ceil().clamp(0, total);

    return Center(
      child: Text(
        "Hold your breath…\n$remaining s",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}

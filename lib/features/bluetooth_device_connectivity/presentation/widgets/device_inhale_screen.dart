import 'package:flutter/cupertino.dart';

import '../cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';
import 'inhale_getting_started.dart';
import 'inhale_view.dart';

class DeviceInhaleScreen extends StatelessWidget {
  final BluetoothInhaleState state;
  const DeviceInhaleScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {

    if (!state.startCounterFinished && !state.inhaleStarted) {
      return InhaleGettingStarted(state: state);
    }

    // 2️⃣ INHALE PHASE (live progress)
    if (state.inhaleStarted && !state.inhaleFinished) {
      return InhaleView(state: state);
    }

    // 3️⃣ HOLD PHASE
    if (state.holdStarted && !state.holdFinished) {
      return InhaleView(state: state);
    }

    // 4️⃣ HOLD FINISHED (waiting for blownow → navigation handled by BlocListener)
    if (state.holdFinished) {
      return InhaleView(state: state);
    }

    // fallback (should never hit)
    return InhaleView(state: state);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart'; // 🚨 REQUIRED FOR SEAMLESS BACKGROUND

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../common/dialogs/disconnection_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/size/get_height.dart';
import '../../../../features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';

import '../../data/datasource/bluetooth_manager.dart';
import '../../data/model/breath_setting_model.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_cubit_new.dart';
import '../cubit/bluetooth_inhale_cubit_new/bluetooth_inhale_new_state.dart';
import '../widgets/hold_breach_failed.dart';
import '../widgets/inhale_failed.dart';
import '../widgets/new_inhale_screen.dart';

// 🚨 THE MAGIC HAND-OFF BOX
class SharedVideoHandOff {
  static VideoPlayerController? controller;
}

class BluetoothInhaleScreenNew extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const BluetoothInhaleScreenNew({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
    required this.breathingSettings,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BluetoothInhaleCubitNew(
        context.read<BluetoothRepository>(),
        breathingSettings,
      ),
      child: _InhaleViewScaffold(
        clientProfileModel: clientProfileModel,
        dietPlanStrategyModel: dietPlanStrategyModel,
        minRange: minRange,
        maxRange: maxRange,
        breathingSettings: breathingSettings,
      ),
    );
  }
}

class _InhaleViewScaffold extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const _InhaleViewScaffold({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
    required this.breathingSettings,
  });

  @override
  State<_InhaleViewScaffold> createState() => _InhaleViewScaffoldState();
}

class _InhaleViewScaffoldState extends State<_InhaleViewScaffold> {
  bool _disconnectDialogShown = false;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    // 🚨 Detect if the device is using a 3-button navigation bar vs gestures
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final hasNavBar = bottomPadding > 35.0;

    return BlocListener<BluetoothInhaleCubitNew, BluetoothInhaleCubitNewState>(
      listenWhen: (previous, current) =>
          previous.isConnected != current.isConnected ||
          previous.holdFinished != current.holdFinished ||
          previous.inhaleFailed != current.inhaleFailed ||
          previous.navigateToDashboard != current.navigateToDashboard ||
          previous.holdBreathViolation != current.holdBreathViolation,
      listener: (context, state) => _handleStateLogic(context, state),
      child: BlocBuilder<BluetoothInhaleCubitNew, BluetoothInhaleCubitNewState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              _onCancel(context: context, state: state);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: _buildAppBar(
                context: context,
                onBackClicked: () => _onCancel(context: context, state: state),
              ),
              // 🚨 Dynamically uses Safe Area ONLY if a 3-button nav bar is present
              body: SafeArea(
                  bottom: hasNavBar, child: _buildScreen(context, state)),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required VoidCallback onBackClicked,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: onBackClicked,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildScreen(
      BuildContext context, BluetoothInhaleCubitNewState state) {
    if (state.inhaleFailed) {
      final isHoldBreach = state.holdBreathViolation.trim().isNotEmpty;

      if (isHoldBreach) {
        return HoldBreachFailed(
          text: state.holdBreathViolation.trim(),
          onStartAgain: () =>
              context.read<BluetoothInhaleCubitNew>().cancelTest(),
        );
      }

      final msg = state.inhaleFailReason.trim().isNotEmpty
          ? state.inhaleFailReason.trim()
          : "Test failed.";

      return InhaleFailed(
        text: msg,
        onStartAgain: () =>
            context.read<BluetoothInhaleCubitNew>().cancelTest(),
      );
    }

    // 🚨 SEAMLESS MAGIC HAPPENS HERE:
    // Replaced the old blue circle with our custom Seamless View!
    if (state.startCounterStarted && !state.startCounterFinished) {
      return _SeamlessInhaleCountdown(state: state);
    }

    if (state.startCounterFinished ||
        (state.holdStarted && !state.holdFinished)) {
      return NewInhaleScreen(
        state: state,
        breathingSettings: widget.breathingSettings,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              "Something went wrong\nPlease start again",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  context.read<BluetoothInhaleCubitNew>().cancelTest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(
                  vertical: rh(context: context, px: 16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Start Again",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                  height: rh(context: context, px: 1.0),
                  letterSpacing: rh(context: context, px: 0.30),
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 48)),
        ],
      ),
    );
  }

  void _handleStateLogic(
      BuildContext context, BluetoothInhaleCubitNewState state) async {
    if (!mounted) return;
    if (_navigated) return;

    if (state.navigateToDashboard) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
      return;
    }

    if (!state.isConnected) {
      UuidBluetoothManager().clearAllConnections();
      await _showDisconnectDialog(context);
    } else {
      _closeDisconnectDialogIfOpen(context);
    }

    if (state.inhaleFailed) return;

    if (state.holdFinished) {
      _navigated = true;
      _closeDisconnectDialogIfOpen(context);
      context.go(
        AppRoutes.bluetoothExhaleScreen,
        extra: {
          "clientProfileModel": widget.clientProfileModel,
          "dietPlanStrategyModel": widget.dietPlanStrategyModel,
          "baseValue": state.blowExhaleBaseValue.toStringAsFixed(2),
          "min_range": widget.minRange,
          "max_range": widget.maxRange,
          "breathSettings": widget.breathingSettings,
        },
      );
    }
  }

  void _onCancel({
    required BuildContext context,
    required BluetoothInhaleCubitNewState state,
  }) {
    if (state.inhaleFailed) {
      context.read<BluetoothInhaleCubitNew>().cancelTest();
      return;
    }

    showCancelTestDialog(context, () async {
      context.read<BluetoothInhaleCubitNew>().cancelTest();
    });
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;

    _disconnectDialogShown = true;

    await showDeviceDisconnectedBox(
      context: context,
      onButtonPressed: () {
        context.read<BluetoothInhaleCubitNew>().cancelTest();
      },
    );

    _disconnectDialogShown = false;
  }

  void _closeDisconnectDialogIfOpen(BuildContext context) {
    if (!_disconnectDialogShown) return;

    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    _disconnectDialogShown = false;
  }
}

// ============================================================================
// 🚨 NEW SEAMLESS COUNTDOWN WIDGET (Replaces Blue Circle UI)
// ============================================================================

class _SeamlessInhaleCountdown extends StatefulWidget {
  final BluetoothInhaleCubitNewState state;

  const _SeamlessInhaleCountdown({required this.state});

  @override
  State<_SeamlessInhaleCountdown> createState() =>
      _SeamlessInhaleCountdownState();
}

class _SeamlessInhaleCountdownState extends State<_SeamlessInhaleCountdown> {
  late VideoPlayerController _c3;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // 🚨 MAGIC: If the Calibration screen handed off the video, use it!
    if (SharedVideoHandOff.controller != null) {
      _c3 = SharedVideoHandOff.controller!;
      _initialized = true;
    } else {
      // Normal fallback if app reloads on this screen
      _c3 = VideoPlayerController.asset(
        'assets/images/calibration/cali3.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true), // 🚨 ADDED
      );
      _c3.initialize().then((_) {
        if (!mounted) return;
        _c3.setVolume(0.0); // 🚨 ADDED
        _c3.seekTo(_c3.value.duration).then((_) {
          setState(() {
            _initialized = true;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    // 🚨 ALWAYS explicitly dispose the controller to free up the Android MediaCodec
    _c3.dispose();

    // Clean up the handoff after use so it's ready for the next test
    SharedVideoHandOff.controller = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Very brief fallback while video loads into memory
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: rh(context: context, px: 20)),
        SizedBox(
          height: rh(context: context, px: 40),
          width: double.infinity,
          child: RichText(
            key: ValueKey("countdown_${widget.state.startCounter}"),
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Starting in...",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: 1.10,
                letterSpacing: rh(context: context, px: -1),
              ),
              children: [
                TextSpan(
                  text:
                      "${widget.state.startCounter}", // 🚨 Driven completely by the Inhale Cubit timer
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF308BF9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 8,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _c3.value.size.width,
                        height: _c3.value.size.height,
                        child: VideoPlayer(_c3), // 🚨 Frozen video background
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// lib/features/bluetooth_device_connectivity/presentation/screens/bluetooth_calibration_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_inhale_screen_new.dart'
    show SharedVideoHandOff;
import 'package:video_player/video_player.dart'; // 🚨 REQUIRED FOR VIDEO STACK

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import '../../../../common/dialogs/exhale_timeout_dialog.dart';
import '../../../../core/size/get_height.dart';
import '../../data/datasource/bluetooth_manager.dart';

class BluetoothCalibrationScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const BluetoothCalibrationScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  State<BluetoothCalibrationScreen> createState() =>
      _BluetoothCalibrationScreenState();
}

class _BluetoothCalibrationScreenState
    extends State<BluetoothCalibrationScreen> {
  bool _dialogOpen = false;

  void _postFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fn();
    });
  }

  void _navigateToDashboard(BluetoothCalibrationCubit cubit) {
    cubit.dialogDismissed();
    context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
  }

  Future<bool> _showCancelDialog(
    BluetoothCalibrationCubit cubit,
    bool allSignalSent,
  ) async {
    _dialogOpen = true;
    final completer = Completer<bool>();

    _postFrame(() {
      showCancelTestDialog(context, () async {
        cubit.sendAbort();
        completer.complete(true);
      });

      Future.microtask(() async {
        try {
          final res = await completer.future;
          if (!mounted) return;
          if (res) _navigateToDashboard(cubit);
        } finally {
          _dialogOpen = false;
        }
      });
    });

    return completer.future;
  }

  void _showTimeoutDialog(
    BluetoothCalibrationCubit cubit,
    BluetoothCalibrationState state,
  ) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    _postFrame(() {
      showExhaleSessionTimeOutDialog(
        context: context,
        onButtonPressed: () {
          if (state.allSignalSent) cubit.sendAbort();
          _navigateToDashboard(cubit);
        },
        message: "Session timed out",
        description:
            "No response was received from the device. Please restart the test.",
      ).then((_) => _dialogOpen = false);
    });
  }

  void _showErrorDialog(String msg) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    _postFrame(() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(msg),
        ),
      ).then((_) => _dialogOpen = false);
    });
  }

  void _showDisconnectedDialog(BluetoothCalibrationCubit cubit) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    _postFrame(() {
      showDeviceDisconnectedBox(
        context: context,
        onButtonPressed: () async {
          if (!mounted) return;
          context.pop();
          if (!mounted) return;
          context.go(
            AppRoutes.clientDashboard,
            extra: widget.clientProfileModel,
          );
        },
      ).then((_) => _dialogOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 MAGIC THRESHOLD LOGIC:
    // Gesture pills (iOS/Android) are usually <= 34px.
    // 3-button nav bars are typically >= 48px.
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isThreeButtonNav = bottomPadding > 35.0;

    return BlocProvider(
      create: (ctx) => BluetoothCalibrationCubit(
        ctx.read<BluetoothRepository>(),
        AudioHelper(),
      ),
      child: BlocListener<BluetoothCalibrationCubit, BluetoothCalibrationState>(
        listenWhen: (prev, curr) =>
            prev.navigateToInhaleScreen != curr.navigateToInhaleScreen ||
            prev.textError != curr.textError ||
            prev.isDialogShown != curr.isDialogShown ||
            prev.isTimeOver != curr.isTimeOver ||
            prev.isBluetoothConnected != curr.isBluetoothConnected ||
            prev.startCalibrationTime != curr.startCalibrationTime,
        listener: (context, state) {
          final cubit = context.read<BluetoothCalibrationCubit>();

          if (state.navigateToInhaleScreen) {
            _postFrame(() {
              cubit.stopScreenOperation();
              context.go(
                AppRoutes.bluetoothInhaleScreen,
                extra: {
                  "client": widget.clientProfileModel,
                  "strategy": widget.dietPlanStrategyModel,
                  "min_range": widget.minRange,
                  "max_range": widget.maxRange,
                  "breath_settings": state.breathingSettings,
                },
              );
            });
            return;
          }

          if (state.isTimeOver && !state.navigateToInhaleScreen) {
            cubit.stopScreenOperation();
            _showTimeoutDialog(cubit, state);
            return;
          }

          if (state.textError != null) {
            _showErrorDialog(state.textError!);
            return;
          }

          if (state.isDialogShown || !state.isBluetoothConnected) {
            UuidBluetoothManager().clearAllConnections();
            _showDisconnectedDialog(cubit);
          }
        },
        child:
            BlocBuilder<BluetoothCalibrationCubit, BluetoothCalibrationState>(
          builder: (context, state) {
            final cubit = context.read<BluetoothCalibrationCubit>();

            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) return;

                if (state.isTimeOver && !state.navigateToInhaleScreen) {
                  if (state.allSignalSent) cubit.sendAbort();
                  _navigateToDashboard(cubit);
                  return;
                }

                await _showCancelDialog(cubit, state.allSignalSent);
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () =>
                          _showCancelDialog(cubit, state.allSignalSent),
                      icon: SvgPicture.asset(
                        "assets/images/common/closeicon.svg",
                        width: rh(context: context, px: 24),
                        height: rh(context: context, px: 24),
                      ),
                    ),
                  ],
                ),
                body: SafeArea(
                  // 🚨 Dynamically applies SafeArea ONLY for 3-button devices
                  bottom: isThreeButtonNav,
                  child: _CalibrationVideoStack(state: state),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// 🚨 PREMIUM VIDEO SEQUENCE MANAGER UI COMPONENT
// ============================================================================

// 🚨 Reverted to only the 3 main video stages (no countdown stage)
enum CaliStage { connecting, calibrating, transitioning }

class _CalibrationVideoStack extends StatefulWidget {
  final BluetoothCalibrationState state;

  const _CalibrationVideoStack({required this.state});

  @override
  State<_CalibrationVideoStack> createState() => _CalibrationVideoStackState();
}

class _CalibrationVideoStackState extends State<_CalibrationVideoStack> {
  late VideoPlayerController _c1;
  late VideoPlayerController _c2;
  late VideoPlayerController _c3;

  bool _initialized = false;
  bool _hasVideoError = false;

  CaliStage _stage = CaliStage.connecting;

  // Sequence Locks
  bool _c1Finished = false;
  bool _hardwareReady = false;

  @override
  void initState() {
    super.initState();
    _initVideos();
  }

  Future<void> _initVideos() async {
    try {
      // 🚨 ADDED: videoPlayerOptions to all 3 to stop audio focus stealing
      _c1 = VideoPlayerController.asset(
        'assets/images/calibration/cali1.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _c2 = VideoPlayerController.asset(
        'assets/images/calibration/cali2.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _c3 = VideoPlayerController.asset(
        'assets/images/calibration/cali3.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await Future.wait([
        _c1.initialize(),
        _c2.initialize(),
        _c3.initialize(),
      ]);

      if (!mounted) return;

      _c1.setLooping(false);
      _c2.setLooping(true);
      _c3.setLooping(false);

      // 🚨 CHANGED: Volume to 0.0 to prevent audio channel usage
      _c1.setVolume(0.0);
      _c2.setVolume(0.0);
      _c3.setVolume(0.0);

      _c1.addListener(_c1Listener);
      _c3.addListener(_c3Listener);

      setState(() {
        _initialized = true;
      });

      _playStage(CaliStage.connecting);
    } catch (e) {
      debugPrint("🚨 VIDEO INITIALIZATION FAILED: $e");
      if (mounted) {
        setState(() {
          _initialized = true;
          _hasVideoError = true;
        });
      }
    }
  }

  void _c1Listener() {
    if (_c1.value.position >= _c1.value.duration &&
        _c1.value.duration > Duration.zero) {
      _c1.removeListener(_c1Listener);
      _c1Finished = true;
      _evaluateNextStage();
    }
  }

  void _c3Listener() {
    if (_c3.value.position >= _c3.value.duration &&
        _c3.value.duration > Duration.zero) {
      _c3.removeListener(_c3Listener);

      if (mounted) {
        // HAND-OFF: Give the active video controller to the Inhale screen!
        SharedVideoHandOff.controller = _c3;

        // INSTANT ROUTE: cali3 is finished, go straight to Inhale Screen!
        context.read<BluetoothCalibrationCubit>().triggerInhaleNavigation();
      }
    }
  }

  @override
  void didUpdateWidget(covariant _CalibrationVideoStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialized && !_hasVideoError) {
      if (widget.state.calibrationHardwareReady && !_hardwareReady) {
        _hardwareReady = true;
        _evaluateNextStage();
      }
    }
  }

  void _evaluateNextStage() {
    if (!_initialized || _hasVideoError) return;

    if (_stage == CaliStage.connecting) {
      if (_c1Finished) {
        if (_hardwareReady) {
          _playStage(CaliStage.transitioning);
        } else {
          _playStage(CaliStage.calibrating);
        }
      }
    } else if (_stage == CaliStage.calibrating) {
      if (_hardwareReady) {
        _playStage(CaliStage.transitioning);
      }
    }
  }

  // 🚨 MAGIC: Instant cut logic. We DO NOT seekTo(0) anymore.
  // The videos are already primed at 0. We just call play() instantly.
  void _playStage(CaliStage nextStage) {
    if (_stage == nextStage && nextStage != CaliStage.connecting) return;

    setState(() {
      _stage = nextStage;
    });

    if (_stage == CaliStage.connecting) {
      _c1.play();
    } else if (_stage == CaliStage.calibrating) {
      _c2.play(); // Start playing cali2 IMMEDIATELY OVER cali1

      // Delay pausing the old video by 100ms so its frozen frame stays visible
      // underneath just long enough for cali2 to paint its first frame.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _c1.pause();
      });
    } else if (_stage == CaliStage.transitioning) {
      _c3.play(); // Start playing cali3 IMMEDIATELY OVER cali2

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _c2.pause();
      });
    }
  }

  @override
  void dispose() {
    if (!_hasVideoError) {
      _c1.dispose();
      _c2.dispose();
      // CRITICAL: Do not dispose _c3 if we passed it to the Inhale Screen!
      if (SharedVideoHandOff.controller != _c3) {
        _c3.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildDynamicText() {
    if (_stage == CaliStage.connecting) {
      return _animText("Connecting to device...");
    } else if (_stage == CaliStage.calibrating) {
      return _animText("Calibrating airflow...");
    } else if (_stage == CaliStage.transitioning) {
      return _animText("Almost ready...");
    }
    return const SizedBox.shrink();
  }

  Widget _animText(String text) {
    return Text(
      text,
      key: ValueKey(text),
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: const Color(0xFF252525),
        fontSize: rh(context: context, px: 25),
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: rh(context: context, px: -1),
      ),
    );
  }

  // 🚨 MAGIC: We no longer use AnimatedOpacity. We just use pure Opacity.
  // We keep lower-level stages visible underneath so higher stages seamlessly paint over them.
  Widget _buildVideoLayer(VideoPlayerController c, CaliStage layerStage) {
    bool isVisible = false;
    if (layerStage == CaliStage.connecting) {
      isVisible = true; // Cali1 is ALWAYS visible at the very bottom
    } else if (layerStage == CaliStage.calibrating) {
      // Cali2 is visible during calibrating AND transitioning
      isVisible =
          _stage == CaliStage.calibrating || _stage == CaliStage.transitioning;
    } else if (layerStage == CaliStage.transitioning) {
      // Cali3 is only visible during transitioning
      isVisible = _stage == CaliStage.transitioning;
    }

    return Opacity(
      opacity: isVisible ? 1.0 : 0.0,
      child: c.value.isInitialized
          ? Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // 🚨 REMOVED THE LOADING SPINNER
      // Now returns an invisible shrink box for a seamless transition
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: rh(context: context, px: 20)),
        SizedBox(
          height: rh(context: context, px: 40),
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildDynamicText(),
          ),
        ),
        // 🚨 UPDATED: Added stage condition so it fades out when Almost Ready begins
        AnimatedOpacity(
          opacity: widget.state.startCalibrationTime &&
                  widget.state.remainingSeconds > 0 &&
                  _stage != CaliStage.transitioning
              ? 1.0
              : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            "Estimated wait: ${widget.state.remainingSeconds}s",
            style: GoogleFonts.poppins(
              color: const Color(0xFF888888), // Subtle grey
              fontSize: rh(context: context, px: 14), // Smaller font size
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 8,
          child: _hasVideoError
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: rh(context: context, px: 6),
                    color: const Color(0xFF308BF9),
                    backgroundColor: const Color(0xFFE1E6ED),
                  ),
                )
              : ClipRect(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // These paint over each other seamlessly
                      _buildVideoLayer(_c1, CaliStage.connecting),
                      _buildVideoLayer(_c2, CaliStage.calibrating),
                      _buildVideoLayer(_c3, CaliStage.transitioning),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

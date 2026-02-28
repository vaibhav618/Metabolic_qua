import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../common/dialogs/cancel_Test_dialog.dart';
import '../../../../common/dialogs/disconnection_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../../data/datasource/bluetooth_manager.dart';
import '../../domain/params/generating_result_params.dart';
import '../../domain/processor/bluetooth_blow_processor.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_cubit.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';
import '../widgets/exhale_failed.dart';
import '../widgets/exhale_screen_app_bar.dart';
import '../widgets/new_exhale_screen_2.dart';

class BluetoothNewExhaleScreen extends StatelessWidget {
  final String baseValue;
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const BluetoothNewExhaleScreen({
    super.key,
    required this.baseValue,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
     required this.breathingSettings,
  });

  @override
  Widget build(BuildContext context) {
    final wrappedBase = "/${baseValue.trim()}/";

    return BlocProvider(
      create: (_) => BluetoothExhaleCubit(
        repo: context.read<BluetoothRepository>(),
        processor: BluetoothBlowProcessor(),
        baseValue: wrappedBase, breathingSettings: breathingSettings,
      ),
      child: _BluetoothNewExhaleScreenView(
        clientProfileModel: clientProfileModel,
        dietPlanStrategyModel: dietPlanStrategyModel,
        minRange: minRange,
        maxRange: maxRange, breathingSettings: breathingSettings,
      ),
    );
  }
}

class _BluetoothNewExhaleScreenView extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const _BluetoothNewExhaleScreenView({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange, required this.breathingSettings,
  });

  @override
  State<_BluetoothNewExhaleScreenView> createState() =>
      _BluetoothNewExhaleScreenViewState();
}


class _BluetoothNewExhaleScreenViewState extends State<_BluetoothNewExhaleScreenView> {
  bool _disconnectDialogShown = false;



  void _onCancel(BuildContext context, BluetoothExhaleState state) {
    if(state.exhaleFailed){
       context.read<BluetoothExhaleCubit>().cancelTest();
    }else{
      showCancelTestDialog(context, () async {
        await context.read<BluetoothExhaleCubit>().cancelTest();
      });
    }
  }

  Future<void> _showDisconnectDialog(BuildContext context) async {
    if (!mounted) return;
    if (_disconnectDialogShown) return;

    _disconnectDialogShown = true;

    await showDeviceDisconnectedBox(context: context, onButtonPressed: () {
      context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
    });
    if (mounted) {
      _disconnectDialogShown = false;
    }
  }

  void _closeDisconnectDialogIfOpen(BuildContext context) {
    if (!mounted) return;
    if (!_disconnectDialogShown) return;

    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {
    } finally {
      _disconnectDialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothExhaleCubit, BluetoothExhaleState>(
      listenWhen: (prev, curr) =>
      prev.isConnected != curr.isConnected ||
          prev.exhaleSuccess != curr.exhaleSuccess ||
          prev.exhaleFailed != curr.exhaleFailed ||
          prev.analysisReady != curr.analysisReady ||
          prev.navigateToDashboard != curr.navigateToDashboard,
      listener: (context, state) {
        if (state.cancelTest || state.navigateToDashboard) {
          _closeDisconnectDialogIfOpen(context);


          // if navigating is already requested, do it and return
          if (state.navigateToDashboard) {
            context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
          }
          return;
        }
        if (!state.isConnected) {
          UuidBluetoothManager().clearAllConnections();
          _showDisconnectDialog(context);
          return;
        } else {
          _closeDisconnectDialogIfOpen(context);
        }

        if (state.analysisReady) {
          if (state.blowValues.isNotEmpty) {
            final averageValue =
                state.blowValues.reduce((a, b) => a + b) / state.blowValues.length;
            final dummyParams = GeneratingResultParams(
              maxPressure: state.blowValues.reduce(max),
              bestPressure: averageValue,
              blowDuration: (state.inRangeDurationMs / 1000).toInt(),
              blowValuesList: state.blowValues,
              clientProfileModel: widget.clientProfileModel,
              dietPlanStrategyModel: widget.dietPlanStrategyModel,
              minRange: widget.minRange,
              maxRange: widget.maxRange,
            );

            context.push(
              AppRoutes.bluetoothGeneratingResultScreen,
              extra: dummyParams,
            );
          }
        }

        if (state.navigateToDashboard) {
          context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
        }
      },
      child: BlocBuilder<BluetoothExhaleCubit, BluetoothExhaleState>(
        buildWhen: (p, c) =>
        p.progress != c.progress ||
            p.inRange != c.inRange ||
            p.exhaleStarted != c.exhaleStarted ||
            p.holdSecondsLeft != c.holdSecondsLeft ||
            p.isConnected != c.isConnected ||
            p.exhaleFailed != c.exhaleFailed ||
            p.error != c.error,
        builder: (context, state) {
          if (state.exhaleFailed) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) return;
                _onCancel(context, state);
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: ExhaleScreenAppBar(context: context, cancelTestClicked: () {
                  _onCancel(context, state);
                }, ),
                body: SafeArea(
                  child: ExhaleFailed(
                    state: state,
                    onStartAgain: () async {
                      await context.read<BluetoothExhaleCubit>().cancelTest();
                    },
                  ),
                ),
              ),
            );
          }
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              _onCancel(context, state);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: ExhaleScreenAppBar(context: context,  cancelTestClicked: () {   _onCancel(context, state);  }),
              body: SafeArea(
                child: NewExhaleScreen2(state: state, breathingSettings: widget.breathingSettings,),
              ),
            ),
          );
        },
      ),
    );
  }
}
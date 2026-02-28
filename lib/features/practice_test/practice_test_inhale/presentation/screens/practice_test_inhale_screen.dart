import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/inhale_failed.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/bloc/practice_test_inhale_cubit.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/bloc/practice_test_inhale_state.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/data/practice_test_inhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/screens/practice_test_inhale_progress_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/screens/practice_test_start_counter_screen.dart'
    show PracticeTestStartCounterScreen;

import '../../../practice_test_home/bloc/practice_flow_bloc.dart';
import '../../../practice_test_home/domain/enums/practice_test.dart';

class PracticeTestInhaleScreen extends StatelessWidget {
  final PracticeTestInhaleParams practiceTestInhaleParams;

  const PracticeTestInhaleScreen({
    super.key,
    required this.practiceTestInhaleParams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeTestInhaleCubit(
        context.read(),
        practiceTestInhaleParams.breathingSettings,
      ),
      child: _PracticeTestInhaleView(
        settings: practiceTestInhaleParams.breathingSettings,
      ),
    );
  }
}

class _PracticeTestInhaleView extends StatelessWidget {
  final BreathingSettings settings;

  const _PracticeTestInhaleView({required this.settings});

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required VoidCallback onBackClicked,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onBackClicked,
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PracticeTestInhaleCubit, PracticeTestInhaleState>(
      listenWhen: (p, c) =>
          p.isConnected != c.isConnected ||
          p.error != c.error ||
          p.inhaleFailed != c.inhaleFailed ||
          p.inhaleSuccess != c.inhaleSuccess ||
          p.navigateBack != c.navigateBack ||
          p.inhaleSuccess != c.inhaleSuccess,
      listener: (context, state) {
        if (!state.isConnected) {
          _showSnack(context, "Device disconnected");
        }

        final err = state.error;
        if (err != null && err.trim().isNotEmpty) {
          _showSnack(context, err);
        }

        if (state.inhaleSuccess) {
          context.read<PracticeFlowBloc>().add(
                PracticeFlowMarkCompleted(PracticeTestSteps.inhaleTest),
              );
          context.pop();
        }

        if (state.navigateBack) {}
      },
      child: BlocBuilder<PracticeTestInhaleCubit, PracticeTestInhaleState>(
        buildWhen: (p, c) =>
            p.startCounterStarted != c.startCounterStarted ||
            p.startCounterFinished != c.startCounterFinished ||
            p.inhaleStarted != c.inhaleStarted ||
            p.inhaleFinished != c.inhaleFinished ||
            p.inhaleFailed != c.inhaleFailed ||
            p.progress != c.progress,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(
              context: context,
              onBackClicked: () {
                context.read<PracticeTestInhaleCubit>().cancelTest();
                Navigator.of(context).maybePop();
              },
            ),
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _BuildView(
                  key: ValueKey(
                    "${state.startCounterStarted}-"
                    "${state.startCounterFinished}-"
                    "${state.inhaleStarted}-"
                    "${state.inhaleFinished}-"
                    "${state.inhaleFailed}",
                  ),
                  state: state,
                  settings: settings,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _BuildView extends StatelessWidget {
  final PracticeTestInhaleState state;
  final BreathingSettings settings;

  const _BuildView({
    super.key,
    required this.state,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.startCounterFinished) {
      return PracticeTestStartCounterScreen(state: state);
    }

    if (state.startCounterFinished && !state.inhaleFailed) {
      return PracticeTestInhaleProgressScreen(
        state: state,
        breathingSettings: settings,
      );
    }

    if (state.inhaleFailed) {
      final msg = state.inhaleFailReason.trim().isNotEmpty
          ? state.inhaleFailReason.trim()
          : "Test failed.";

      return InhaleFailed(
        text: msg,
        onStartAgain: () {
          context.read<PracticeTestInhaleCubit>().restartAfterFailWithPercent();
        },
      );
    }

    return SizedBox.shrink();
  }
}

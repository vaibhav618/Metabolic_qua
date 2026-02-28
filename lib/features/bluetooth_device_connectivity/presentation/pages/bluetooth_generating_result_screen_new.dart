import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../data/repository/bluetooth_repository.dart';
import '../../data/repository/generating_result_repository.dart';
import '../../domain/params/result_screen_params.dart';
import '../cubit/bluetooth_generating_result_cubit_new/bluetooth_generating_result_cubit.dart';
import '../cubit/bluetooth_generating_result_cubit_new/bluetooth_generating_result_state.dart';

class BluetoothGeneratingResultScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;
  final double minRange;
  final double maxRange;

  const BluetoothGeneratingResultScreen({
    super.key,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  State<BluetoothGeneratingResultScreen> createState() =>
      _BluetoothGeneratingResultScreenState();
}

class _BluetoothGeneratingResultScreenState
    extends State<BluetoothGeneratingResultScreen> {
  late final BluetoothGeneratingResultCubit _cubit;
  bool _navigated = false;
  bool _showTurningOffBar = false;

  late final TextStyle _titleStyle;
  late final TextStyle _barStyle;

  @override
  void initState() {
    super.initState();

    _titleStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: -2.04,
    );

    _barStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -0.72,
    );

    _cubit = BluetoothGeneratingResultCubit(
      repo: context.read<BluetoothRepository>(),
      repository: context.read<GeneratingResultRepository>(),
      maxPressure: widget.maxPressure,
      bestPressure: widget.bestPressure,
      blowDuration: widget.blowDuration,
      blowValuesList: widget.blowValuesList,
      clientProfileModel: widget.clientProfileModel,
      dietPlanStrategyModel: widget.dietPlanStrategyModel,
      minRange: widget.minRange,
      maxRange: widget.maxRange,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _handleNavigationLogic(
      BuildContext context, BluetoothGeneratingResultState state) {
    if (state.isTimedOut) return;

    // 🔥 FIXED CONDITION
    final waitingForDeviceData =
        state.completedSteps < 2 &&
            !state.navigateToResultScreen &&
            !state.isTimedOut;

    if (!state.isBluetoothConnected &&
        !_navigated &&
        waitingForDeviceData) {
      _navigated = true;

      showDeviceDisconnectedBox(
        context: context,
        onButtonPressed: () {
          if (!mounted) return;
          _cubit.dialogDismissed();
          context.go(
            AppRoutes.clientDashboard,
            extra: widget.clientProfileModel,
          );
        },
      );
      return;
    }

    if (state.navigateToResultScreen && !_navigated) {
      _navigated = true;


      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _cubit.sendAbort();
        setState(() => _showTurningOffBar = true);
        _cubit.resetNavigationFlag();

        context.go(
          AppRoutes.dietitianResultScreen,
          extra: ResultScreenParamsNew(
            clientProfileModel: widget.clientProfileModel,
            result: state.dietitianResult!,
          ),
        );
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<
          BluetoothGeneratingResultCubit,
          BluetoothGeneratingResultState>(
        listenWhen: (prev, next) =>
        prev.isTimedOut != next.isTimedOut ||
            prev.isDialogShown != next.isDialogShown ||
            prev.navigateToResultScreen != next.navigateToResultScreen,
        listener: _handleNavigationLogic,
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              leading: const SizedBox.shrink(),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Generating result...",
                            textAlign: TextAlign.center,
                            style: _titleStyle,
                          ),
                        ),
                        const SizedBox(height: 20),
                        RepaintBoundary(
                          child: Image.asset(
                            'assets/images/gif_images/gif_generating_result.gif',
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RepaintBoundary(
                    child: _TurningOffBar(
                      isVisible: _showTurningOffBar,
                      textStyle: _barStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TurningOffBar extends StatelessWidget {
  final bool isVisible;
  final TextStyle textStyle;

  const _TurningOffBar({
    required this.isVisible,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isVisible
            ? Container(
          key: const ValueKey('bar_on'),
          decoration: const BoxDecoration(
            color: Color(0xFFE1E6ED),
          ),
          alignment: Alignment.center,
          child: Text(
            "Turning off device...",
            style: textStyle,
          ),
        )
            : const SizedBox(key: ValueKey('bar_off')),
      ),
    );
  }
}
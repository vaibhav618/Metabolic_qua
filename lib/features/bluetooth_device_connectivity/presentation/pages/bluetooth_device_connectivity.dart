import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/dialogs/bluetooth_enable_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/device_section.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../common/dialogs/device_inhale_or_exhale_mode.dart';
import '../../../../common/dialogs/device_low_battery.dart';

class BluetoothDeviceConnectivity extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final bool isTestTaken;

  const BluetoothDeviceConnectivity({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange, required this.isTestTaken,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => BluetoothConnectionCubit(ctx.read<BluetoothRepository>())
        ..init(),
      child: _BluetoothDeviceConnectivityView(
        clientProfileModel: clientProfileModel,
        dietPlanStrategyModel: dietPlanStrategyModel,
        minRange: minRange,
        maxRange: maxRange, isTestTaken: isTestTaken,
      ),
    );
  }
}

class _BluetoothDeviceConnectivityView extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final bool isTestTaken;

  const _BluetoothDeviceConnectivityView({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange, required this.isTestTaken,
  });

  @override
  State<_BluetoothDeviceConnectivityView> createState() =>
      __BluetoothDeviceConnectivityViewState();
}

class __BluetoothDeviceConnectivityViewState
    extends State<_BluetoothDeviceConnectivityView> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        final cubit = context.read<BluetoothConnectionCubit>();
        cubit.sendAbort();
        _navigateToDashboard();
      },
      child: StreamBuilder<fbp.BluetoothAdapterState>(
        stream: fbp.FlutterBluePlus.adapterState,
        initialData: fbp.BluetoothAdapterState.unknown,
        builder: (context, snapshot) {
          final adapterState = snapshot.data;

          if (adapterState == fbp.BluetoothAdapterState.unknown) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF308BF9)),
              ),
            );
          }

          if (adapterState != fbp.BluetoothAdapterState.on && !_dialogShown) {
            _dialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showBluetoothEnableDialog(
                context: context,
                onButtonPressed: () {
                  fbp.FlutterBluePlus.turnOn();
                },
              ).then((_) => _dialogShown = false);
            });
          }

          if (adapterState == fbp.BluetoothAdapterState.on && _dialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              _dialogShown = false;
            });
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () async {
                    final cubit = context.read<BluetoothConnectionCubit>();
                    cubit.sendAbort();
                    _navigateToDashboard();
                  },
                  icon: SvgPicture.asset("assets/images/common/closeicon.svg"),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: BlocListener<BluetoothConnectionCubit, BluetoothConnectionState>(
                listenWhen: (prev, curr) =>
                prev.isDeviceError != curr.isDeviceError ||
                    prev.textError != curr.textError ||
                    prev.deviceIsInhaleOrExhaleMode != curr.deviceIsInhaleOrExhaleMode ||
                    prev.isReconnecting != curr.isReconnecting ||
                    prev.linkMessage != curr.linkMessage,

                listener: (context, state) async {
                  if(state.deviceIsInhaleOrExhaleMode){

                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => WillPopScope(
                        onWillPop: () async => false,
                        child: DeviceInhaleOrExhaleMode(
                          onOk: (){
                            final cubit = context.read<BluetoothConnectionCubit>();
                            UuidBluetoothManager().clearAllConnections();
                            _navigateToDashboard();
                          },
                        ),
                      ),
                    );
                  }
                  if (state.isDeviceError && state.textError=="LOW_BATTERY") {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => WillPopScope(
                        onWillPop: () async => false,
                        child: DeviceLowBattery(
                          message: state.textError ?? '',
                          onOk: (){
                            final cubit = context.read<BluetoothConnectionCubit>();
                            cubit.sendAbort();
                            _navigateToDashboard();
                          },
                        ),
                      ),
                    );
                  }
                },
                child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
                  builder: (context, state) {
                    if (adapterState != fbp.BluetoothAdapterState.on) {
                      return _bluetoothOffUI();
                    }
                    return DeviceSection(state: state);
                  },
                ),
              ),
            ),
            bottomNavigationBar: _bottomButton(),
          );
        },
      ),
    );
  }

  Widget _bottomButton() {
    return SafeArea(
      top: false,
      child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
        builder: (context, state) {
          final isReady = state.deviceReady == true;

          final canStart = state.isConnected && isReady;

          String buttonText;
          if (!state.isConnected && state.isScanning) {
            buttonText = "Start";
          } else if (state.isConnected && !isReady) {
            buttonText = "Checking device...";
          } else {
            buttonText = "Start";
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canStart
                    ? () {
                  if(widget.isTestTaken){
                    context.go(
                      AppRoutes.retakeTestScreen,
                      extra: {
                        "client": widget.clientProfileModel,
                        "strategy": widget.dietPlanStrategyModel,
                        "min_range": widget.minRange,
                        "max_range": widget.maxRange,
                      },
                    );
                  }else{
                    context.push(
                      AppRoutes.bluetoothCalibrationScreen,
                      extra: {
                        "client": widget.clientProfileModel,
                        "strategy": widget.dietPlanStrategyModel,
                        "min_range": widget.minRange,
                        "max_range": widget.maxRange,
                      },
                    );
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  backgroundColor: canStart
                      ? const Color(0xFF308BF9)
                      : const Color(0xFFD9D9D9),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    color: canStart ? Colors.white : const Color(0xFF959595),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bluetoothOffUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/device_connection/bluetooth_disconnected.svg",
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(
            'Bluetooth is Off',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please enable Bluetooth to connect a device',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {

    context.go(
      AppRoutes.clientDashboard,
      extra: widget.clientProfileModel,
    );
  }
}

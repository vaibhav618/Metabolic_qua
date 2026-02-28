import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/dialogs/bluetooth_enable_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/device_low_battery.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/device_section.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/bloc/practice_flow_bloc.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/domain/enums/practice_test.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class PracticeTestBluetoothDeviceConnectivity extends StatelessWidget {
  final ClientProfileModel clientProfileModel;

  const PracticeTestBluetoothDeviceConnectivity({
    super.key,
    required this.clientProfileModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          BluetoothConnectionCubit(ctx.read<BluetoothRepository>())..init(),
      child: _BluetoothDeviceConnectivityView(
          clientProfileModel: clientProfileModel),
    );
  }
}

class _BluetoothDeviceConnectivityView extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const _BluetoothDeviceConnectivityView({
    required this.clientProfileModel,
  });

  @override
  State<_BluetoothDeviceConnectivityView> createState() =>
      _BluetoothDeviceConnectivityViewState();
}

class _BluetoothDeviceConnectivityViewState
    extends State<_BluetoothDeviceConnectivityView> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fbp.BluetoothAdapterState>(
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
            final nav = Navigator.of(context, rootNavigator: true);
            if (nav.canPop()) nav.pop();
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
                onPressed: () {
                  context.read<BluetoothConnectionCubit>().sendAbort();
                  _navigateToDashboard(context);
                },
                icon: SvgPicture.asset("assets/images/common/closeicon.svg"),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocListener<BluetoothConnectionCubit,
                BluetoothConnectionState>(
              listenWhen: (prev, curr) =>
                  prev.isDeviceError != curr.isDeviceError ||
                  prev.textError != curr.textError,
              listener: (context, state) async {
                if (state.isDeviceError && state.textError == "LOW_BATTERY") {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => WillPopScope(
                      onWillPop: () async => false,
                      child: DeviceLowBattery(
                        message: state.textError ?? '',
                        onOk: () {
                          context.read<BluetoothConnectionCubit>().sendAbort();
                          _navigateToDashboard(context);
                        },
                      ),
                    ),
                  );
                }
              },
              child: BlocBuilder<BluetoothConnectionCubit,
                  BluetoothConnectionState>(
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
    );
  }

  Widget _bottomButton() {
    return SafeArea(
      top: false,
      child: BlocBuilder<BluetoothConnectionCubit, BluetoothConnectionState>(
        builder: (context, state) {
          final isReady = state.deviceReady == true;
          final canStart = state.isConnected && isReady;

          final buttonText = (!state.isConnected && state.isScanning)
              ? "Start"
              : (state.isConnected && !isReady)
                  ? "Checking device..."
                  : "Start";

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canStart
                    ? () {
                        context.read<PracticeFlowBloc>().add(
                              PracticeFlowMarkCompleted(
                                  PracticeTestSteps.connect),
                            );
                        context.pop();
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

  void _navigateToDashboard(BuildContext context) {
    // This ensures we go straight back to the dashboard and pass the required data
    context.go(
      AppRoutes.clientDashboard,
      extra: widget.clientProfileModel,
    );
  }
}

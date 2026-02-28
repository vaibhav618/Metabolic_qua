import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import '../../../../../core/size/get_height.dart';

class StartDeviceScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const StartDeviceScreen({super.key, required this.clientProfileModel});

  @override
  State<StartDeviceScreen> createState() => _StartDeviceScreenState();
}

class _StartDeviceScreenState extends State<StartDeviceScreen> with WidgetsBindingObserver {
  StreamSubscription<BluetoothAdapterState>? _btSub;
  BluetoothAdapterState _btState = BluetoothAdapterState.unknown;

  bool _dialogOpen = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _btSub = FlutterBluePlus.adapterState.listen((s) {
      _btState = s;

      if (_dialogOpen && s == BluetoothAdapterState.on) {
        _closeDialogIfOpen();
        _goNext();
      }
    });

    FlutterBluePlus.adapterState.first.then((s) {
      _btState = s;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _btSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _dialogOpen) {
      _recheckIfOn();
    }
  }

  Future<void> _onOkPressed() async {
    if (_checking) return;
    setState(() => _checking = true);

    try {
      final s = await FlutterBluePlus.adapterState.first;
      _btState = s;

      if (!mounted) return;

      if (s == BluetoothAdapterState.on) {
        _goNext();
        return;
      }

      if (Platform.isAndroid) {
        await _showAndroidTurnOnDialog();
      } else {
        await _showIosWaitDialog();
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _recheckIfOn() async {
    final s = await FlutterBluePlus.adapterState.first;
    _btState = s;

    if (!mounted) return;

    if (_dialogOpen && s == BluetoothAdapterState.on) {
      _closeDialogIfOpen();
      _goNext();
    }
  }

  Future<void> _showAndroidTurnOnDialog() async {
    if (!mounted || _dialogOpen) return;
    _dialogOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final r16 = rh(context: ctx, px: 16);
        final fs16 = rh(context: ctx, px: 16);
        final fs13 = rh(context: ctx, px: 13);

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
            title: Text(
              "Turn on Bluetooth",
              style: GoogleFonts.poppins(
                fontSize: fs16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF252525),
              ),
            ),
            content: StreamBuilder<BluetoothAdapterState>(
              stream: FlutterBluePlus.adapterState,
              initialData: _btState,
              builder: (_, snap) {
                final s = snap.data ?? BluetoothAdapterState.unknown;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bluetooth is off. Turn it on to continue.",
                      style: GoogleFonts.poppins(
                        fontSize: fs13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF252525),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s == BluetoothAdapterState.on
                                ? "Bluetooth is ON"
                                : "Waiting for Bluetooth to turn ON...",
                            style: GoogleFonts.poppins(
                              fontSize: fs13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF252525),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FlutterBluePlus.turnOn();
                  } catch (_) {
                    await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF252525),
                ),
                child: Text(
                  "Turn On",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _dialogOpen = false;
  }

  Future<void> _showIosWaitDialog() async {
    if (!mounted || _dialogOpen) return;
    _dialogOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final r16 = rh(context: ctx, px: 16);
        final fs16 = rh(context: ctx, px: 16);
        final fs13 = rh(context: ctx, px: 13);

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
            title: Text(
              "Turn on Bluetooth",
              style: GoogleFonts.poppins(
                fontSize: fs16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF252525),
              ),
            ),
            content: StreamBuilder<BluetoothAdapterState>(
              stream: FlutterBluePlus.adapterState,
              initialData: _btState,
              builder: (_, snap) {
                final s = snap.data ?? BluetoothAdapterState.unknown;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bluetooth is off. Please enable it to continue.",
                      style: GoogleFonts.poppins(
                        fontSize: fs13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF252525),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s == BluetoothAdapterState.on
                                ? "Bluetooth is ON"
                                : "Waiting for Bluetooth to turn ON...",
                            style: GoogleFonts.poppins(
                              fontSize: fs13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF252525),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF252525),
                ),
                child: Text(
                  "Open Settings",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _dialogOpen = false;
  }

  void _closeDialogIfOpen() {
    if (!_dialogOpen) return;
    _dialogOpen = false;
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _goNext() {

  }

  @override
  Widget build(BuildContext context) {
    final p20 = rh(context: context, px: 20);
    final s22 = rh(context: context, px: 22);
    final fs25 = rh(context: context, px: 25);
    final fs15 = rh(context: context, px: 15);
    final h61 = rh(context: context, px: 61);
    final r50 = rh(context: context, px: 50);
    final lsNeg1 = rh(context: context, px: -1);
    final ls03 = rh(context: context, px: 0.30);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              size: s22,
              color: const Color(0xFF252525),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(p20),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Image.asset(
                  "assets/images/device_connection/start_device.png",
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Start by turning on\nyour device",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: fs25,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: lsNeg1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: h61,
                      child: ElevatedButton(
                        onPressed: (){
                          context.go(
                            '${AppRoutes.practiceFlowShell}/${AppRoutes.practiceTestConnectivity}',
                            extra: widget.clientProfileModel
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF252525),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r50),
                          ),
                        ),
                        child: _checking
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : Text(
                          "Ok, got it",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: fs15,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: ls03,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

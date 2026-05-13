import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';

import '../../domain/processor/ota_processor.dart';
import 'device_update_state.dart';

class DeviceUpdateCubit extends Cubit<DeviceUpdateState> {
  final BluetoothRepository repo;

  StreamSubscription<String>? _dataSub;
  StreamSubscription<bool>? _connSub;
  Timer? _bootloaderTimeout;

  StreamSubscription<List<int>>? _directRawSub;
  StreamController<List<int>>? _rawBuffer;

  OtaProcessor? _otaProcessor;

  bool _bootloaderRequested = false; // 🚨 Added this flag

  DeviceUpdateCubit({required this.repo}) : super(const DeviceUpdateState()) {
    _listenToBluetooth();
  }

  void _log(String direction, String message) {
    if (kDebugMode) {
      print("[OTA_LINK] $direction $message");
    }
  }

  void _listenToBluetooth() {
    _connSub = repo.connectionStatusStream().listen((connected) {
      if (isClosed) return;

      if (connected) {
        // 🚨 HARDWARE TIMEOUT FIX 🚨
        // The millisecond we connect, we MUST check the version.
        // Do not wait for the UI to ask. If we wait, the device turns Green and locks us out.
        _log("SYS",
            "Device Connected. Instantly checking version to beat Green Light timeout...");
        checkForUpdate();
      } else {
        if (state.status != DeviceUpdateStatus.success) {
          _log("SYS", "Device disconnected unexpectedly.");
          _otaProcessor?.abort();
          emit(state.copyWith(
            status: DeviceUpdateStatus.error,
            errorMessage: "Device disconnected.",
          ));
        }
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (isClosed || data.isEmpty) return;

      final cleanData = data.trim();

      if (!cleanData.contains('ª')) {
        _log("RX <-", "[$cleanData]");
      }

      // Ignore hardware noise/errors that aren't relevant to OTA
      if (cleanData.contains("ERROR")) return;

      // -------------------------------------------------------------
      // 🚨 FIX: GLOBAL BOOTLOADER CATCH (Moved OUTSIDE the version check)
      // If the device sends '%' at ANY time, it is in the bootloader.
      // -------------------------------------------------------------
      if (cleanData.contains('%') || cleanData.contains('OTA_READY')) {
        if (_bootloaderRequested &&
            state.status != DeviceUpdateStatus.flashing) {
          _log("SYS", "🚨 Device is stuck in Bootloader! Triggering Flash...");

          _bootloaderTimeout?.cancel();
          emit(state.copyWith(
              status: DeviceUpdateStatus.flashing, progress: 0.0));
          _startBinaryFlash();
        } else if (!_bootloaderRequested) {
          _log("SYS",
              "Ignoring random bootloader signal. We didn't request it.");
        }
        return; // Stop processing this packet further
      }

      // -------------------------------------------------------------
      // STANDARD VERSION CHECK
      // -------------------------------------------------------------
      if (state.status == DeviceUpdateStatus.checkingVersion) {
        if (cleanData.contains(RegExp(r'\d+\.\d+\.\d+'))) {
          _processDeviceVersion(cleanData);
        }
      }
    });
  }

  void checkForUpdate() {
    if (!repo.isConnected || isClosed) return; // 🚨 Safety Fix

    _bootloaderRequested = false;

    emit(state.copyWith(status: DeviceUpdateStatus.checkingVersion));
    _log("TX ->", '[" ] (Requesting Firmware Version)');
    repo.sendData('"');

    // 🚨 Reduced to 3 seconds. If it takes longer, the device is turning Green anyway.
    Timer(const Duration(seconds: 3), () {
      if (!isClosed && state.status == DeviceUpdateStatus.checkingVersion) {
        // 🚨 Safety Fix
        _log("SYS", "Version check timed out. Assuming up to date.");
        emit(state.copyWith(status: DeviceUpdateStatus.upToDate));
      }
    });
  }

  Future<void> _processDeviceVersion(String deviceVersion) async {
    _log("SYS", "Device reports version: $deviceVersion");

    // 🚨 Removed 500ms delay to instantly update UI and beat the timeout
    if (isClosed) return; // 🚨 Safety Fix

    String latestServerVersion = "v1.0.2";

    if (deviceVersion != latestServerVersion) {
      _log("SYS", "Update required! $deviceVersion -> $latestServerVersion");
      emit(state.copyWith(
        status: DeviceUpdateStatus.updateAvailable,
        currentVersion: deviceVersion,
        latestVersion: latestServerVersion,
      ));
    } else {
      _log("SYS", "Device is up to date.");
      emit(state.copyWith(
        status: DeviceUpdateStatus.upToDate,
        currentVersion: deviceVersion,
      ));
    }
  }

  void startUpdateSequence() {
    if (!repo.isConnected || isClosed) return; // 🚨 Safety Fix

    _bootloaderRequested = true;

    emit(state.copyWith(status: DeviceUpdateStatus.enteringBootloader));
    _log("TX ->", '[- ] (Commanding device to enter bootloader)');
    repo.sendData('-');

    _bootloaderTimeout?.cancel();
    _bootloaderTimeout = Timer(const Duration(seconds: 10), () {
      if (!isClosed && state.status == DeviceUpdateStatus.enteringBootloader) {
        // 🚨 Safety Fix
        _log("SYS", "FATAL: Device never sent OTA_READY.");
        emit(state.copyWith(
          status: DeviceUpdateStatus.error,
          errorMessage: "Failed to enter update mode. Please restart device.",
        ));
      }
    });
  }

  Future<void> _startBinaryFlash() async {
    try {
      ByteData fwData =
          await rootBundle.load('assets/firmware/SLOTB_MAIN.ino.bin');
      List<int> firmwareBytes = fwData.buffer.asUint8List();

      final bleManager = UuidBluetoothManager();

      // 🚨 FLUTTER FIX: We don't need a custom rawBuffer anymore.
      // We pass the manager's rawDataStream directly to the processor!
      _otaProcessor = OtaProcessor(
        writeRawData: (data) async {
          // Add await here so the pacing in OtaProcessor works perfectly
          await bleManager.writeRaw(data);
        },
        rawDataStream: bleManager.rawDataStream, // 🚀 Direct connection!
        onProgress: (progress) {
          if (!isClosed) {
            emit(state.copyWith(progress: progress));
          }
        },
        onLog: (msg) => _log("OTA_PROC", msg),
        onSuccess: () {
          Future.microtask(() {
            if (!isClosed) {
              _bootloaderRequested = false;
              emit(state.copyWith(
                  status: DeviceUpdateStatus.success, progress: 1.0));
            }
          });
        },
        onError: (err) {
          if (!isClosed) {
            // 🚨 THE SLOT SWAP FIX 🚨
            // If the error is a known slot swap, DO NOT show an error screen.
            // Just log it and let Auto-Reconnect handle it.
            if (err == "SLOT_SWAP_REBOOT") {
              _log("SYS",
                  "Device swapping slots. Waiting for auto-reconnect...");
            } else {
              _bootloaderRequested = false;
              emit(state.copyWith(
                  status: DeviceUpdateStatus.error, errorMessage: err));
            }
          }
        },
      );

      // Start the flash!
      await _otaProcessor!.startFlash(firmwareBytes);
    } catch (e) {
      if (!isClosed) {
        _bootloaderRequested = false;
        _log("SYS", "Failed to load firmware file: $e");
        emit(state.copyWith(
          status: DeviceUpdateStatus.error,
          errorMessage: "Could not load firmware file.",
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _directRawSub?.cancel();
    _rawBuffer?.close();
    _otaProcessor?.dispose();
    _dataSub?.cancel();
    _connSub?.cancel();
    _bootloaderTimeout?.cancel();
    return super.close();
  }
}

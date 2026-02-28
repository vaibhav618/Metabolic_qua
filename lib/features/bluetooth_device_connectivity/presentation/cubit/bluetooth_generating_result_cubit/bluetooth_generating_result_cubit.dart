import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit/bluetooth_generating_result_state.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class BluetoothGeneratingResultCubit extends Cubit<BluetoothGeneratingResultState> {
  final BluetoothRepository repo;
  final double maxPressure;
  final double bestPressure;
  final int blowDuration;
  final List<double> blowValuesList;
  final ClientProfileModel clientProfileModel;
  final double minRange;
  final double maxRange;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final GeneratingResultRepository repository;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool _disposed = false;
  bool _isGeneratingResult = false;
  bool _isProcessing = false;

  final StringBuffer _rawBuffer = StringBuffer();
  String _rawData = "";

  // ✅ NEW: timer
  static const int _timeoutSeconds = 300;
  Timer? _timeoutTimer;
  int _remainingSeconds = _timeoutSeconds;

  BluetoothGeneratingResultCubit({
    required this.repo,
    required this.maxPressure,
    required this.bestPressure,
    required this.blowDuration,
    required this.blowValuesList,
    required this.clientProfileModel,
    required this.repository,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  }) : super(const BluetoothGeneratingResultState()) {
    _init();
  }

  void _init() {
    _connSub = repo.connectionStatusStream().listen(_handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(_onBluetoothDataReceived);

    // ✅ NEW: start 5 min countdown as soon as screen/cubit opens
    _startTimeoutTimer();

    if (repo.isConnected) {
      _handleBluetoothConnection(true);
    }
  }

  // ✅ NEW: timer tick
  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _remainingSeconds = _timeoutSeconds;

    // push initial value (05:00)
    emit(state.copyWith(remainingSeconds: _remainingSeconds, isTimedOut: false));

    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_disposed) {
        t.cancel();
        return;
      }

      _remainingSeconds--;

      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        emit(state.copyWith(remainingSeconds: 0));
        t.cancel();
        _handleTimeout();
        return;
      }

      emit(state.copyWith(remainingSeconds: _remainingSeconds));
    });
  }

  // ✅ NEW: timeout action
  void _handleTimeout() {
    if (_disposed) return;

    // abort device & stop further processing
    sendAbort();

    emit(state.copyWith(
      isTimedOut: true,
      textError: "Timeout: 5 minutes exceeded",
    ));

    _stop(); // stop streams so process stops
  }

  // ✅ NEW: stop timer when leaving successfully
  void _stopTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  Future<void> _handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected && !_isGeneratingResult) {
      _isGeneratingResult = true;
      emit(state.copyWith(completedSteps: 1));
      _triggerAnalysis();
    } else if (!connected && !state.isDialogShown) {
      _showDisconnectedDialog();
    }
  }

  Future<void> fetchDietitianResult({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
    required double minRange,
    required double maxRange,
  }) async {
    try {
      final result = await repository.fetchResults(
        acetone: acetone,
        ethanol: ethanol,
        hydrogen: hydrogen,
        diabetic: diabetic,
        goal: goal,
        dietitianId: dietitianId,
        profileId: profileId,
        dietPlanId: dietPlanId,
        minRange: minRange,
        maxRange: maxRange,
      );

      emit(state.copyWith(dietitianResult: result, textError: null));
    } catch (e) {
      emit(state.copyWith(textError: e.toString()));
    }
  }

  void _triggerAnalysis() {
    if (_disposed) return;

    try {
      repo.sendData("/");
      if (kDebugMode) print("📤 Sent '/' to BLE for triggering analysis");
    } catch (e) {
      if (kDebugMode) print("⚠️ Error sending trigger to BLE: $e");
    }
  }

  void _onBluetoothDataReceived(String data) {
    if (data.isEmpty || _disposed) return;

    _rawBuffer.write(data);
    _rawData += data;

    if (kDebugMode) {
      print("📥 BLE Received Fragment: $data");
      print("🔎 Accumulated Raw Data: $_rawData");
    }

    if (_rawData.contains("*")) {
      final cleaned = _rawBuffer.toString().replaceFirst(
        RegExp(r'^analize'),
        '',
      );
      _processFinalData(cleaned.trim());
      _rawBuffer.clear();
      _rawData = "";
    }
  }

  Future<void> _processFinalData(String rawData) async {
    if (_isProcessing || _disposed) return;
    _isProcessing = true;

    try {
      emit(state.copyWith(completedSteps: 2));
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(completedSteps: 3));
      await Future.delayed(const Duration(seconds: 1));

      String cleaned = rawData
          .replaceAll(RegExp(r'\{.*?\}'), '')
          .replaceAll(RegExp(r'analize', caseSensitive: false), '')
          .replaceAll('*', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '')
          .trim();

      cleaned = cleaned.replaceAll(RegExp(r'\${2,}'), '\$');

      if (kDebugMode) {
        print("🎯 Cleaned BLE Test Data: $cleaned");
      }

      final replaced = cleaned
          .replaceAll("Best_pr", bestPressure.toStringAsFixed(0))
          .replaceAll("MAXPR", maxPressure.toStringAsFixed(0))
          .replaceAll("BDur", blowDuration.toString());

      if (kDebugMode) {
        print("✅ Final Test Data Ready for API: $replaced");
      }

      final apiResponse = await _callProcessRawDataApi(replaced);

      if (apiResponse != null) {
        final acetone = (apiResponse['acetone'] as num?)?.toDouble() ?? 0;
        final ethanol = (apiResponse['ethanol'] as num?)?.toDouble() ?? 0;
        final hydrogen = (apiResponse['hydrogen'] as num?)?.toDouble() ?? 0;

        emit(
          state.copyWith(
            acetone: acetone,
            ethanol: ethanol,
            hydrogen: hydrogen,
          ),
        );

        await fetchDietitianResult(
          acetone: acetone,
          ethanol: ethanol,
          hydrogen: hydrogen,
          diabetic: dietPlanStrategyModel.isDiabetic,
          goal: "fat_loss",
          dietitianId: clientProfileModel.dietitianId,
          profileId: clientProfileModel.profileId,
          dietPlanId: dietPlanStrategyModel.id.toString(),
          minRange: minRange,
          maxRange: maxRange,
        );

        // ✅ NEW: stop timer once we are navigating
        _stopTimeoutTimer();

        emit(state.copyWith(navigateToResultScreen: true));
      } else {
        emit(state.copyWith(textError: "API response invalid"));
      }
    } catch (e) {
      emit(state.copyWith(textError: "Error while processing results: $e"));
    } finally {
      _isProcessing = false;
    }
  }

  void resetNavigationFlag() {
    emit(state.copyWith(navigateToResultScreen: false));
  }

  Future<Map<String, dynamic>?> _callProcessRawDataApi(String testData) async {
    const String apiUrl =
        "https://humorstech.com/dietitian/api/app/process_raw_data.php";

    try {
      final blowValues = blowValuesList.join(", ");

      final body = {
        'testdata': testData,
        'subid': "${clientProfileModel.dietitianId}\$${clientProfileModel.profileId}",
        'gender': clientProfileModel.gender,
        'age': clientProfileModel.age.toString(),
        'height': clientProfileModel.height.toString(),
        'blow_region': 'south_indian',
        'blow_raw_values': blowValues,
        'diet_plan_id': dietPlanStrategyModel.id.toString(),
      };

      if (kDebugMode) {
        print("--------------------------------------------------");
        print("📡 Sending API Request to: $apiUrl");
        print("📤 POST Parameters:");
        body.forEach((key, value) {
          print("   ➤ $key : $value");
        });
        print("--------------------------------------------------");
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );

      if (kDebugMode) {
        print("🌐 API Response Status: ${response.statusCode}");
        print("🌐 API Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["status"] == "success" && decoded["data"] != null) {
          final data = decoded["data"];
          return {
            "acetone": data["AcetonePpm"],
            "ethanol": data["ethanolPpm"],
            "hydrogen": data["H2Ppm"],
          };
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) print("⚠️ API Error: $e");
      return null;
    }
  }

  void _showDisconnectedDialog() {
    emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (_disposed) return;
    emit(state.copyWith(isDialogShown: false));
  }

  void sendAbort() {
    repo.sendData("&");
  }

  void _stop() {
    _disposed = true;

    // ✅ NEW
    _stopTimeoutTimer();

    _connSub?.cancel();
    _dataSub?.cancel();
    _connSub = null;
    _dataSub = null;
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}

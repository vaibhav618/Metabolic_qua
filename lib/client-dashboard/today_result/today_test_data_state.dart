import 'package:equatable/equatable.dart';
import '../../features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

enum TestDataStatus { initial, loading, success, empty, failure }

class TestDataState extends Equatable {
  final TestDataStatus status;
  final GeneratingResultModel? result;
  final String? errorMessage;

  // ✅ NEW
  final DateTime? activeDate;

  const TestDataState({
    this.status = TestDataStatus.initial,
    this.result,
    this.errorMessage,
    this.activeDate,
  });

  // ✅ Sentinel to differentiate "not provided" vs "explicitly null"
  static const Object _noValue = Object();

  TestDataState copyWith({
    TestDataStatus? status,
    Object? result = _noValue, // ✅ changed type
    String? errorMessage,
    DateTime? activeDate,
  }) {
    return TestDataState(
      status: status ?? this.status,
      result: result == _noValue
          ? this.result
          : result as GeneratingResultModel?, // ✅ allows null
      errorMessage: errorMessage ?? this.errorMessage,
      activeDate: activeDate ?? this.activeDate,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage, activeDate];
}

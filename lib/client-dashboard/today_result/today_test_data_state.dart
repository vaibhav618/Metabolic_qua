import 'package:equatable/equatable.dart';

import '../../features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

enum TestDataStatus { initial, loading, success, empty, failure }

class TestDataState extends Equatable {
  final TestDataStatus status;
  final GeneratingResultModel? result;
  final String? errorMessage;

  const TestDataState({
    this.status = TestDataStatus.initial,
    this.result,
    this.errorMessage,
  });

  TestDataState copyWith({
    TestDataStatus? status,
    GeneratingResultModel? result,
    String? errorMessage,
  }) {
    return TestDataState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}

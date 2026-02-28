import 'package:equatable/equatable.dart';

import '../data/models/latest_test_data.dart';

sealed class LatestTestState extends Equatable {
  const LatestTestState();
  @override
  List<Object?> get props => [];
}

class LatestTestInitial extends LatestTestState {}

class LatestTestLoading extends LatestTestState {}

class LatestTestLoaded extends LatestTestState {
  final LatestTestData? data; // ✅ can be null
  const LatestTestLoaded(this.data);

  bool get hasData => data != null;

  @override
  List<Object?> get props => [data, hasData];
}

class LatestTestError extends LatestTestState {
  final String message;
  const LatestTestError(this.message);

  @override
  List<Object?> get props => [message];
}

// lib/features/metabolism_test/bloc/test_data_state.dart
import 'package:equatable/equatable.dart';
import '../data/models/test_data_record.dart';

abstract class TestDataState extends Equatable {
  const TestDataState();
  @override
  List<Object?> get props => [];
}

class TestDataInitial extends TestDataState {}

class TestDataLoading extends TestDataState {}

class TestDataLoaded extends TestDataState {
  final List<TestDataRecord> records;
  const TestDataLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class TestDataEmpty extends TestDataState {}

class TestDataError extends TestDataState {
  final String message;
  const TestDataError(this.message);
  @override
  List<Object?> get props => [message];
}

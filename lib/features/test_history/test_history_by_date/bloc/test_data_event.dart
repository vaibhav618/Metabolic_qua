// lib/features/metabolism_test/bloc/test_data_event.dart
import 'package:equatable/equatable.dart';

abstract class TestDataEvent extends Equatable {
  const TestDataEvent();
  @override
  List<Object?> get props => [];
}

class FetchTestData extends TestDataEvent {
  final String profileId;
  final DateTime date;
  const FetchTestData({required this.profileId, required this.date});

  @override
  List<Object?> get props => [profileId, date];
}

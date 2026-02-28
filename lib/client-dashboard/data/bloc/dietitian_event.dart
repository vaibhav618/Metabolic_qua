import 'package:equatable/equatable.dart';

abstract class DietitianEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDietitian extends DietitianEvent {}

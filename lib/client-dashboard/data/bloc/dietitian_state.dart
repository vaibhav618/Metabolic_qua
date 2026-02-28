import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/dietitian_model.dart';

abstract class DietitianState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DietitianInitial extends DietitianState {}

class DietitianLoading extends DietitianState {}

class DietitianLoaded extends DietitianState {
  final DietitianModel dietitian;

  DietitianLoaded(this.dietitian);

  @override
  List<Object?> get props => [dietitian];
}

class DietitianError extends DietitianState {
  final String message;

  DietitianError(this.message);

  @override
  List<Object?> get props => [message];
}

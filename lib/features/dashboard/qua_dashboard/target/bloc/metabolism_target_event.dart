import 'package:equatable/equatable.dart';

sealed class MetabolismTargetEvent extends Equatable {
  const MetabolismTargetEvent();
  @override
  List<Object?> get props => [];
}

class FetchMetabolismTarget extends MetabolismTargetEvent {
  final int age;
  final String gender;
  final double heightCm;
  final double currentWeight;
  final bool diabetic;

  const FetchMetabolismTarget({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeight,
    required this.diabetic,
  });

  @override
  List<Object?> get props =>
      [age, gender, heightCm, currentWeight, diabetic];
}

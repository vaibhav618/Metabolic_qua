import 'package:equatable/equatable.dart';

abstract class WaterLogEvent extends Equatable {
  const WaterLogEvent();

  @override
  List<Object?> get props => [];
}

/// Load full water log history (with optional loader)
class LoadWaterLog extends WaterLogEvent {
  final String profileId;
  final double targetWaterInML;
  final bool showLoader;

  const LoadWaterLog({
    required this.profileId,
    required this.targetWaterInML,
    this.showLoader = true, // ✅ default true so old calls still work
  });

  @override
  List<Object?> get props => [profileId, targetWaterInML, showLoader];
}

/// When user taps a day chip
class SelectWaterLogDay extends WaterLogEvent {
  final int index;

  const SelectWaterLogDay(this.index);

  @override
  List<Object?> get props => [index];
}

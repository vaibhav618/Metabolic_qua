import 'package:equatable/equatable.dart';

class AudioState extends Equatable {
  final bool isMuted;
  final bool isPlaying;

  const AudioState({this.isMuted = false, this.isPlaying = false});

  AudioState copyWith({bool? isMuted, bool? isPlaying}) {
    return AudioState(
      isMuted: isMuted ?? this.isMuted,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [isMuted, isPlaying];
}

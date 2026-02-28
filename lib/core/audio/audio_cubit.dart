import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/core/audio/audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioHelper _audioHelper = AudioHelper();

  AudioCubit() : super(const AudioState());

  Future<void> toggleMute() async {
    await _audioHelper.toggleMute();
    emit(state.copyWith(isMuted: _audioHelper.isMuted));
  }

  Future<void> playInhale() async {
    _audioHelper.playInhaleAudio();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> playExhale() async {
    _audioHelper.playExhaleAudio();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> playPlaceTube() async {
    _audioHelper.playPlaceBreatheTube();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> playStartTest() async {
    _audioHelper.playStartBreathTest();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> stop() async {
    _audioHelper.stopAudio();
    emit(state.copyWith(isPlaying: false));
  }

  @override
  Future<void> close() {
    _audioHelper.dispose();
    return super.close();
  }
}

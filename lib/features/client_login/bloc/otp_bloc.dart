import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/services/check_profile_client.dart';
import '../data/services/send_otp_email.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  Timer? _timer;
  static const int _duration = 60;

  OtpBloc(int initialOtp) : super(OtpState(receivedOtp: initialOtp)) {
    on<StartTimer>(_onStartTimer);
    on<TimerTicked>(_onTimerTicked);
    on<OtpInputChanged>(_onOtpInputChanged);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
  }

  void _onStartTimer(StartTimer event, Emitter<OtpState> emit) {
    _timer?.cancel();

    // ✅ start timer fresh, also reset resend flags
    emit(state.copyWith(
      secondsRemaining: _duration,
      canResend: false,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerTicked(_duration - timer.tick));
    });
  }

  void _onTimerTicked(TimerTicked event, Emitter<OtpState> emit) {
    // ✅ If already success, stop timer & do nothing (prevents extra emits)
    if (state.isSuccess) {
      _timer?.cancel();
      return;
    }

    if (event.seconds <= 0) {
      _timer?.cancel();
      emit(state.copyWith(secondsRemaining: 0, canResend: true));
    } else {
      emit(state.copyWith(secondsRemaining: event.seconds));
    }
  }

  void _onOtpInputChanged(OtpInputChanged event, Emitter<OtpState> emit) {
    // ✅ Just update entered OTP; clear error
    emit(state.copyWith(
      enteredOtp: int.tryParse(event.code),
      errorText: null,
    ));
  }

  Future<void> _onResendOtpRequested(
      ResendOtpRequested event,
      Emitter<OtpState> emit,
      ) async {
    if (state.isResending) return;

    emit(state.copyWith(
      isResending: true,
      errorText: null,
      // ✅ reset success + profile on resend
      isSuccess: false,
      profile: null,
    ));

    try {
      final newOtpStr = (1111 + Random.secure().nextInt(8889)).toString();
      final result = await sendOtpToEmail(event.email, newOtpStr);

      if (result['success'] == true) {
        final finalOtp = int.tryParse(result['otp']?.toString() ?? '') ?? int.parse(newOtpStr);

        emit(state.copyWith(
          receivedOtp: finalOtp,
          isResending: false,
          enteredOtp: null, // optional: clear entered OTP
          errorText: null,
        ));

        add(StartTimer()); // Restart countdown
      } else {
        emit(state.copyWith(
          isResending: false,
          errorText: result['message'] ?? "Resend failed",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isResending: false,
        errorText: "Connection error",
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event,
      Emitter<OtpState> emit,
      ) async {
    // ✅ If already success, don't verify again (prevents repeated navigation)
    if (state.isSuccess) return;

    if (state.isVerifying) return;

    if (state.enteredOtp == null) {
      emit(state.copyWith(errorText: "Please enter the OTP"));
      return;
    }

    if (state.enteredOtp != state.receivedOtp) {
      emit(state.copyWith(errorText: "Invalid OTP entered"));
      return;
    }

    emit(state.copyWith(isVerifying: true, errorText: null));

    try {
      final profile = await checkClientProfile(userEmail: event.email);

      // ✅ stop timer once verified
      _timer?.cancel();

      emit(state.copyWith(
        isVerifying: false,
        isSuccess: true, // ✅ becomes true only once
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        isVerifying: false,
        errorText: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'retake_test_state.dart';

class RetakeTestCubit extends Cubit<RetakeTestState> {
  RetakeTestCubit() : super(const RetakeTestState());

  bool _computeEnabled({String? reason, String details = ""}) {
    if (reason == null) return false;
    if (reason == 'curious') return true;
    return details.trim().isNotEmpty;
  }

  void selectReason(String value) {
    final newDetails = (value == 'curious') ? '' : state.details;

    emit(
      state.copyWith(
        selectedReason: value,
        details: newDetails,
        isButtonEnabled: _computeEnabled(reason: value, details: newDetails),
        submitted: false,
      ),
    );
  }

  void updateDetails(String text) {
    emit(
      state.copyWith(
        details: text,
        isButtonEnabled: _computeEnabled(
          reason: state.selectedReason,
          details: text,
        ),
        submitted: false,
      ),
    );
  }

  void submit() {
    if (!state.isButtonEnabled) return;

    final payload = <String, dynamic>{
      "reason": state.selectedReason,
      if (state.selectedReason != 'curious' && state.details.trim().isNotEmpty)
        "details": state.details.trim(),
    };

    debugPrint("Retake payload => ${jsonEncode(payload)}");

    // ✅ JUST set true. Don't set false immediately.
    emit(state.copyWith(submitted: true));
  }

  // ✅ call this after navigation (from UI)
  void resetSubmitted() {
    emit(state.copyWith(submitted: false));
  }
}

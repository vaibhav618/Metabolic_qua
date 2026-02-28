import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/cubit/otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpState());

  void updateOtp(String otp) => emit(state.copyWith(otp: otp, error: ''));

  void startResendTimer() async {
    emit(state.copyWith(resendSeconds: 60));
    for (int i = 59; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed) return;
      emit(state.copyWith(resendSeconds: i));
    }
  }

  void resendOtp() {
    emit(state.copyWith(otp: '', error: '', isVerified: false));
    startResendTimer();
  }

  Future<void> verifyOtp() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 1)); // simulate API call

    if (state.otp == '1234') {
      emit(state.copyWith(isVerified: true, isLoading: false));
    } else {
      emit(
        state.copyWith(
          isVerified: false,
          isLoading: false,
          error: 'Invalid OTP',
        ),
      );
    }
  }
}



// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'otp_state.dart';
// import 'package:respyr_dietician/data/repository/otp_repository.dart';

// class OtpCubit extends Cubit<OtpState> {
//   final OtpRepository _otpRepository;

//   OtpCubit(this._otpRepository) : super(OtpState());

//   void updateOtp(String otp) => emit(state.copyWith(otp: otp, error: ''));

//   void startResendTimer() async {
//     emit(state.copyWith(resendSeconds: 60));
//     for (int i = 59; i >= 0; i--) {
//       await Future.delayed(const Duration(seconds: 1));
//       if (isClosed) return;
//       emit(state.copyWith(resendSeconds: i));
//     }
//   }

//   void resendOtp() {
//     emit(state.copyWith(otp: '', error: '', isVerified: false));
//     startResendTimer();
//   }

//   Future<void> verifyOtp() async {
//     emit(state.copyWith(isLoading: true));

//     try {
//       final isValid = await _otpRepository.verifyOtp(state.otp);
//       if (isValid) {
//         emit(state.copyWith(isVerified: true, isLoading: false));
//       } else {
//         emit(state.copyWith(
//           isVerified: false,
//           isLoading: false,
//           error: 'Invalid OTP',
//         ));
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         isLoading: false,
//         isVerified: false,
//         error: 'Server error. Please try again.',
//       ));
//     }
//   }
// }


// class OtpRepository {
//   Future<bool> verifyOtp(String otp) async {
//     // Replace this with your actual HTTP/API logic
//     final response = await http.post(
//       Uri.parse('https://your.api/verify-otp'),
//       body: {'otp': otp},
//     );

//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       return json['success'] == true; // or your real success condition
//     } else {
//       throw Exception('OTP verification failed');
//     }
//   }
// }

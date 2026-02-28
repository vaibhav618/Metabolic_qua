import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/create_password_screen/presentation/cubit/create_password_state.dart';

class CreatePasswordCubit extends Cubit<CreatePasswordState> {
  CreatePasswordCubit() : super(const CreatePasswordState());

  void updateNewPassword(String value) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasNum = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    final hasMin = value.length >= 6;

    final isValid = hasUpper && hasNum && hasSpecial && hasMin;

    emit(
      state.copyWith(
        newPassword: value,
        hasUppercase: hasUpper,
        hasNumber: hasNum,
        hasSpecialChar: hasSpecial,
        hasMinLength: hasMin,
        isSuccess: isValid,
        passwordMatch: value == state.confirmPassword,
        submittedSuccessfully: false,
      ),
    );
  }

  void updateConfirmPassword(String value) {
    emit(
      state.copyWith(
        confirmPassword: value,
        passwordMatch: value == state.newPassword,
        submittedSuccessfully: false,
      ),
    );
  }

  void submit() {
    emit(state.copyWith(showErrors: true));

    if (state.isSuccess && state.passwordMatch) {
      print('Change password request sent');
      emit(state.copyWith(submittedSuccessfully: true));
    }
  }
}

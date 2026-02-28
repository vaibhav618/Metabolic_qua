import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/account_setting_screen/presentation/cubit/account_setting_state.dart';

class AccountSettingCubit extends Cubit<AccountSettingState> {
  AccountSettingCubit()
    : super(
        const AccountSettingState(
          email: "ex@gmail.com",
          name: "default",
          mobileNumber: "+9876543210",
        ),
      );

  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updateMobileNumber(String mobileNumber) {
    emit(state.copyWith(mobileNumber: mobileNumber));
  }

  void updateEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void changePassword() {
    print("Navigate to OTP Screen");
  }
}

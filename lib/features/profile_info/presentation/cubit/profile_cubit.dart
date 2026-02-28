import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/weight_unit.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/core/utils/validators.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final CalculateBMI calculateBMI;
  final CalculateBMR calculateBMR;
  final DietitianRepository dietitianRepository;

  ProfileCubit(
      this.calculateBMI,
      this.calculateBMR,
      this.dietitianRepository,
      ) : super(const ProfileState());

  /// Store ONLY the image file path (saved after crop)
  void updateProfileImagePath(String filePath) {
    emit(state.copyWith(profileImagePath: filePath));
  }

  void clearProfileData() {
    emit(const ProfileState()); // Emit a fresh initial empty state
  }

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateEmail(String email) => emit(state.copyWith(email: email));
  void updateLocation(String location) => emit(state.copyWith(location: location));
  void updateGender(String gender) => emit(state.copyWith(gender: gender));
  void updateAge(int age) => emit(state.copyWith(age: age));

  void updateHeight(double heightCm) => emit(state.copyWith(height: heightCm));
  void updateHeightFromFeet(int feet, int inches) {
    final cm = (feet * 30.48) + (inches * 2.54);
    emit(state.copyWith(height: cm));
  }

  void updateHeightUnit(HeightUnit unit) => emit(state.copyWith(heightUnit: unit));

  void updateWeight(double weightKg) => emit(state.copyWith(weight: weightKg));
  void updateWeightFromLbs(double lbs) {
    final kg = lbs * 0.453592;
    emit(state.copyWith(weight: kg));
  }

  void updateWeightUnit(WeightUnit unit) => emit(state.copyWith(weightUnit: unit));

  /// Save selected dietician id into state
  void updateDietitian(String dietitianId) =>
      emit(state.copyWith(
        dietitianId: dietitianId,
      ));

  // Validators
  String? validateAgeInput(String input) => Validators.validateAge(input);
  String? validateWeightInput(String input, WeightUnit unit) =>
      Validators.validateWeight(input, unit);
  String? validateHeightInput(String input, HeightUnit unit) =>
      Validators.validateHeight(input, unit);

  Future<void> fetchDietitianName(String id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final dietitian = await dietitianRepository.fetchDietitian(id);

      if (dietitian != null) {
        emit(
          state.copyWith(
            dietitianId: dietitian.dietitianId,
            dietitianName: dietitian.name,
            dietitianImageUrl: dietitian.logoUrl,
            dietitianPhoneNo: dietitian.phoneNo,
            dietitianEmail: dietitian.email,
            dietitianClinicName: dietitian.phoneNo,
            isLoading: false,
            errorMessage: null,
          ),
        );
      } else {
        emit(state.copyWith(
          dietitianName: "NotFound",
          isLoading: false,
          errorMessage: "Dietitian not found",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        dietitianName: "Error",
        isLoading: false,
        errorMessage: "Failed to fetch dietitian: $e",
      ));
    }
  }



  void clearDieticianName() => emit(state.copyWith(dietitianClinicName: ""));



  double? getBMI() {
    if (state.height != null && state.weight != null) {
      return calculateBMI(state.weight!, state.height!);
    }
    return null;
  }

  double? getBMR() {
    if (state.height != null && state.weight != null && state.age != null) {
      return calculateBMR(
        weightKg: state.weight!,
        heightCm: state.height!,
        age: state.age!,
        gender: state.gender,
      );
    }
    return null;
  }
}

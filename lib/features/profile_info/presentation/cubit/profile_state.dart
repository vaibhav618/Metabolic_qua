import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/weight_unit.dart';

class ProfileState extends Equatable {
  final String? profileImagePath; // <-- file path only
  final String name;
  final String email;
  final String location;
  final String gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? dietitianId;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final String dietitianName;
  final String dietitianImageUrl;
  final String dietitianPhoneNo;
  final String dietitianEmail;
  final String dietitianClinicName;
  final String phoneNo;
  final bool? isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profileImagePath,
    this.name = '',
    this.email = '',
    this.location = '',
    this.gender = 'Female',
    this.age,
    this.height,
    this.weight,
    this.dietitianId,
    this.heightUnit = HeightUnit.cm,
    this.weightUnit = WeightUnit.kg,
    this.dietitianName = '',
    this.dietitianImageUrl = '',
    this.dietitianPhoneNo = '',
    this.dietitianEmail = '',
    this.dietitianClinicName = '',
    this.phoneNo = '',
    this.isLoading,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? profileImagePath,
    String? name,
    String? email,
    String? location,
    String? gender,
    int? age,
    double? height,
    double? weight,
    HeightUnit? heightUnit,
    WeightUnit? weightUnit,
    String? dietitianId,
    String? dietitianName,
    String? dietitianImageUrl,
    String? dietitianPhoneNo,
    String? dietitianEmail,
    String? dietitianClinicName,
    String? phoneNo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profileImagePath: profileImagePath ?? this.profileImagePath,
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      heightUnit: heightUnit ?? this.heightUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      dietitianId: dietitianId ?? this.dietitianId,
      dietitianName: dietitianId ?? this.dietitianName,
      dietitianImageUrl: dietitianImageUrl ?? this.dietitianImageUrl,
      dietitianPhoneNo: dietitianPhoneNo ?? this.dietitianPhoneNo,
      dietitianEmail: dietitianEmail ?? this.dietitianEmail,
      dietitianClinicName: dietitianClinicName ?? this.dietitianClinicName,
      phoneNo: phoneNo ?? this.phoneNo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    profileImagePath,
    name,
    email,
    location,
    gender,
    age,
    height,
    weight,
    heightUnit,
    weightUnit,
    dietitianId,
    dietitianName,
    dietitianImageUrl,
    dietitianPhoneNo,
    dietitianEmail,
    dietitianClinicName,
    phoneNo,
    isLoading,
    errorMessage,
  ];

  @override
  String toString() =>
      'ProfileState(profileImagePath: $profileImagePath, name: $name, email: $email, location: $location, gender: $gender, age: $age, height: $height, weight: $weight, heightUnit: $heightUnit, weightUnit: $weightUnit, dietitianId: $dietitianId, errorMessage: $errorMessage)';
}

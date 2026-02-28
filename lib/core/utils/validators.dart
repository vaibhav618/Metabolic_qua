import 'package:respyr_dietitian/features/profile_info/domain/usecases/height_unit.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/weight_unit.dart';

class Validators {
  static String? validateAge(String input) {
    if (input.trim().isEmpty) return "Please enter your age";

    final age = int.tryParse(input.trim());
    if (age == null) return "Please enter a valid number";

    if (age < 18 || age > 100) return "Age must be between 18 and 100";

    return null;
  }

  static String? validateWeight(String input, WeightUnit unit) {
    if (input.trim().isEmpty) return "Please enter your weight";

    final value = double.tryParse(input.trim());
    if (value == null) return "Please enter a valid number";

    if (unit == WeightUnit.kg && (value < 20 || value > 250)) {
      return "Weight in kg must be between 20 and 250";
    } else if (unit == WeightUnit.lbs && (value < 44 || value > 550)) {
      return "Weight in lbs must be between 44 and 550";
    }

    return null;
  }

  static String? validateHeight(String input, HeightUnit unit) {
    if (input.trim().isEmpty) return "Please enter your height";

    if (unit == HeightUnit.cm) {
      final value = double.tryParse(input.trim());
      if (value == null) return "Please enter a valid number";

      if (value < 50 || value > 280) {
        return "Height in cm must be between 50 and 280";
      }
    } else {
      final parts = input.split('.');

      if (parts.isEmpty || parts.length > 2) {
        return "Please enter height in feet.inches format (e.g. 5.10)";
      }

      final feet = int.tryParse(parts[0]);
      final inches = parts.length == 2 ? int.tryParse(parts[1]) : 0;

      if (feet == null || feet < 1 || feet > 9) {
        return "Feet must be between 1 and 9";
      }

      if (inches == null || inches < 0 || inches > 11) {
        return "Inches must be between 0 and 11";
      }

      if (feet == 1 && inches < 1) {
        return "Height must be greater than 1.0";
      }
    }

    return null;
  }

  static String? validateDieticianId(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return "Please enter your Dietician ID";
    if (trimmed.length != 9) return "ID must be exactly 9 characters long";

    return null;
  }
}

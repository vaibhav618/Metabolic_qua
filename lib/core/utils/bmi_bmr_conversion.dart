class BmiBmrUtils {
  /// BMI Formula: weight (kg) / [height (m)]²
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;
    if (heightM == 0) return 0.0;
    return weightKg / (heightM * heightM);
  }

  /// Mifflin-St Jeor Equation (most accurate)
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == "male") {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      // female
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }
}

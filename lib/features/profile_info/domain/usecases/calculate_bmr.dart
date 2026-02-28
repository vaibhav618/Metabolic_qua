class CalculateBMR {
  double call({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    final genderLower = gender.toLowerCase();
    return genderLower == 'male'
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
  }
}

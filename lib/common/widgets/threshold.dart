class Thresholds {
  static const double blowThreshold = 10;
  static const double inhaleThreshold = 15;
  static const double abortDifference = 1500;

  static double calculateThresholdPercentage(double baseValue) {
    double valueThreshold = baseValue + blowThreshold;
    double valueDiff = valueThreshold - baseValue;
    return (valueDiff / (valueDiff * 2)) * 100;
  }

  static double calculateBlowPercentage(double baseValue, double blowValue) {
    double valueThreshold = baseValue + blowThreshold;
    double valueDiff1 = valueThreshold - blowValue;
    valueDiff1 = blowThreshold - valueDiff1;
    double valueDiff = valueThreshold - baseValue;
    return (valueDiff1 / (valueDiff * 2)) * 100;
  }

  static double calculateBlowPercentage1(
      double baseValue, double blowValue, double exhaleThreshold) {
    double diff = blowValue - baseValue;
    double progress = (diff / exhaleThreshold) * 100;
    return progress;
  }

  static double calculateInhalePercentage(
      double baseValue, double inhaleValue, double inhaleThreshold) {
    double diff = inhaleValue - baseValue;
    double progress = (diff / inhaleThreshold) * 100;
    return progress;
  }
}

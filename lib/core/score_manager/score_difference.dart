Map<String, dynamic> getScoreDifference({
  required double current,
  required double previous,
}) {
  // Avoid divide-by-zero
  if (previous == 0) {
    return {
      "percentage": 0.0,
      "status": "no_change",
    };
  }

  double percent = ((current - previous) / previous) * 100;

  if (percent > 0) {
    return {
      "percentage": percent,
      "status": "increase",
    };
  } else if (percent < 0) {
    return {
      "percentage": percent.abs(),
      "status": "decrease",
    };
  } else {
    return {
      "percentage": 0.0,
      "status": "no_change",
    };
  }
}

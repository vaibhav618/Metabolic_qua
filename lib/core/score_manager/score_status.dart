class ScoreStatus{
  String getScoreStatus({required double score}) {
    if (score < 60) {
      return "Poor";
    } else if (score < 80) {
      return "Fair";
    } else {
      return "Good";
    }
  }
}
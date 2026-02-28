class MetabolismScore {
  final double score;
  final String date; // Ensure this is named 'date'

  MetabolismScore({required this.score, required this.date});

  factory MetabolismScore.fromJson(Map<String, dynamic> json) {
    return MetabolismScore(
      // Accesses 'fat_loss_metabolism_score' and converts to double
      score: (json['fat_loss_metabolism_score'] as num).toDouble(),
      // Accesses 'date' from JSON
      date: json['date'] as String,
    );
  }
}
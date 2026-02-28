class MealTimeHelper {
  /// Extracts meal name before the word "at"
  String getMealName(String label) {
    if (label.isEmpty) return '';
    // Split at the word "at"
    final parts = label.split(RegExp(r'\s+at\s+', caseSensitive: false));
    return parts.first.trim(); // everything before "at"
  }

  /// Extracts time (like "08:00 AM") after the word "at"
  String getMealTime(String label) {
    if (label.isEmpty) return '';
    final reg = RegExp(r'(\d{1,2}:\d{2}\s*[APMapm]{2})');
    final match = reg.firstMatch(label);
    if (match != null) {
      return match.group(1)!.trim(); // return matched time
    }
    return '';
  }
}

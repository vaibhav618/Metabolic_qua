class CurrentMeal {
  Map<String, dynamic>? pickCurrentMeal(List meals) {
    if (meals.isEmpty) return null;
    final now = DateTime.now();

    final list = _attachAndSort(meals);

    // Show if within 30 mins of start
    for (final m in list) {
      final start = m['_dt'] as DateTime;
      final end = start.add(const Duration(minutes: 30));
      final inWindow = (now.isAfter(start) && now.isBefore(end)) || now.isAtSameMomentAs(start);
      if (inWindow) return m;
    }

    // Show next upcoming
    for (final m in list) {
      if (now.isBefore(m['_dt'] as DateTime)) return m;
    }

    // Day over → last
    return list.last;
  }

  /// Returns the meal *after* the current one.
  /// - If you are within a 30-min window, this returns the next meal in the day.
  /// - If you are not in any window, this returns the first upcoming (same as pickCurrentMeal),
  ///   and then tries to return the one after that; if none, returns null.
  Map<String, dynamic>? pickUpcomingMeal(List meals) {
    if (meals.isEmpty) return null;
    final now = DateTime.now();
    final list = _attachAndSort(meals);

    // Find current in-window index
    int? inWindowIdx;
    for (int i = 0; i < list.length; i++) {
      final start = list[i]['_dt'] as DateTime;
      final end = start.add(const Duration(minutes: 30));
      if ((now.isAfter(start) && now.isBefore(end)) || now.isAtSameMomentAs(start)) {
        inWindowIdx = i;
        break;
      }
    }

    if (inWindowIdx != null) {
      // We are currently in a meal window → upcoming is the next index (if any)
      final nextIdx = inWindowIdx + 1;
      return nextIdx < list.length ? list[nextIdx] : null;
    }

    // Not in any window: find the first upcoming as "current",
    // then upcoming is the next one after it.
    for (int i = 0; i < list.length; i++) {
      final start = list[i]['_dt'] as DateTime;
      if (now.isBefore(start)) {
        final nextIdx = i + 1;
        return nextIdx < list.length ? list[nextIdx] : null;
      }
    }

    // If day is over (all past), no upcoming.
    return null;
  }

  // --- helpers ---

  List<Map<String, dynamic>> _attachAndSort(List meals) {
    final list = meals.map<Map<String, dynamic>>((m) {
      final map = Map<String, dynamic>.from(m as Map);
      map['_dt'] = _parseTimeToToday((map['time'] ?? '').toString());
      return map;
    }).toList()
      ..sort((a, b) => (a['_dt'] as DateTime).compareTo(b['_dt'] as DateTime));
    return list;
  }

  /// Smarter parser for different time formats and keywords
  DateTime _parseTimeToToday(String timeLabel) {
    final now = DateTime.now();
    String text = timeLabel.toLowerCase().trim();

    // 1) explicit "HH:MM AM/PM" or "H AM/PM"
    final reg = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)', caseSensitive: false);
    final match = reg.firstMatch(text);
    if (match != null) {
      int hh = int.parse(match.group(1)!);
      final mm = int.tryParse(match.group(2) ?? '0') ?? 0;
      final ampm = match.group(3)!.toUpperCase();
      if (ampm == 'PM' && hh != 12) hh += 12;
      if (ampm == 'AM' && hh == 12) hh = 0;
      return DateTime(now.year, now.month, now.day, hh, mm);
    }

    // 2) keywords like "before 9 am", "after 7 pm"
    if (text.contains('before 9')) return DateTime(now.year, now.month, now.day, 8, 45);
    if (text.contains('before 10')) return DateTime(now.year, now.month, now.day, 9, 45);
    if (text.contains('after 7'))  return DateTime(now.year, now.month, now.day, 19, 15);

    // 3) period-based phrases
    if (text.contains('early morning')) return DateTime(now.year, now.month, now.day, 7, 30);
    if (text.contains('mid morning'))   return DateTime(now.year, now.month, now.day, 11, 0);
    if (text.contains('morning'))       return DateTime(now.year, now.month, now.day, 9, 0);
    if (text.contains('noon') || text.contains('afternoon')) return DateTime(now.year, now.month, now.day, 13, 0);
    if (text.contains('lunch'))         return DateTime(now.year, now.month, now.day, 13, 30);
    if (text.contains('snack'))         return DateTime(now.year, now.month, now.day, 16, 30);
    if (text.contains('evening'))       return DateTime(now.year, now.month, now.day, 17, 30);
    if (text.contains('dinner'))        return DateTime(now.year, now.month, now.day, 20, 0);
    if (text.contains('post dinner') || text.contains('night'))
      return DateTime(now.year, now.month, now.day, 22, 0);

    // 4) fallback
    return DateTime(now.year, now.month, now.day, 23, 59);
  }
}

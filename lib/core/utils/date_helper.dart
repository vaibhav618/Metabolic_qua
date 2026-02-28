class DateHelper {
  // ✅ ADDED THIS METHOD: Standardizes date for API calls (e.g., 2025-12-22)
  static String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static String formatToDayMonth(DateTime date) {
    return "${date.day} ${_monthName(date.month)}";
  }

  // Convert to IST and format as: 20 Nov, 4:35pm
  static String formatToDateTimeString(DateTime dateUtc) {
    // 1️⃣ Ensure we start from UTC
    final ist = dateUtc.toUtc().add(const Duration(hours: 5, minutes: 30));

    final day = ist.day.toString().padLeft(2, '0');
    final month = _monthShort(ist.month);

    final hour24 = ist.hour;
    final hour12 = hour24 > 12 ? hour24 - 12 : hour24 == 0 ? 12 : hour24;
    final minute = ist.minute.toString().padLeft(2, '0');
    final ampm = hour24 >= 12 ? "pm" : "am";

    return "$day $month, $hour12:$minute$ampm";
  }

  // Helper methods
  static String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  static String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  static bool isNewNotification(DateTime input) {
    final now = DateTime.now();
    final difference = now.difference(input).inHours;
    return difference.abs() <= 5;
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
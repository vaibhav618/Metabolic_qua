String formatToDayMonth(DateTime date) {
  return "${date.day} ${_monthName(date.month)}";
}

String formatToDayShortMonth(DateTime date) {
  return "${date.day} ${_monthShort(date.month)}";
}

String formatToDateTimeString(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthShort(date.month);
  final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final ampm = date.hour >= 12 ? "pm" : "am";
  return "$day $month, $hour:$minute$ampm";
}

// Helper methods
String _monthName(int month) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month];
}

String _monthShort(int month) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month];
}

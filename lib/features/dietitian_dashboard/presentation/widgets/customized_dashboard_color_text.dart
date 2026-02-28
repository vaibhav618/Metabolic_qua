import 'package:flutter/material.dart';

class CustomizedDashboardColorText {
  static LinearGradient getGradientColor() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return const LinearGradient(
        colors: [Color(0xFFFFE29F), Color(0xFFFFA99F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 12 && hour < 19) {
      return const LinearGradient(
        colors: [Color(0xFFFFD6A5), Color(0xFFFDCB6E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF8093F1), Color(0xFFB388EB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  static Color dashboardIconTextColor() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return const Color(0xFFDA5747);
    } else if (hour >= 12 && hour < 19) {
      return const Color(0xFFC9880F);
    } else {
      return Color(0xFF3F1476);
    }
  }

  static Color totalContColor() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return const Color(0xFFF6270E);
    } else if (hour >= 12 && hour < 19) {
      return const Color(0xFFF6A000);
    } else {
      return Color(0xFF582699);
    }
  }

  static String greetingText() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return "Good morning";
    } else if (hour >= 12 && hour < 19) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  static String mealTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return "06:00 AM-12:00 PM";
    } else if (hour >= 12 && hour < 19) {
      return "12:00 PM-07:00 PM";
    } else {
      return "07:00 PM-06:00 AM";
    }
  }

  static Color titleColor() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 19 && hour < 6) {
      return Color(0xFFFFFFFF);
    } else {
      return Color(0xFF252525);
    }
  }

  static String getTimeRange(int hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 19) return 'afternoon';
    return 'evening';
  }

  static String mealTitle() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return "Breakfast";
    if (hour >= 12 && hour < 19) return "Lunch";
    return "Dinner";
  }
}

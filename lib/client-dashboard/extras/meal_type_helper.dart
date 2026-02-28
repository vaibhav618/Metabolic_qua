import 'package:flutter/material.dart';
import 'package:respyr_dietitian/client-dashboard/extras/theme.dart';

class ThemeHelper{
  String getCurrentMealType() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return "Breakfast";
    } else if (hour >= 11 && hour < 17) {
      return "Lunch";
    } else {
      return "Dinner";
    }
  }


  String getGreetingMessage() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return "Good morning";
    } else if (hour >= 11 && hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }




  LinearGradient getHeroGradient() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return DietTheme().morningHeroGradient;
    } else if (hour >= 11 && hour < 17) {
      return DietTheme().afternoonHeroGradient;
    } else {
      return DietTheme().nightHeroGradient;
    }
  }


  Color getThemeDarkColor() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return DietTheme().morningDietDarkColor;
    } else if (hour >= 11 && hour < 17) {
      return DietTheme().afternoonDietDarkColor;
    } else {
      return DietTheme().nightDietDarkColor;
    }
  }


  LinearGradient getDietItemGradient() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return DietTheme().morningItemGradient;
    } else if (hour >= 11 && hour < 17) {
      return DietTheme().afternoonItemGradient;
    } else {
      return DietTheme().nightItemGradient;
    }
  }
  Color getStatusBarColor() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return DietTheme().morningStatusBarColor;
    } else if (hour >= 11 && hour < 17) {
      return DietTheme().afternoonStatusBarColor;
    } else {
      return DietTheme().nightStatusBarColor;
    }
  }


  Color getGreetingTextColor() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 11) {
      return const Color(0xFF252525);
    } else if (hour >= 11 && hour < 17) {
      return const Color(0xFF252525);
    } else {
      return Colors.white;
    }
  }


}
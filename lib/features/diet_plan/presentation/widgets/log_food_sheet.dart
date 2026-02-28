import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../log_food/data/repository/insert_food_log_api.dart';

class LogFoodSheet {
  // ---------- small helpers ----------
  String _two(int n) => n.toString().padLeft(2, '0');

  /// 2025-11-11
  String? _fmtDate(DateTime? d) {
    if (d == null) return null;
    return "${d.year}-${_two(d.month)}-${_two(d.day)}";
  }

  /// 2025-11-11 08:00:00
  String? _fmtDateTime(DateTime? d) {
    if (d == null) return null;
    return "${d.year}-${_two(d.month)}-${_two(d.day)} "
        "${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}";
  }

  String? _weekdayLower(DateTime? d) {
    if (d == null) return null;
    const names = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
    return names[(d.weekday - 1).clamp(0, 6)];
  }

  /// Tue, 11 Nov 2025 • 08:00 AM
  String? _prettyLine({DateTime? date, String? mealTime}) {
    if (date == null && (mealTime == null || mealTime.isEmpty)) return null;

    String? dow;
    if (date != null) {
      const dows = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      dow = "${dows[(date.weekday - 1).clamp(0, 6)]}, ${date.day} ${months[(date.month - 1).clamp(0, 11)]} ${date.year}";
    }

    if (dow != null && mealTime != null && mealTime.trim().isNotEmpty) {
      return "$dow • $mealTime";
    } else if (dow != null) {
      return dow;
    } else {
      return mealTime;
    }
  }
  // ---------- end helpers ----------

  Widget valuesContainer(String valueType, String value, String valueIndicator) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valueType,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.50,
            ),
          ),
          Text(
            valueIndicator,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.20,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> logFood({
    required int index,
    required String mealTitle,
    required String foodName,
    required String foodType,
    required String foodScale,
    required String foodCalories,
    required String foodProtein,
    required String foodFat,
    required String foodCarbs,
    required BuildContext context,
    required String dieticianId,
    required String profileId,
    required String dietPlanId,

    // NEW (optional): day + time metadata to send to backend
    DateTime? logDate,          // selected chip's concrete date
    String? mealTime,           // time string from plan JSON (title or time)
    DateTime? logDateTime,      // combined date + time (00:00 if not parseable)
  }) async {
    // Decide what to commit to meal_date column:
    // Prefer logDateTime (date+time). If null, fallback to logDate @ 00:00:00. If both null, let server default.
    final mealDateStr = _fmtDateTime(logDateTime) ?? _fmtDate(logDate);

    // Core nutrient values + meta (stays in meal_values JSON)
    final Map<String, dynamic> foodValues = {
      "foodScale": foodScale,
      "foodCalories": foodCalories,
      "foodProtein": foodProtein,
      "foodFat": foodFat,
      "foodCarbs": foodCarbs,
      "meta": {
        "meal_day_key": mealTitle.toLowerCase(),
        "meal_time": mealTime,
        "meal_date": _fmtDate(logDate),
        "meal_datetime": _fmtDateTime(logDateTime),
      }
    };

    final result = await FoodLogApi.insertFoodLog(
      dieticianId: dieticianId,
      profileId: profileId,
      dietPlanId: dietPlanId,
      mealTitle: mealTitle,
      mealName: foodName,
      mealValues: jsonEncode(foodValues),
      // NEW: write to columns
      mealDate: mealDateStr,                  // -> PHP: meal_date DATETIME
      mealDay: _weekdayLower(logDate),        // -> PHP: meal_day
    );

    // UI feedback
    if (result["success"] == true) {
      if (result["already_exists"] == true) {
        if (kDebugMode) debugPrint("ℹ️ Already exists: ${result["id"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Already logged for this date")),
        );
      } else {
        if (kDebugMode) debugPrint("✅ Inserted Successfully: ${result["id"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserted Successfully")),
        );
      }
    } else {
      if (kDebugMode) debugPrint("⚠️ Error: ${result["error"] ?? result["message"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result["error"] ?? "Failed"}")),
      );
    }
    return result;
  }

  void showFoodBottomSheet({
    required int index,
    required String mealTitle,
    required String foodName,
    required String foodType,
    required String foodScale,
    required String foodCalories,
    required String foodProtein,
    required String foodFat,
    required String foodCarbs,
    required BuildContext context,
    required bool isLogged,
    required VoidCallback onLogged,
    required VoidCallback onAlreadyLogged,
    required String dieticianId,
    required String profileId,
    required String dietPlanId,

    // NEW optional params for day/time
    DateTime? logDate,          // e.g., 2025-11-11
    String? mealTime,           // e.g., "08:00 AM" / "Breakfast"
    DateTime? logDateTime,      // e.g., 2025-11-11 08:00:00
  }) {
    final pretty = _prettyLine(date: logDate, mealTime: mealTime);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, -0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFFFFF7AD), Colors.white],
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 20, bottom: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(bottomSheetContext, {"status": "closed"});
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Meal title
                      Text(
                        mealTitle,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFAC9C0C),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -0.72,
                        ),
                      ),

                      // Sub-line with day + date (+ time)
                      if (pretty != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          pretty,
                          style: GoogleFonts.poppins(
                            color: const Color(0xCC252525),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    children: [
                      Text(
                        foodName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          valuesContainer("Calories", foodCalories, "kcal"),
                          valuesContainer("Protein", foodProtein, "gram"),
                        ],
                      ),
                      const SizedBox(height: 53.5),
                      Row(
                        children: [
                          valuesContainer("Fat", foodFat, "gram"),
                          valuesContainer("Carbs", foodCarbs, "gram"),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // CTA — logs (if needed) and RETURNS to main with result
                      TextButton(
                        onPressed: () async {
                          if (isLogged) {
                            onAlreadyLogged();
                            Navigator.pop(bottomSheetContext, {
                              "status": "already_logged",
                              "mealTitle": mealTitle,
                              "mealName": foodName,
                              "logDate": _fmtDate(logDate),
                              "mealTime": mealTime,
                              "logDateTime": _fmtDateTime(logDateTime),
                            });
                            return;
                          }

                          try {
                            final result = await logFood(
                              index: index,
                              mealTitle: mealTitle,
                              foodName: foodName,
                              foodType: foodType,
                              foodScale: foodScale,
                              foodCalories: foodCalories,
                              foodProtein: foodProtein,
                              foodFat: foodFat,
                              foodCarbs: foodCarbs,
                              context: bottomSheetContext,
                              dieticianId: dieticianId,
                              profileId: profileId,
                              dietPlanId: dietPlanId,
                              // NEW: push meta to backend in both columns+JSON
                              logDate: logDate,
                              mealTime: mealTime,
                              logDateTime: logDateTime,
                            );

                            if (result["success"] == true &&
                                result["already_exists"] == true) {
                              onAlreadyLogged();
                            } else if (result["success"] == true) {
                              onLogged();
                            }

                            Navigator.pop(bottomSheetContext, {
                              "status": (result["success"] == true &&
                                  result["already_exists"] == true)
                                  ? "already_logged"
                                  : "logged",
                              "mealTitle": mealTitle,
                              "mealName": foodName,
                              "logDate": _fmtDate(logDate),
                              "mealTime": mealTime,
                              "logDateTime": _fmtDateTime(logDateTime),
                              "values": {
                                "calories": foodCalories,
                                "protein": foodProtein,
                                "fat": foodFat,
                                "carbs": foodCarbs,
                              },
                            });
                          } catch (_) {
                            // Keep sheet open on failure
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 14,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogged ? "Already Logged" : "Log this meal",
                              style: GoogleFonts.poppins(
                                color: isLogged ? Colors.grey : const Color(0xFF308BF9),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -0.30,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: isLogged ? Colors.grey : const Color(0xFF308BF9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

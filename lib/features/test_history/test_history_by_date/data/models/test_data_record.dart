import 'dart:convert';

/// ------------------------------------------------------------
/// Your existing TestDataRecord (UNCHANGED)
/// ------------------------------------------------------------
class TestDataRecord {
  final int testId;
  final String profileId;

  final double? absorptiveScore;
  final double? fermentativeScore;
  final double? fatScore;
  final double? glucoseScore;
  final double? hepaticStressScore;
  final double? detoxScore;

  final double? acetonePpm;
  final double? h2Ppm;
  final double? ethanolPpm;

  final DateTime dateTime;
  final bool? isTakenTest;

  /// Raw JSON string from `test_json` column (for debugging / logging)
  final String? testJsonRaw;

  /// Parsed JSON from `test_json` (Metabolism_Score_Analysis, etc.)
  final Map<String, dynamic>? testJson;

  TestDataRecord({
    required this.testId,
    required this.profileId,
    required this.dateTime,
    this.absorptiveScore,
    this.fermentativeScore,
    this.fatScore,
    this.glucoseScore,
    this.hepaticStressScore,
    this.detoxScore,
    this.acetonePpm,
    this.h2Ppm,
    this.ethanolPpm,
    this.isTakenTest,
    this.testJsonRaw,
    this.testJson,
  });

  factory TestDataRecord.fromJson(
      Map<String, dynamic> json,
      bool? isTakenTest,
      ) {
    final raw = json['test_json']?.toString();

    return TestDataRecord(
      testId: int.parse(json['test_id'].toString()),
      profileId: json['profile_id'] as String,
      absorptiveScore: _toDouble(json['absorptive_metabolism_score']),
      fermentativeScore: _toDouble(json['fermentative_metabolism_score']),
      fatScore: _toDouble(json['fat_metabolism_score']),
      glucoseScore: _toDouble(json['glucose_metabolism_score']),
      hepaticStressScore: _toDouble(json['hepatic_stress_metabolism_score']),
      detoxScore: _toDouble(json['detoxification_metabolism_score']),
      acetonePpm: _toDouble(json['acetone_ppm']),
      h2Ppm: _toDouble(json['h2_ppm']),
      ethanolPpm: _toDouble(json['ethanol_ppm']),
      dateTime: DateTime.parse(json['date_time']),
      isTakenTest: isTakenTest,
      testJsonRaw: raw,
      testJson: _parseTestJson(raw),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static Map<String, dynamic>? _parseTestJson(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      // If `test_json` is not valid JSON, just ignore to avoid crash
      return null;
    }
  }

  factory TestDataRecord.dummy({required String profileId}) {
    return TestDataRecord(
      testId: 0,
      profileId: profileId,
      dateTime: DateTime.now(),
      absorptiveScore: null,
      fermentativeScore: null,
      fatScore: null,
      glucoseScore: null,
      hepaticStressScore: null,
      detoxScore: null,
      acetonePpm: null,
      h2Ppm: null,
      ethanolPpm: null,
      isTakenTest: false,
      testJsonRaw: null,
      testJson: null,
    );
  }
}

/// ------------------------------------------------------------
/// NEW: Wrapper model for the full API response
/// ------------------------------------------------------------

class TestDataResponse {
  final bool success;
  final int count;
  final TestDateRange dateRange;
  final List<TestDataRecord> data;

  TestDataResponse({
    required this.success,
    required this.count,
    required this.dateRange,
    required this.data,
  });

  factory TestDataResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? []);

    return TestDataResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? list.length,
      dateRange: TestDateRange.fromJson(json['date_range'] ?? {}),
      data: list
          .map(
            (e) => TestDataRecord.fromJson(
          e as Map<String, dynamic>,
          true, // or null / your own isTakenTest logic
        ),
      )
          .toList(),
    );
  }
}

class TestDateRange {
  final DateTime startIst;
  final DateTime endIst;

  TestDateRange({
    required this.startIst,
    required this.endIst,
  });

  factory TestDateRange.fromJson(Map<String, dynamic> json) {
    final startStr = json['start_ist']?.toString() ?? '';
    final endStr = json['end_ist']?.toString() ?? '';

    return TestDateRange(
      startIst:
      startStr.isNotEmpty ? DateTime.parse(startStr.replaceFirst(' ', 'T')) : DateTime.now(),
      endIst:
      endStr.isNotEmpty ? DateTime.parse(endStr.replaceFirst(' ', 'T')) : DateTime.now(),
    );
  }
}

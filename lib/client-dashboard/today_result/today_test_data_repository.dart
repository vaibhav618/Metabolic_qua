import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_api_service.dart';

import '../../features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

class TodayTestDataRepository {
  final TodayTestDataApiService api;
  TodayTestDataRepository(this.api);

  Future<GeneratingResultModel?> fetchDay({
    required String profileId,
    required String dietitianId,
    DateTime? date,
  }) async {
    // format date -> YYYY-MM-DD
    final String day = DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

    final jsonMap = await api.fetchForDay(
      profileId: profileId,
      dietitianId: dietitianId,
      dateYYYYMMDD: day,
    );

    if (jsonMap['success'] != true) {
      return null;
    }

    // ✅ CASE 1: new API already returns respyr_response at root
    if (jsonMap.containsKey('respyr_response')) {
      return GeneratingResultModel.fromJson(jsonMap);
    }

    // ✅ CASE 2: old API: { success, count, data: [ { ... , test_json: "..." } ] }
    final List<dynamic>? dataList = jsonMap['data'] as List<dynamic>?;
    if (dataList == null || dataList.isEmpty) return null;

    final first = dataList.first as Map<String, dynamic>;

    // test_json is a JSON string
    Map<String, dynamic> inner = {};
    final raw = first['test_json']?.toString();
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        inner = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        inner = {};
      }
    }

    final mapped = <String, dynamic>{
      'success': jsonMap['success'] ?? true,
      'message': jsonMap['message'] ?? 'Record fetched',
      'test_id': first['test_id'] ?? 0,
      'date_time': first['date_time'] ?? '',
      'url_called': jsonMap['url_called'] ?? '',
      'respyr_response': inner,
    };

    return GeneratingResultModel.fromJson(mapped);
  }
}

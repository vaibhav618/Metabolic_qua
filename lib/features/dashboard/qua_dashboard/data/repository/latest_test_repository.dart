

import '../models/latest_test_data.dart';
import '../services/latest_test_service.dart';

class LatestTestRepository {
  final LatestTestService service;

  LatestTestRepository(this.service);

  Future<LatestTestData?> fetchLatestTest({
    required String dietitianId,
    required String profileId,
    required String date,
  }) async {
    final json = await service.fetchLatestTestRaw(
      dietitianId: dietitianId,
      profileId: profileId,
      date: date,
    );


    if (json['success'] != true) {
      throw Exception(json['message']?.toString() ?? 'API error');
    }

    final data = json['data'];
    if (data == null) return null;




    return LatestTestData.fromJson(Map<String, dynamic>.from(data));
  }
}

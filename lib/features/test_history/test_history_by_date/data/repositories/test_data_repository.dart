import 'package:intl/intl.dart';
import '../models/test_data_record.dart';
import '../sources/test_data_api.dart';

class TestDataRepository {
  final TestDataApi api;
  final bool? isTakenTest;
  TestDataRepository(this.isTakenTest, {required this.api});

  /// Accepts either a DateTime or a preformatted "YYYY-MM-DD" string
  Future<List<TestDataRecord>> getForProfileOnDate({
    required String profileId,
    required DateTime date,
  }) async {
    final ymd = DateFormat('yyyy-MM-dd').format(date);
    final jsonMap = await api.fetchByProfileAndDate(
      profileId: profileId,
      dateYMD: ymd,
    );

    final list = (jsonMap['data'] as List<dynamic>? ?? [])
        .map((e) => TestDataRecord.fromJson(e as Map<String, dynamic>,isTakenTest))
        .toList();

    // API already returns latest first, but we can enforce just in case.
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }
}

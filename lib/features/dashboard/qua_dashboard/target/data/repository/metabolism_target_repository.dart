import '../models/metabolism_target_model.dart';
import '../services/metabolism_target_service.dart';

class MetabolismTargetRepository {
  final MetabolismTargetService service;

  MetabolismTargetRepository(this.service);

  Future<MetabolismTargetModel> getTarget({
    required int age,
    required String gender,
    required double heightCm,
    required double currentWeight,
    required bool diabetic,
  }) async {
    final json = await service.fetchTarget(
      age: age,
      gender: gender,
      heightCm: heightCm,
      currentWeight: currentWeight,
      diabetic: diabetic,
    );

    return MetabolismTargetModel.fromJson(json);
  }
}

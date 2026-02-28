class TestLog {
  final int id;
  final String? testId;
  final String dietPlanId;
  final String clientId;
  final bool testTaken;
  final String updatedAt; // keep as string (e.g., "2025-08-11 09:15:42")

  const TestLog({
    required this.id,
    required this.testId,
    required this.dietPlanId,
    required this.clientId,
    required this.testTaken,
    required this.updatedAt,
  });

  factory TestLog.fromJson(Map<String, dynamic> json) {
    return TestLog(
      id: int.parse(json["id"].toString()),
      testId: json["test_id"]?.toString(),
      dietPlanId: json["diet_plan_id"]?.toString() ?? "",
      clientId: json["client_id"]?.toString() ?? "",
      testTaken: (json["test_taken"] is bool)
          ? json["test_taken"] as bool
          : json["test_taken"].toString() == "1",
      updatedAt: json["updated_at"]?.toString() ?? "",
    );
  }
}
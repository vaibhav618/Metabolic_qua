class TestLogException implements Exception {
  final String message;
  TestLogException(this.message);
  @override
  String toString() => "TestLogException: $message";
}
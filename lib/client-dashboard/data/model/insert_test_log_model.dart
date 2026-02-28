class InsertLogResult {
  final bool success;
  final String message;
  final int? insertedId;
  const InsertLogResult({required this.success, required this.message, this.insertedId});
}
/// Thrown when an entity is looked up by ID but does not exist in storage.
class NotFoundException implements Exception {
  const NotFoundException({
    required this.message,
    required this.id,
  });

  final String message;
  final int id;

  @override
  String toString() => 'NotFoundException($id): $message';
}

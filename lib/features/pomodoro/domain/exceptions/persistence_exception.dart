/// Thrown when an Isar write operation fails during session persistence.
class PersistenceException implements Exception {
  const PersistenceException(this.message);

  final String message;
}

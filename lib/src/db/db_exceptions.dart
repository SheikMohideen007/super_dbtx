class DBException implements Exception {
  final String message;
  DBException(this.message);
  @override
  String toString() => 'DBException: $message';
}

class DBOpenException extends DBException {
  DBOpenException(super.message);
}

class DBQueryException extends DBException {
  DBQueryException(super.message);
}

class DBBackupException extends DBException {
  DBBackupException(super.message);
}

import 'dart:io';
// import 'package:path/path.dart' as p;
import 'db_exceptions.dart';
import 'db_logger.dart';

class DBBackup {
  // Creates a file copy of the database file to backupPath.
  static Future<void> backupDatabase(String dbPath, String backupPath) async {
    try {
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw DBBackupException('Database file not found at $dbPath');
      }
      final backupFile = File(backupPath);
      await backupFile.create(recursive: true);
      await dbFile.copy(backupPath);
      DBLogger.info('Database backed up to $backupPath');
    } catch (e) {
      DBLogger.info('backupDatabase error: $e');
      throw DBBackupException(e.toString());
    }
  }

  // Restores a backup file to the dbPath (overwrites existing DB file).
  static Future<void> restoreDatabase(String backupPath, String dbPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw DBBackupException('Backup file not found at $backupPath');
      }
      await backupFile.copy(dbPath);
      DBLogger.info('Database restored from $backupPath to $dbPath');
    } catch (e) {
      DBLogger.info('restoreDatabase error: $e');
      throw DBBackupException(e.toString());
    }
  }
}

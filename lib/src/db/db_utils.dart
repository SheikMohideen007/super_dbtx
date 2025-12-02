import 'dart:io';
import 'package:super_dbtx/super_dbtx.dart';
import 'db_exceptions.dart';
import 'db_logger.dart';

class DBUtils {
  // Drop all tables provided by tableNames
  static Future<void> dropAll(SuperDatabase db, List<String> tableNames) async {
    try {
      for (final t in tableNames) {
        DBLogger.info('Dropping table if exists: $t');
        await db.raw.execute('DROP TABLE IF EXISTS $t');
      }
    } catch (e) {
      DBLogger.info('dropAll error: $e');
      throw DBQueryException(e.toString());
    }
  }

  // Check if table exists in the database
  static Future<bool> tableExists(SuperDatabase db, String tableName) async {
    try {
      final result = await db.raw.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      DBLogger.info('tableExists error: $e');
      throw DBQueryException(e.toString());
    }
  }

  // Drop table if exists
  static Future<void> dropTable(SuperDatabase db, String tableName) async {
    if (!isValidIdentifier(tableName)) {
      throw DBQueryException("Invalid table name: $tableName");
    }

    try {
      await db.raw.execute('DROP TABLE IF EXISTS $tableName');
      DBLogger.info('Dropped table: $tableName');
    } catch (e) {
      DBLogger.info('dropTable error: $e');
      throw DBQueryException("Failed to drop table $tableName: $e");
    }
  }

  // to avoid a SQL injection via table or column names.
  static bool isValidIdentifier(String name) {
    final regex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    return regex.hasMatch(name);
  }

  // Checking a DB Size
  static Future<int> getSuperDatabaseSize(String dbPath) async {
    try {
      final file = File(dbPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      throw DBQueryException("Failed to get DB size: $e");
    }
  }

  // to shrink a size of Db after deleted a multiple rows.
  static Future<void> vacuum(SuperDatabase db) async {
    try {
      await db.raw.execute('VACUUM');
      DBLogger.info('VACUUM executed');
    } catch (e) {
      throw DBQueryException("VACUUM failed: $e");
    }
  }

  // to fetch all the table names
  static Future<List<String>> fetchTableNames(SuperDatabase db) async {
    try {
      final result = await db.raw.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      return result.map((e) => e['name'] as String).toList();
    } catch (e) {
      throw DBQueryException("Failed to fetch table names: $e");
    }
  }

  // to delete all rows but keep table structure
  static Future<void> clearTable(SuperDatabase db, String tableName) async {
    if (!isValidIdentifier(tableName)) {
      throw DBQueryException("Invalid table name: $tableName");
    }

    try {
      await db.raw.delete(tableName);
    } catch (e) {
      throw DBQueryException("Failed to clear table $tableName: $e");
    }
  }

  // to count rows for ANY table
  static Future<int> getRowCount(SuperDatabase db, String tableName) async {
    try {
      final result = await db.raw.rawQuery(
        'SELECT COUNT(*) as cnt FROM $tableName',
      );
      return result.first['cnt'] as int;
    } catch (e) {
      throw DBQueryException("Failed to count rows in $tableName: $e");
    }
  }

  // drop + recreate (Schema resets)
  static Future<void> recreateTable(
    SuperDatabase db,
    String tableName,
    String createSql,
  ) async {
    await dropTable(db, tableName);
    await db.raw.execute(createSql);
  }

  // to check a DB path.
  static Future<String> getDBPath(SuperDatabase db) async {
    return db.raw.path;
  }

  // to get a column's related data
  static Future<List<String>> getTableColumns(
    SuperDatabase db,
    String tableName,
  ) async {
    try {
      final result = await db.raw.rawQuery("PRAGMA table_info($tableName)");
      return result.map((c) => c['name'] as String).toList();
    } catch (e) {
      throw DBQueryException("Failed to get columns for $tableName: $e");
    }
  }

  // For Altering a thing in the table //

  // to Add new column to a table
  static Future<void> addColumn(
    SuperDatabase db,
    String tableName,
    String columnDefinition,
  ) async {
    if (!isValidIdentifier(tableName)) {
      throw DBQueryException("Invalid table name: $tableName");
    }

    try {
      await db.raw.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnDefinition',
      );
      DBLogger.info('Added column to $tableName: $columnDefinition');
    } catch (e) {
      throw DBQueryException('Failed to add column to $tableName: $e');
    }
  }

  // to rename a table
  static Future<void> renameTable(
    SuperDatabase db,
    String oldName,
    String newName,
  ) async {
    if (!isValidIdentifier(oldName) || !isValidIdentifier(newName)) {
      throw DBQueryException("Invalid table names");
    }

    try {
      await db.raw.execute('ALTER TABLE $oldName RENAME TO $newName');
      DBLogger.info('Renamed table $oldName to $newName');
    } catch (e) {
      throw DBQueryException('Failed to rename table $oldName: $e');
    }
  }

  // to rename a column in the table
  static Future<void> renameColumn(
    SuperDatabase db,
    String tableName,
    String oldColumn,
    String newColumn,
  ) async {
    try {
      await db.raw.execute(
        'ALTER TABLE $tableName RENAME COLUMN $oldColumn TO $newColumn',
      );
      DBLogger.info('Renamed column $oldColumn to $newColumn in $tableName');
    } catch (e) {
      throw DBQueryException(
        'Failed to rename column $oldColumn in $tableName: $e',
      );
    }
  }
}

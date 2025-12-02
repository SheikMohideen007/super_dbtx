import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:super_dbtx/src/db/super_database.dart';
import 'db_exceptions.dart';
import 'db_logger.dart';

typedef TableCreate = String;
typedef UpgradeMap = Map<int, List<String>>;
typedef OnOpenCallback = FutureOr<void> Function(SuperDatabase db);

class DBInitializer {
  DBInitializer._();

  /* Initialize (open) a database with given parameters.
   - dbPath: absolute path to DB file
   - version: db schema version
   - createQueries: list of CREATE TABLE ... SQL strings
   - upgradeQueries: map of version -> list of SQL strings to run when upgrading to that version
   - onOpen: optional callback invoked when DB is opened
   */

  /// Pure function – does NOT store instance — returns fresh SuperDatabase
  static Future<SuperDatabase> init({
    required String dbPath,
    required int version,
    required List<TableCreate> createQueries,
    UpgradeMap? upgradeQueries,
    OnOpenCallback? onOpen,
    bool readOnly = false,
    bool singleInstance = true,
  }) async {
    try {
      final directory = File(dbPath).parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      DBLogger.info('Opening DB at: $dbPath (version $version)');

      final rawDb = await openDatabase(
        dbPath,
        version: version,
        readOnly: readOnly,
        singleInstance: singleInstance,
        onCreate: (db, ver) async {
          DBLogger.info('onCreate: creating tables');
          for (final q in createQueries) {
            DBLogger.info('execute create query: $q');
            await db.execute(q);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          DBLogger.info('onUpgrade not implemented');
        },
        onOpen: (db) async {
          DBLogger.info('Database opened at $dbPath');
          if (onOpen != null) await onOpen(SuperDatabase(db));
        },
      );

      return SuperDatabase(rawDb);
    } catch (e) {
      DBLogger.info('DBInitializer.init error: $e');
      throw DBOpenException(e.toString());
    }
  }

  // to get a database path
  static Future<String> databasePath(String dbName) async {
    final base = await getDatabasesPath();
    return join(base, dbName);
  }

  // Need to write for closing the DB
}


//  DBLogger.info('onUpgrade: $oldVersion -> $newVersion');
//           if (upgradeQueries != null) {
//             for (var v = oldVersion + 1; v <= newVersion; v++) {
//               final queries = upgradeQueries[v];
//               if (queries != null) {
//                 DBLogger.info('Running migrations for version $v');
//                 for (final q in queries) {
//                   DBLogger.info('execute upgrade query: $q');
//                   await db.execute(q);
//                 }
//               }
//             }
//           }
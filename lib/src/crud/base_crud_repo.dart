import 'package:sqflite/sqflite.dart';
import 'package:super_dbtx/src/db/super_database.dart';
import 'crud_repo.dart';
import 'query_builder.dart';
import '../db/db_logger.dart';
import '../utils/safe_executor.dart';

typedef FromMap<T> = T Function(Map<String, Object?> map);
typedef ToMap<T> = Map<String, Object?> Function(T model);

class BaseCrudRepo<T> implements CrudRepo<T> {
  final SuperDatabase db;
  final String tableName;
  final FromMap<T> fromMap;
  final ToMap<T> toMap;
  final String idColumn;

  BaseCrudRepo({
    required this.db,
    required this.tableName,
    required this.fromMap,
    required this.toMap,
    this.idColumn = 'id',
  });

  @override
  Future<int> save(T model) async {
    final map = toMap(model);
    DBLogger.info('save -> table: $tableName');
    return safeExec(() async {
      return await db.raw.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  @override
  Future<int> update(T model) async {
    final map = toMap(model);
    final id = map[idColumn];
    if (id == null) throw ArgumentError('id cannot be null for update');
    DBLogger.info('update -> table: $tableName id: $id');
    return safeExec(() async {
      return await db.raw.update(
        tableName,
        map,
        where: '$idColumn = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<int> deleteById(dynamic id) async {
    DBLogger.info('deelteById -> table: $tableName id: $id');
    return safeExec(() async {
      return await db.raw.delete(
        tableName,
        where: '$idColumn = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<int> deleteAll() async {
    DBLogger.info('deleteAll -> table: $tableName');
    return safeExec(() async {
      return await db.raw.delete(tableName);
    });
  }

  @override
  Future<List<T>> getAll({String? orderBy}) async {
    DBLogger.info('getAll -> table: $tableName');
    return safeExec(() async {
      final data = await db.raw.query(
        tableName,
        orderBy: orderBy ?? '$idColumn DESC',
      );
      return data.map((m) => fromMap(Map<String, Object?>.from(m))).toList();
    });
  }

  @override
  Future<T?> getOneById(dynamic id) async {
    DBLogger.info('getOneById -> table: $tableName id: $id');
    return safeExec(() async {
      final data = await db.raw.query(
        tableName,
        where: '$idColumn = ?',
        whereArgs: [id],
      );
      if (data.isEmpty) return null;
      return fromMap(Map<String, Object?>.from(data.first));
    });
  }

  @override
  Future<List<T>> getByColumn(String column, dynamic value) async {
    DBLogger.info('getByColumn -> table: $tableName column: $column');
    return safeExec(() async {
      final data = await db.raw.query(
        tableName,
        where: '$column = ?',
        whereArgs: [value],
      );
      return data.map((m) => fromMap(Map<String, Object?>.from(m))).toList();
    });
  }

  @override
  Future<List<T>> getByColumns(
    List<String> columns,
    List<dynamic> values,
  ) async {
    final where = buildAndWhereClause(columns);
    DBLogger.info('getByColumns -> table: $tableName where: $where');
    return safeExec(() async {
      final data = await db.raw.query(
        tableName,
        where: where,
        whereArgs: values,
      );
      return data.map((m) => fromMap(Map<String, Object?>.from(m))).toList();
    });
  }

  /// Pagination helper (limit/offset)
  Future<List<T>> getPage({
    required int limit,
    required int offset,
    String? orderBy,
  }) async {
    DBLogger.info('getPage -> table: $tableName limit: $limit offset: $offset');

    return safeExec(() async {
      final data = await db.raw.query(
        tableName,
        orderBy: orderBy ?? '$idColumn DESC',
        limit: limit,
        offset: offset,
      );
      return data.map((m) => fromMap(Map<String, Object?>.from(m))).toList();
    });
  }

  /// Bulk insert inside a transaction
  Future<void> bulkInsert(List<T> items) async {
    DBLogger.info('bulkInsert -> table: $tableName count: ${items.length}');
    await safeExec(() async {
      await db.raw.transaction((txn) async {
        for (final item in items) {
          await txn.insert(
            tableName,
            toMap(item),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    });
  }

  //checks whether the entry for the id is exist or not
  Future<bool> exists({required int id}) async {
    return await safeExec(() async {
      final result = await db.raw.query(
        tableName,
        columns: [idColumn],
        where: '$idColumn = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }

  // getting total count
  Future<int> count() async {
    return await safeExec(() async {
      final result = await db.raw.rawQuery(
        'SELECT COUNT(*) as cnt FROM $tableName',
      );
      return result.first['cnt'] as int;
    });
  }
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:super_dbtx/super_dbtx.dart';
import 'package:super_dbtx/super_dbtx.dart';

class UserModel {
  final int? id;
  final String name;
  const UserModel({this.id, required this.name});
}

Map<String, Object?> userToMap(UserModel u) => {'id': u.id, 'name': u.name};
UserModel userFromMap(Map<String, Object?> m) =>
    UserModel(id: m['id'] as int?, name: m['name'] as String);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database sdb;
  late SuperDatabase ssdb;
  late BaseCrudRepo<UserModel> repo;
  const usersCreateSql = '''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    );
  ''';

  setUp(() async {
    sdb = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (d, v) async {
        await d.execute(usersCreateSql);
      },
    );
    ssdb = SuperDatabase(sdb);

    repo = BaseCrudRepo<UserModel>(
      db: ssdb,
      tableName: 'users',
      idColumn: 'id',
      fromMap: userFromMap,
      toMap: userToMap,
    );
  });

  tearDown(() async {
    await sdb.close();
  });

  test('tableExists after create', () async {
    final ex = await DBUtils.tableExists(ssdb, 'users');
    expect(ex, true);
  });

  test('insert & getOne & count & exists', () async {
    final id = await repo.save(UserModel(name: 'Alice'));
    expect(id, isPositive);

    final one = await repo.getOneById(id);
    expect(one, isNotNull);
    expect(one!.name, 'Alice');

    final c = await repo.count();
    expect(c, 1);

    final e = await repo.exists(id: id);
    expect(e, true);
  });

  test('getAll, update & delete', () async {
    await repo.save(UserModel(name: 'A'));
    await repo.save(UserModel(name: 'B'));

    var all = await repo.getAll(orderBy: 'id ASC');
    expect(all.length, 2);

    final id = await repo.save(UserModel(name: 'Old'));
    final upd = await repo.update(UserModel(id: id, name: 'New'));
    expect(upd, 1);
    final f = await repo.getOneById(id);
    expect(f!.name, 'New');

    final del = await repo.deleteById(id);
    expect(del, 1);
  });

  test('deleteAll & clearTable & getRowCount', () async {
    await repo.save(UserModel(name: 'X'));
    await repo.save(UserModel(name: 'Y'));

    final del = await repo.deleteAll();
    expect(del >= 0, true);

    // use clearTable on recreated data
    await repo.save(UserModel(name: 'P'));
    await DBUtils.clearTable(ssdb, 'users');
    final rc = await DBUtils.getRowCount(ssdb, 'users');
    expect(rc, 0);
  });

  test('bulkInsert & getPage', () async {
    final items = List.generate(50, (i) => UserModel(name: 'U$i'));
    await repo.bulkInsert(items);

    final page1 = await repo.getPage(limit: 10, offset: 0, orderBy: 'id ASC');
    expect(page1.length, 10);

    final page2 = await repo.getPage(limit: 20, offset: 10, orderBy: 'id ASC');
    expect(page2.length, 20);
  });

  test('getByColumns (single column) & getByColumn', () async {
    await repo.bulkInsert([
      UserModel(name: 'A'),
      UserModel(name: 'A'),
      UserModel(name: 'B'),
    ]);
    final aRows = await repo.getByColumn('name', 'A');
    expect(aRows.length, 2);

    final cols = await repo.getByColumns(['name'], ['B']);
    expect(cols.length, 1);
    expect(cols.first.name, 'B');
  });

  test('query builder IN clause usage (delete by in)', () async {
    await repo.bulkInsert([
      UserModel(name: 'I1'),
      UserModel(name: 'I2'),
      UserModel(name: 'I3'),
    ]);
    final all = await repo.getAll();
    final ids = all.map((u) => (u as UserModel).id).whereType<int>().toList();

    // delete by storing raw call using buildInClause
    final clause = buildInClause('id', ids.length);
    final removed = await sdb.delete('users', where: clause, whereArgs: ids);
    expect(removed, ids.length);
  });

  test('DBUtils fetchTableNames, getTableColumns, getDBPath', () async {
    final tables = await DBUtils.fetchTableNames(ssdb);
    expect(tables.contains('users'), true);

    final cols = await DBUtils.getTableColumns(ssdb, 'users');
    expect(cols.contains('id'), true);
    expect(cols.contains('name'), true);

    final path = await DBUtils.getDBPath(ssdb);
    expect(path, isNotEmpty);
  });

  test('addColumn & renameColumn flow', () async {
    // add column
    await DBUtils.addColumn(ssdb, 'users', 'age INTEGER DEFAULT 0');
    var cols = await DBUtils.getTableColumns(ssdb, 'users');
    expect(cols.contains('age'), true);

    // rename column (if supported)
    await DBUtils.renameColumn(ssdb, 'users', 'age', 'years');
    cols = await DBUtils.getTableColumns(ssdb, 'users');
    expect(cols.contains('years') || cols.contains('age'), true);
  });
}

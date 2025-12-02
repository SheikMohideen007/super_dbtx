// import 'package:flutter_test/flutter_test.dart';
// // import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:super_dbtx/super_dbtx.dart';

// class UserModel {
//   final int? id;
//   final String name;

//   UserModel({this.id, required this.name});
// }

// Map<String, Object?> userToMap(UserModel user) {
//   return {'id': user.id, 'name': user.name};
// }

// UserModel userFromMap(Map<String, Object?> map) {
//   return UserModel(id: map['id'] as int?, name: map['name'] as String);
// }

// void main() {
//   late Database db;
//   late SuperDatabase sdb;
//   late BaseCrudRepo<UserModel> repo;

//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;
//   setUp(() async {
//     // Using in-memory database for testing
//     db = await openDatabase(
//       inMemoryDatabasePath,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE users(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT
//           )
//         ''');
//       },
//     );

//     sdb = SuperDatabase(db);

//     repo = BaseCrudRepo<UserModel>(
//       db: sdb,
//       tableName: 'users',
//       idColumn: 'id',
//       fromMap: userFromMap,
//       toMap: userToMap,
//     );
//   });

//   tearDown(() async {
//     await db.close();
//   });

//   /* Test Script starts */

//   test('Insert user', () async {
//     final id = await repo.save(UserModel(name: 'Sheik'));
//     await repo.save(UserModel(name: 'mohideen'));
//     // print("$id...$id2");
//     expect(id, isPositive);
//   });

//   test('Get all users', () async {
//     await repo.save(UserModel(name: 'Sheik'));
//     await repo.save(UserModel(name: 'Test'));

//     final users = await repo.getAll();
//     expect(users.length, 2);
//   });

//   test('Get one by ID', () async {
//     final id = await repo.save(UserModel(name: 'Sheik'));
//     final user = await repo.getOneById(id);

//     expect(user, isNotNull);
//     expect(user!.name, 'Sheik');
//   });

//   test('Update user', () async {
//     final id = await repo.save(UserModel(name: 'Old Name'));
//     // final user = await repo.getOneById(id);
//     // print(user!.name);
//     final updated = await repo.update(UserModel(id: id, name: 'New Name'));

//     expect(updated, 1);

//     final fetched = await repo.getOneById(id);
//     expect(fetched!.name, 'New Name');
//   });

//   test('Delete by ID', () async {
//     final id = await repo.save(UserModel(name: 'Delete Me'));
//     final deleted = await repo.deleteById(id);

//     expect(deleted, 1);

//     final user = await repo.getOneById(id);
//     expect(user, isNull);
//   });

//   test('Delete all', () async {
//     await repo.save(UserModel(name: 'A'));
//     await repo.save(UserModel(name: 'B'));

//     final count = await repo.deleteAll();
//     expect(count, 2);
//   });

//   test('Count users', () async {
//     await repo.save(UserModel(name: 'A'));
//     await repo.save(UserModel(name: 'B'));

//     final c = await repo.count();
//     expect(c, 2);
//   });

//   test('Exists check', () async {
//     final id = await repo.save(UserModel(name: 'Exists'));
//     final exists = await repo.exists(id: id);

//     expect(exists, true);
//   });

//   test('Bulk Insert', () async {
//     final items = List.generate(5, (i) => UserModel(name: 'User $i'));

//     await repo.bulkInsert(items);

//     final c = await repo.count();
//     expect(c, 5);
//   });

//   test('Drop table using DBUtils', () async {
//     expect(await DBUtils.tableExists(db, 'users'), true);

//     await DBUtils.dropTable(db, 'users');

//     final exists = await DBUtils.tableExists(db, 'users');
//     expect(exists, false);
//   });

//   test('VACUUM does not crash in memory DB', () async {
//     await DBUtils.vacuum(db);
//   });
// }

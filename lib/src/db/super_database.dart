import 'package:sqflite/sqflite.dart';

class SuperDatabase {
  final Database _db;

  SuperDatabase(this._db);

  Database get raw => _db;
}

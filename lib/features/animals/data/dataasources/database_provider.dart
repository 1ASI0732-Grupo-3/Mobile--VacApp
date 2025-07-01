import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  Database? _db;

  Future<Database> openDb() async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'easyshoes.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE animals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          gender TEXT,
          birthDate TEXT,
          breed TEXT,
          location TEXT,
          bovineImg TEXT,
          stableId INTEGER
        )
      ''');
      },
    );
    return _db as Database;
  }
}
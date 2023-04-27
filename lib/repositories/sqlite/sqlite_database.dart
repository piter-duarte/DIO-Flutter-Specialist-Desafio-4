import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

Map<int, String> scripts = {
  1: '''CREATE TABLE pessoa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    altura REAL
  );''',
  2: '''CREATE TABLE imc (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    imc REAL,
    peso REAL,
    data TEXT,
    id_pessoa INTEGER,
    CONSTRAINT fk_imc_pessoa FOREIGN KEY(id_pessoa) REFERENCES pessoa(id) ON DELETE CASCADE
  );'''
};

class SqliteDatabase {
  static Database? db;

  Future<Database> obterDatabase() async {
    if (db == null) {
      return await _iniciarDatabase();
    } else {
      return db!;
    }
  }

  Future<Database> _iniciarDatabase() async {
    var db = await openDatabase(
      path.join(await getDatabasesPath(), 'database.db'),
      version: scripts.length,
      onCreate: (Database db, int version) async {
        for (var i = 1; i <= scripts.length; i++) {
          await db.execute(scripts[i]!);
          debugPrint(scripts[i]);
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        for (var i = oldVersion + 1; i < scripts.length; i++) {
          await db.execute(scripts[i]!);
          debugPrint(scripts[i]!);
        }
      },
    );

    return db;
  }
}

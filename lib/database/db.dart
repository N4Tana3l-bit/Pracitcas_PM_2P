import 'dart:async' as async;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static Database? _db;

  static async.Future<Database> get database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'notas.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE notas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, contenido TEXT)',
      ),
    );
    return _db!;
  }

  static async.Future<int> insertar(String titulo, String contenido) async {
    final db = await database;
    return db.insert('notas', {'titulo': titulo, 'contenido': contenido});
  }

  static async.Future<List<Map<String, Object?>>> listar() async {
    final db = await database;
    return db.query('notas', orderBy: 'id DESC');
  }

  static async.Future<int> actualizar(int id, String titulo, String contenido) async {
    final db = await database;
    return db.update(
      'notas',
      {'titulo': titulo, 'contenido': contenido},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  static async.Future<int> eliminar(int id) async {
    final db = await database;
    return db.delete('notas', where: 'id=?', whereArgs: [id]);
  }
}
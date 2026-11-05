import 'dart:async' as async;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBTareas {
  static Database? _db;

  static async.Future<Database> get database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'tareas_app.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE tareas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, completada INTEGER)',
      ),
    );
    return _db!;
  }

  static async.Future<int> insertar(String titulo) async {
    final db = await database;
    return db.insert('tareas', {'titulo': titulo, 'completada': 0});
  }

  static async.Future<List<Map<String, Object?>>> listar() async {
    final db = await database;
    return db.query('tareas', orderBy: 'id DESC');
  }

  static async.Future<int> toggleCompletada(int id, bool completada) async {
    final db = await database;
    return db.update(
      'tareas',
      {'completada': completada ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static async.Future<int> actualizar(int id, String titulo) async {
    final db = await database;
    return db.update(
      'tareas',
      {'titulo': titulo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static async.Future<int> eliminar(int id) async {
    final db = await database;
    return db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }
}
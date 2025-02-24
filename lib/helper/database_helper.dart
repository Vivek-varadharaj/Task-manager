import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_manager_app/features/home/domain/models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY,
          todo TEXT NOT NULL,
          completed INTEGER NOT NULL,
          userId INTEGER NOT NULL,
          dateAdded INTEGER DEFAULT (strftime('%s', 'now')),
          description TEXT,
          dueDate TEXT,
          remindMe INTEGER, -- 0 for false, 1 for true
          priority INTEGER -- Store enum as integer
        )
      ''');
      },
    );
  }

  Future<void> insertTasks(Todo task) async {
    final db = await database;

    await db.insert(
      'tasks',
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Todo task) async {
    final db = await database;

    int value = await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log(value.toString());
  }

  Future<List<Todo>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'dateAdded DESC',
    );

    return List.generate(maps.length, (i) => Todo.fromJson(maps[i]));
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

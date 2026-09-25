import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/course_model.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import 'sample_data.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('unitask.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT,
        lecturer TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        deadline TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    await SampleData.seedInitialData(db);
  }

  // --- COURSE CRUD ---
  Future<List<Course>> getCourses() async {
    final db = await instance.database;
    final maps = await db.query('courses', orderBy: 'name ASC');
    return maps.map((m) => Course.fromMap(m)).toList();
  }

  Future<Course?> getCourseById(String id) async {
    final db = await instance.database;
    final maps = await db.query('courses', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Course.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertCourse(Course course) async {
    final db = await instance.database;
    await db.insert('courses', course.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCourse(Course course) async {
    final db = await instance.database;
    await db.update('courses', course.toMap(), where: 'id = ?', whereArgs: [course.id]);
  }

  Future<void> deleteCourse(String id) async {
    final db = await instance.database;
    await db.delete('subtasks', where: 'task_id IN (SELECT id FROM tasks WHERE course_id = ?)', whereArgs: [id]);
    await db.delete('tasks', where: 'course_id = ?', whereArgs: [id]);
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // --- TASK CRUD ---
  Future<List<TaskItem>> getTasks() async {
    final db = await instance.database;
    final query = '''
      SELECT t.*, c.name as course_name 
      FROM tasks t
      LEFT JOIN courses c ON t.course_id = c.id
      ORDER BY 
        CASE WHEN t.deadline IS NULL THEN 1 ELSE 0 END,
        t.deadline ASC,
        t.created_at DESC
    ''';
    final maps = await db.rawQuery(query);

    List<TaskItem> tasks = [];
    for (var m in maps) {
      final taskId = m['id'] as String;
      final subtaskMaps = await db.query('subtasks', where: 'task_id = ?', whereArgs: [taskId]);
      final subtasks = subtaskMaps.map((sm) => Subtask.fromMap(sm)).toList();
      tasks.add(TaskItem.fromMap(m, subtasks: subtasks));
    }
    return tasks;
  }

  Future<TaskItem?> getTaskById(String id) async {
    final db = await instance.database;
    final query = '''
      SELECT t.*, c.name as course_name 
      FROM tasks t
      LEFT JOIN courses c ON t.course_id = c.id
      WHERE t.id = ?
    ''';
    final maps = await db.rawQuery(query, [id]);
    if (maps.isNotEmpty) {
      final subtaskMaps = await db.query('subtasks', where: 'task_id = ?', whereArgs: [id]);
      final subtasks = subtaskMaps.map((sm) => Subtask.fromMap(sm)).toList();
      return TaskItem.fromMap(maps.first, subtasks: subtasks);
    }
    return null;
  }

  Future<void> insertTask(TaskItem task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    for (var subtask in task.subtasks) {
      await db.insert('subtasks', subtask.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> updateTask(TaskItem task) async {
    final db = await instance.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await instance.database;
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [id]);
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- SUBTASK CRUD ---
  Future<void> insertSubtask(Subtask subtask) async {
    final db = await instance.database;
    await db.insert('subtasks', subtask.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSubtask(Subtask subtask) async {
    final db = await instance.database;
    await db.update('subtasks', subtask.toMap(), where: 'id = ?', whereArgs: [subtask.id]);
  }

  Future<void> deleteSubtask(String id) async {
    final db = await instance.database;
    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  // Reset/Re-seed Database
  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.delete('subtasks');
    await db.delete('tasks');
    await db.delete('courses');
    await SampleData.seedInitialData(db);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:db_practice_sqlflite/models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");

    print('Database path: $databasePath');

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        print('Creating database table');
        await db.execute('''
          CREATE TABLE $_tasksTableName (
            $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
            $_tasksContentColumnName TEXT NOT NULL,
            $_tasksStatusColumnName INTEGER NOT NULL
          )
        ''');
        print('Database table created');
      },
    );

    // Verify the table creation by querying the table names
    var result = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="$_tasksTableName"');
    if (result.isNotEmpty) {
      print('Table $_tasksTableName exists.');
    } else {
      print('Table $_tasksTableName does NOT exist.');
    }

    return database;
  }

  Future<void> addTask(String content) async {
    final db = await database; // Get the database instance
    try {
      await db.insert(
        _tasksTableName,
        {
          _tasksContentColumnName: content,
          _tasksStatusColumnName: 0, // Default status is 0 (not completed)
        },
      );
      print('Task inserted: $content');
    } catch (e) {
      print('Error inserting task: $e');
    }
  }

  Future<List<Task>> getTasks() async {
    final db = await database; // Get the database instance
    try {
      final data = await db.query(_tasksTableName); // Query the tasks table
      List<Task> tasks = data
          .map((e) => Task(
                id: e[_tasksIdColumnName] as int,
                status: e[_tasksStatusColumnName] as int,
                content: e[_tasksContentColumnName] as String,
              ))
          .toList();
      return tasks;
    } catch (e) {
      print('Error retrieving tasks: $e');
      return [];
    }
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
        _tasksTableName,
        {
          _tasksStatusColumnName: status,
        },
        where: 'id = ?',
        whereArgs: [
          id,
        ]);
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(_tasksTableName, where: 'id = ?', whereArgs: [
      id,
    ]);
  }
}

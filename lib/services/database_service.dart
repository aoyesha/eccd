import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _database;

  DatabaseService._constructor();

  // Tables
  static const teacherTable = "teacher_table";
  static const adminTable = "admin_table";
  static const classTable = "class_table";
  static const learnerTable = "learner_information_table";
  static const assessmentTable = "assessment_results";

  // Database
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = join(await getDatabasesPath(), "eccd_db.db");
    print("SQLite database path: $dbPath");

    _database = await openDatabase(dbPath, version: 1, onCreate: _onCreate);

    return _database!;
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE teacher_table (
        teacher_id INTEGER PRIMARY KEY AUTOINCREMENT,
        teacher_name TEXT,
        class_id INTEGER,
        email TEXT,
        password TEXT,
        school TEXT,
        district TEXT,
        division TEXT,
        region TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE admin_table (
        admin_id INTEGER PRIMARY KEY AUTOINCREMENT,
        admin_name TEXT,
        email TEXT,
        password TEXT,
        school TEXT,
        district TEXT,
        division TEXT,
        region TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE class_table (
        class_id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_level TEXT,
        class_section TEXT,
        start_school_year TEXT,
        end_school_year TEXT,
        status TEXT,
        teacher_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE learner_information_table (
        learner_id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id INTEGER,
        surname TEXT,
        given_name TEXT,
        middle_name TEXT,
        sex TEXT,
        lrn INTEGER UNIQUE,
        birthday TEXT,
        handedness TEXT,
        birth_order TEXT,
        barangay TEXT,
        city TEXT,
        province TEXT,
        parent_name TEXT,
        parent_occupation TEXT,
        age_mother_at_birth INTEGER,
        spouse_occupation TEXT,
        number_of_siblings INTEGER,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE assessment_results (
        assessment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        learner_id INTEGER NOT NULL,
        class_id INTEGER NOT NULL,
        domain TEXT NOT NULL,
        question_index INTEGER NOT NULL,
        answer INTEGER NOT NULL,
        assessment_type TEXT NOT NULL,
        date_taken TEXT NOT NULL
      )
    ''');
  }

  // insertions
  Future<void> createTeacher(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(teacherTable, data);
  }

  Future<void> createAdmin(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(adminTable, data);
  }

  Future<void> createClass(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(classTable, data);
  }

  Future<void> createLearner(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(learnerTable, data);
  }

  // ================== FETCH METHODS ==================
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    final db = await getDatabase();
    return db.query(teacherTable);
  }

  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    final db = await getDatabase();
    return db.query(adminTable);
  }

  Future<List<Map<String, dynamic>>> getAllClasses() async {
    final db = await getDatabase();
    return db.query(classTable);
  }

  Future<List<Map<String, dynamic>>> getLearnersByClass(int classId) async {
    final db = await getDatabase();
    return db.query(
      learnerTable,
      where: 'class_id = ? AND status = ?',
      whereArgs: [classId, 'active'],
    );
  }
}

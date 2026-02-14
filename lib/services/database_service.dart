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
  static const assessmentHeaderTable = "assessment_header";
  static const assessmentResultsTable = "assessment_results";
  static const learnerEcdTable = 'learner_ecd_table';

  // Database
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = join(await getDatabasesPath(), "eccd_db.db");
    print("SQLite database path: $dbPath");

    _database = await openDatabase(dbPath, version: 2, onCreate: _onCreate);

    return _database!;
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // ------------------ TEACHER ------------------
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
        recovery_q1 TEXT,
        recovery_a1 TEXT,
        recovery_q2 TEXT,
        recovery_a2 TEXT,
        status TEXT
      )
    ''');

    // ------------------ ADMIN ------------------
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
        recovery_q1 TEXT,
        recovery_a1 TEXT,
        recovery_q2 TEXT,
        recovery_a2 TEXT,
        status TEXT
      )
    ''');

    // ------------------ CLASS ------------------
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

    // ------------------ LEARNER ------------------
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

    // ------------------ ASSESSMENT HEADER ------------------
    await db.execute('''
      CREATE TABLE assessment_header (
        assessment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        learner_id INTEGER NOT NULL,
        class_id INTEGER NOT NULL,
        assessment_type TEXT NOT NULL,
        date_taken TEXT NOT NULL,
        age_as_of_assessment REAL,
        FOREIGN KEY (learner_id) REFERENCES learner_information_table(learner_id),
        FOREIGN KEY (class_id) REFERENCES class_table(class_id)
      )
    ''');

    // ------------------ ASSESSMENT RESULTS ------------------
    await db.execute('''
      CREATE TABLE assessment_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id INTEGER NOT NULL,
        domain TEXT NOT NULL,
        question_index INTEGER NOT NULL,
        answer INTEGER NOT NULL,
        FOREIGN KEY (assessment_id) REFERENCES assessment_header(assessment_id)
      )
    ''');

    // ------------------ LEARNER ECD SUMMARY ------------------
    await db.execute('''
      CREATE TABLE learner_ecd_table (
        learner_ecd_id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id INTEGER,
        gmd_total INTEGER,
        gmd_ss INTEGER,
        gmd_interpretation TEXT,

        fms_total INTEGER,
        fms_ss INTEGER,
        fms_interpretation TEXT,

        shd_total INTEGER,
        shd_ss INTEGER,
        shd_interpretation TEXT,

        rl_total INTEGER,
        rl_ss INTEGER,
        rl_interpretation TEXT,

        el_total INTEGER,
        el_ss INTEGER,
        el_interpretation TEXT,

        cd_total INTEGER,
        cd_ss INTEGER,
        cd_interpretation TEXT,

        sed_total INTEGER,
        sed_ss INTEGER,
        sed_interpretation TEXT,

        raw_score INTEGER,
        summary_scaled_score INTEGER,
        standard_score INTEGER,
        interpretation TEXT,

        FOREIGN KEY (assessment_id) REFERENCES assessment_header(assessment_id)
      )
    ''');
  }

  // ================== INSERT METHODS ==================
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

  // ================== PASSWORD UPDATE ==================
  Future<void> updatePassword({
    required String role,
    required String email,
    required String newPassword,
  }) async {
    final db = await getDatabase();

    if (role == 'Teacher') {
      await db.update(
        teacherTable,
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
    } else {
      await db.update(
        adminTable,
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email],
      );
    }
  }
}

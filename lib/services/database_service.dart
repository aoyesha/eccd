import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton instance
  static final DatabaseService instance = DatabaseService._constructor();

  // Teacher Table Columns
  final String _teacherTable = "teacher_table";
  final String _teacherId = "teacher_id";
  final String _teacherName = "teacher_name";
  final String _teacherClassId = "class_id";
  final String _teacherEmail = "email";
  final String _teacherPassword = "password";
  final String _teacherSchool = "school";
  final String _teacherDistrict = "district";
  final String _teacherDivision = "division";
  final String _teacherRegion = "region";
  final String _teacherStatus = "status";

  // Admin Table Columns
  final String _adminTable = "admin_table";
  final String _adminId = "admin_id";
  final String _adminName = "admin_name";
  final String _adminEmail = "email";
  final String _adminPassword = "password";
  final String _adminSchool = "school";
  final String _adminDistrict = "district";
  final String _adminDivision = "division";
  final String _adminRegion = "region";
  final String _adminStatus = "status";

  // Private constructor
  DatabaseService._constructor();

  // Get database
  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "eccd_db.db");

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create Teacher Table
        await db.execute('''
          CREATE TABLE $_teacherTable (
            $_teacherId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_teacherName TEXT,
            $_teacherClassId INTEGER NULL,
            $_teacherEmail TEXT,
            $_teacherPassword TEXT,
            $_teacherSchool TEXT,
            $_teacherDistrict TEXT,
            $_teacherDivision TEXT,
            $_teacherRegion TEXT,
            $_teacherStatus TEXT
          )
        ''');

        // Create Admin Table
        await db.execute('''
          CREATE TABLE $_adminTable (
            $_adminId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_adminName TEXT,
            $_adminEmail TEXT,
            $_adminPassword TEXT,
            $_adminSchool TEXT,
            $_adminDistrict TEXT,
            $_adminDivision TEXT,
            $_adminRegion TEXT,
            $_adminStatus TEXT
          )
        ''');
      },
    );

    return database;
  }

  // Insert teacher
  Future<void> createTeacher(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(_teacherTable, data);
  }

  // Insert admin
  Future<void> createAdmin(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(_adminTable, data);
  }

  // Optional: Fetch all teachers
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    final db = await getDatabase();
    return await db.query(_teacherTable);
  }

  // Optional: Fetch all admins
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    final db = await getDatabase();
    return await db.query(_adminTable);
  }
}

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

  // Class Table Columns
  final String _classTable = "class_table";
  final String _classId = "class_id";
  final String _classLevel = "class_level";
  final String _classSection = "class_section";
  final String _startYear = "start_school_year";
  final String _endYear = "end_school_year";
  final String _classStatus = "status";
  final String _classTeacherId = "teacher_id";

  // Inside DatabaseService class, add learner table columns
  final String _learnerTable = "learner_information_table";
  final String _learnerId = "learner_id";
  final String _learnerClassId = "class_id";
  final String _learnerSurname = "surname";
  final String _learnerGivenName = "given_name";
  final String _learnerMiddleName = "middle_name";
  final String _learnerSex = "sex";
  final String _learnerLRN = "lrn";
  final String _learnerBirthday = "birthday";
  final String _learnerHandedness = "handedness";
  final String _learnerBirthOrder = "birth_order";
  final String _learnerBarangay = "barangay";
  final String _learnerCity = "city";
  final String _learnerProvince = "province";
  final String _learnerParentName = "parent_name";
  final String _learnerParentOccupation = "parent_occupation";
  final String _learnerAgeMother = "age_mother_at_birth";
  final String _learnerSpouseOccupation = "spouse_occupation";
  final String _learnerNumberSiblings = "number_of_siblings";
  final String _learnerStatus = "status";

  // Private constructor
  DatabaseService._constructor();

  // Get database
  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "eccd_db.db");
    print("SQLite database path: $databasePath");  // <-- Add this line

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

        // Create Class Table
        await db.execute('''
          CREATE TABLE $_classTable (
            $_classId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_classLevel TEXT,
            $_classSection TEXT,
            $_startYear TEXT,
            $_endYear TEXT,
            $_classStatus TEXT,
            $_classTeacherId INTEGER,
            FOREIGN KEY ($_classTeacherId) REFERENCES $_teacherTable($_teacherId)
          )
        ''');

        // Create Learner Table
        await db.execute('''
          CREATE TABLE $_learnerTable (
            $_learnerId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_learnerClassId INTEGER,
            $_learnerSurname TEXT,
            $_learnerGivenName TEXT,
            $_learnerMiddleName TEXT,
            $_learnerSex TEXT,
            $_learnerLRN INTEGER,
            $_learnerBirthday TEXT,
            $_learnerHandedness TEXT,
            $_learnerBirthOrder TEXT,
            $_learnerBarangay TEXT,
            $_learnerCity TEXT,
            $_learnerProvince TEXT,
            $_learnerParentName TEXT,
            $_learnerParentOccupation TEXT,
            $_learnerAgeMother INTEGER,
            $_learnerSpouseOccupation TEXT,
            $_learnerNumberSiblings INTEGER,
            $_learnerStatus TEXT,
            FOREIGN KEY ($_learnerClassId) REFERENCES $_classTable($_classId)
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

  // Insert class
  Future<void> createClass(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(_classTable, data);
  }

  // Insert learner
  Future<void> createLearner(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert(_learnerTable, data);
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

  // Optional: Fetch all classes
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    final db = await getDatabase();
    return await db.query(_classTable);
  }

  // Fetch learners by class
  Future<List<Map<String, dynamic>>> getLearnersByClass(int classId) async {
    final db = await getDatabase();
    return await db.query(
      _learnerTable,
      where: '$_learnerClassId = ?',
      whereArgs: [classId],
    );
  }
}

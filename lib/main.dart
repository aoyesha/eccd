import 'package:eccd/view/landing_page.dart';
import 'package:eccd/view/register_page.dart';
import 'package:eccd/view/teacher_checklist_page.dart';
import 'package:eccd/view/teacher_class_list.dart';
import 'package:eccd/view/teacher_class_report_page.dart';
import 'package:eccd/view/teacher_new_data_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eccd/view/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:eccd/services/database_service.dart';



Future<void> deleteOldDatabase() async {
  final path = join(await getDatabasesPath(), "eccd_db.db");

  // Close database if open
  try {
    final db = await openDatabase(path);
    await db.close();
  } catch (_) {}

  await deleteDatabase(path);
  print("Database deleted successfully!");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deleteOldDatabase();  // delete old DB

  // Open the database and create tables
  await DatabaseService.instance.getDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.workSansTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      title: 'ECD Checklist',
      home: const ClassListPage(gradeLevel: "", section:"", teacherId: 1, classId: 1),
    );
  }
}

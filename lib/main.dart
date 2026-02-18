import 'package:eccd/view/login_page.dart';
import 'package:eccd/view/teacher_class_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:eccd/services/database_service.dart';

Future<void> deleteOldDatabase() async {
  final path = join(await getDatabasesPath(), "eccd_db.db");

  try {
    final db = await openDatabase(path);
    await db.close();
  } catch (_) {}

  await deleteDatabase(path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await deleteOldDatabase();
  await DatabaseService.instance.getDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ValueNotifier<double> fontScale = ValueNotifier<double>(1.0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: fontScale,
      builder: (context, scale, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ECD Checklist',
          theme: ThemeData(
            textTheme: GoogleFonts.workSansTextTheme(),
          ),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaleFactor: scale),
              child: child!,
            );
          },
          home: const LoginPage(),
        );
      },
    );
  }
}

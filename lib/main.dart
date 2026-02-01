import 'package:eccd/view/landing_page.dart';
import 'package:eccd/view/register_page.dart';
import 'package:eccd/view/teacher_checklist_page.dart';
import 'package:eccd/view/teacher_new_data_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eccd/view/login_page.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
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
      home: const TeacherChecklistPage(),
    );
  }
}
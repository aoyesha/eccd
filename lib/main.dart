import 'package:eccd/view/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eccd/view/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECD Checklist',
      home: const RegisterPage(),
    );
  }
}
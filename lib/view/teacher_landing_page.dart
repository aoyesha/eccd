import 'package:flutter/material.dart';

class TeacherLandingPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const TeacherLandingPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teacher Landing Page')),
      body: Center(
        child: Text('Welcome, ${user['teacher_name']}!'),
      ),
    );
  }
}

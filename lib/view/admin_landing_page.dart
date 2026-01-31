import 'package:flutter/material.dart';

class AdminLandingPage extends StatelessWidget {
  final Map<String, dynamic> user;
  const AdminLandingPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Landing Page')),
      body: Center(
        child: Text('Welcome, ${user['admin_name']}!'),
      ),
    );
  }
}

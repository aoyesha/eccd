import 'package:flutter/material.dart';
import '../util/navbar.dart';
import '../services/database_service.dart';
import '../main.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  final int userId;
  final String role;

  const SettingsPage({
    Key? key,
    required this.userId,
    required this.role, required String email,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final db = DatabaseService.instance;

    if (widget.role == "Teacher") {
      final teachers = await db.getAllTeachers();
      final user = teachers.firstWhere(
            (t) => t['teacher_id'] == widget.userId,
        orElse: () => {},
      );
      email = user['email'] ?? "";
    } else {
      final admins = await db.getAllAdmins();
      final user = admins.firstWhere(
            (a) => a['admin_id'] == widget.userId,
        orElse: () => {},
      );
      email = user['email'] ?? "";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
        selectedIndex: 5,
        onItemSelected: (_) {},
        teacherId: widget.userId,
      )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Navbar(
              selectedIndex: 5,
              onItemSelected: (_) {},
              teacherId: widget.userId,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Settings",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  _card(
                    title: "Email",
                    child: Text(
                      email.isEmpty ? "Loading..." : email,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _card(
                    title: "Change Password",
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: email.isEmpty
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangePasswordPage(
                              userId: widget.userId,
                              role: widget.role,
                              email: email,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _card(
                    title: "Font Size",
                    child: ValueListenableBuilder<double>(
                      valueListenable: MyApp.fontScale,
                      builder: (context, value, _) {
                        return Slider(
                          value: value,
                          min: 0.8,
                          max: 1.3,
                          divisions: 5,
                          label: value.toStringAsFixed(1),
                          onChanged: (v) {
                            MyApp.fontScale.value = v;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';

import 'register_page.dart';
import '../services/database_service.dart';
import 'landing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  String role = 'Teacher';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > 700
                ? _desktopLayout()
                : _mobileLayout();
          },
        ),
      ),
    );
  }

  // ================= MOBILE =================

  Widget _mobileLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/kids.png', width: 220),
                    const SizedBox(height: 24),
                    _title(),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _form(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= DESKTOP =================

  Widget _desktopLayout() {
    return Center(
      child: SizedBox(
        width: 1100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Image.asset('assets/kids.png', width: 400),
                  ),
                  const SizedBox(height: 22),
                  _title(),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 420, child: _form()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const AutoSizeText(
      "Early Childhood\nDevelopment Checklist",
      textAlign: TextAlign.center,
      maxLines: 2,
      minFontSize: 28,
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  // ================= FORM =================

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Your Email:'),
          _input(
            controller: emailController,
            hint: 'juan.delacruz@deped.gov.ph',
          ),
          const SizedBox(height: 18),

          _label('Password:'),
          _passwordInput(),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPasswordDialog,
              child: const Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 16),
          _roleSelector(),
          const SizedBox(height: 22),
          _loginButton(),
          const SizedBox(height: 16),

          Center(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
                children: [
                  const TextSpan(text: "Don't have an account yet? "),
                  TextSpan(
                    text: "Sign Up",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(() => const RegisterPage());
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUTS =================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordInput() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: '●●●●●●●●',
        suffixIcon: IconButton(
          icon: Icon(
            size: 20,
            obscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => obscure = !obscure),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= ROLE =================

  Widget _roleSelector() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _radio('Teacher'),
          const SizedBox(width: 35),
          _radio('Admin'),
        ],
      ),
    );
  }

  Widget _radio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: role,
          fillColor:
          MaterialStateProperty.resolveWith((states) => Colors.white),
          onChanged: (v) => setState(() => role = v!),
        ),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  // ================= LOGIN =================

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          final email = emailController.text.trim();
          final password = passwordController.text.trim();

          if (email.isEmpty && password.isEmpty) {
            _showErrorSnackBar("Please input details before proceeding");
            return;
          } else if (email.isEmpty) {
            _showErrorSnackBar("Email is required");
            return;
          } else if (password.isEmpty) {
            _showErrorSnackBar("Password is required");
            return;
          }

          final db = DatabaseService.instance;
          Map<String, dynamic> user = {};

          if (role == 'Teacher') {
            final teachers = await db.getAllTeachers();
            user = teachers.firstWhere(
                  (t) => t['email'] == email,
              orElse: () => {},
            );
          } else {
            final admins = await db.getAllAdmins();
            user = admins.firstWhere(
                  (a) => a['email'] == email,
              orElse: () => {},
            );
          }

          if (user.isEmpty) {
            _showErrorSnackBar("No account found in the selected role");
          } else if (user['password'] != password) {
            _showErrorSnackBar("Invalid credentials");
          } else {
            Get.off(() => LandingPage(
              role: role,
              teacherId: user['teacher_id'],
            ));
          }
        },
        child: const Text(
          'Log in',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  // ================= FORGOT PASSWORD =================

  Future<void> _forgotPasswordDialog() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar("Enter your email first");
      return;
    }

    final db = DatabaseService.instance;
    Map<String, dynamic> user = {};

    if (role == 'Teacher') {
      final teachers = await db.getAllTeachers();
      user = teachers.firstWhere(
            (t) => t['email'] == email,
        orElse: () => {},
      );
    } else {
      final admins = await db.getAllAdmins();
      user = admins.firstWhere(
            (a) => a['email'] == email,
        orElse: () => {},
      );
    }

    if (user.isEmpty) {
      _showErrorSnackBar("Account not found");
      return;
    }

    final questions = [
      {'q': user['recovery_q1'], 'a': user['recovery_a1']},
      {'q': user['recovery_q2'], 'a': user['recovery_a2']},
    ];

    final selected = questions[Random().nextInt(2)];
    final answerController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Password Recovery"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected['q']),
            const SizedBox(height: 10),
            TextField(controller: answerController),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (answerController.text.trim() != selected['a']) {
                _showErrorSnackBar("Incorrect answer");
                return;
              }

              await db.updatePassword(
                role: role,
                email: email,
                newPassword: newPasswordController.text.trim(),
              );

              Navigator.pop(context);
              _showErrorSnackBar("Password reset successful");
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

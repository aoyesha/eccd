import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId;
  final String role;
  final String email;

  const ChangePasswordPage({
    Key? key,
    required this.userId,
    required this.role,
    required this.email,
  }) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: 420,
                  child: _form(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Change Password",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _readonlyField("Email", widget.email),
          const SizedBox(height: 18),

          _passwordField(
            "Current Password",
            currentPasswordController,
            obscureCurrent,
                () => setState(() => obscureCurrent = !obscureCurrent),
          ),
          _passwordField(
            "New Password",
            newPasswordController,
            obscureNew,
                () => setState(() => obscureNew = !obscureNew),
          ),
          _passwordField(
            "Confirm New Password",
            confirmPasswordController,
            obscureConfirm,
                () => setState(() => obscureConfirm = !obscureConfirm),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: _handleChangePassword,
              child: const Text(
                "Update Password",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _passwordField(
      String label,
      TextEditingController controller,
      bool obscure,
      VoidCallback toggle,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    await DatabaseService.instance.updatePassword(
      role: widget.role,
      email: widget.email,
      newPassword: newPasswordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password updated successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}

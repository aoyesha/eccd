import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../util/navbar.dart';

class ChangePasswordPage extends StatefulWidget {
  final String role;
  final int userId;

  const ChangePasswordPage({Key? key, required this.role, required this.userId})
    : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmController = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    emailController.dispose();
    newPassController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    try {
      await DatabaseService.instance.updatePassword(
        role: widget.role,
        email: emailController.text.trim(),
        newPassword: newPassController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password updated.")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
              selectedIndex: 5,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFE64843),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          final form = Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPassController,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.trim().length < 6 ? "Min 6 chars" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmController,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                    ),
                    obscureText: true,
                    validator: (v) => v != newPassController.text
                        ? "Passwords do not match"
                        : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE64843),
                      ),
                      child: Text(_busy ? "Saving..." : "Save"),
                    ),
                  ),
                ],
              ),
            ),
          );

          return Row(
            children: [
              if (!isMobile)
                Navbar(
                  selectedIndex: 5,
                  onItemSelected: (_) {},
                  role: widget.role,
                  userId: widget.userId,
                ),
              Expanded(child: SingleChildScrollView(child: form)),
            ],
          );
        },
      ),
    );
  }
}

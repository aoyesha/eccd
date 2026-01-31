import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool obscure = true;
  int currentStep = 1;

  String? selectedRole;
  String? selectedInstitution;
  String? selectedDistrict;
  String? selectedDivision;
  String? selectedRegion;

  final List<String> accountRole = ['Teacher', 'Admin'];
  final List<String> institutions = ['A', 'B', 'C'];
  final List<String> district = ['A', 'B'];
  final List<String> division = ['A', 'B'];
  final List<String> region = ['A', 'B'];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
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

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Image.asset('assets/kids.png', width: 220),
          const SizedBox(height: 24),
          _title(),
          const SizedBox(height: 40),
          _formHeader(),
          Align(alignment: Alignment.centerLeft, child: _form()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _desktopLayout() {
    return Center(
      child: SizedBox(
        width: 1100,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
              child: SizedBox(
                width: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _formHeader(),
                    const SizedBox(height: 20),
                    _form(),
                  ],
                ),
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
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _formHeader() {
    return const Center(
      child: Text(
        "Create an Account",
        style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

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

  Widget _dropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
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
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
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

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (currentStep == 1) ...[
            _label('Please choose an account to access the portal'),
            _dropdown(
              hint: 'Choose an Account',
              items: accountRole,
              value: selectedRole,
              onChanged: (v) => setState(() => selectedRole = v),
            ),
            const SizedBox(height: 16),

            _label('Choose Institution:'),
            _dropdown(
              hint: 'Institution',
              items: institutions,
              value: selectedInstitution,
              onChanged: (v) => setState(() => selectedInstitution = v),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    hint: 'District',
                    items: district,
                    value: selectedDistrict,
                    onChanged: (v) => setState(() => selectedDistrict = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    hint: 'Division',
                    items: division,
                    value: selectedDivision,
                    onChanged: (v) => setState(() => selectedDivision = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    hint: 'Region',
                    items: region,
                    value: selectedRegion,
                    onChanged: (v) => setState(() => selectedRegion = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _stepButton("Next", () {
              if (selectedRole != null &&
                  selectedInstitution != null &&
                  selectedDistrict != null &&
                  selectedDivision != null &&
                  selectedRegion != null) {
                setState(() => currentStep = 2);
              } else {
                _showSnackBar("Please complete all selections");
              }
            }),
          ],

          if (currentStep == 2) ...[
            _label('Your Name:'),
            _input(controller: nameController, hint: 'Juan Dela Cruz'),
            const SizedBox(height: 18),

            _label('Your Email:'),
            _input(controller: emailController, hint: 'juan@deped.gov.ph'),
            const SizedBox(height: 18),

            _label('Set Password:'),
            _passwordInput(),
            const SizedBox(height: 24),

            _createAccountButton(),
            const SizedBox(height: 12),
            _stepButton("Back", () => setState(() => currentStep = 1)),
          ],

          const SizedBox(height: 24),

          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
              children: [
                const TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Log in',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _createAccountButton() {
    return _stepButton("Create Account", _handleCreateAccount);
  }

  Future<void> _handleCreateAccount() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (!RegExp(r'^[\w-\.]+@deped\.gov\.ph$').hasMatch(email)) {
      _showSnackBar("Email must end with @deped.gov.ph");
      return;
    }

    if (!RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@%^&*+#_])[A-Za-z\d@%^&*+#_]{8,}$')
        .hasMatch(password)) {
      _showSnackBar("Password must meet complexity rules");
      return;
    }

    final db = DatabaseService.instance;

    if (selectedRole == "Teacher") {
      await db.createTeacher({
        "teacher_name": name,
        "email": email,
        "password": password,
        "school": selectedInstitution,
        "district": selectedDistrict,
        "division": selectedDivision,
        "region": selectedRegion,
        "status": "active",
      });
    } else {
      await db.createAdmin({
        "admin_name": name,
        "email": email,
        "password": password,
        "school": selectedInstitution,
        "district": selectedDistrict,
        "division": selectedDivision,
        "region": selectedRegion,
        "status": "active",
      });
    }

    _showSnackBar("Account created successfully", isError: false);

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.black : Colors.green[700],
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'login_page.dart';

const Map<String, Map<String, List<String>>> regionHierarchy = {
  "NCR": {
    "Quezon City": ["District 1", "District 2", "District 3", "District 4"],
    "Manila": ["District I", "District II", "District III", "District IV"],
  },
  "Region IV-A": {
    "Laguna": ["Calamba", "Los Baños", "Biñan"],
    "Cavite": ["Imus", "Dasmariñas", "Bacoor"],
  },
};

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
  final institutionController = TextEditingController();

  bool obscure = true;
  int currentStep = 1;

  String? selectedRole;
  String? selectedRegion;
  String? selectedDivision;
  String? selectedDistrict;

  final List<String> accountRole = ['Teacher', 'Admin'];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    institutionController.dispose();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Image.asset('assets/kids.png', width: 220),
          const SizedBox(height: 24),
          _title(),
          const SizedBox(height: 20),
          _formHeader(),
          const SizedBox(height: 16),
          _form(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ================= DESKTOP (FIXED) =================

  Widget _desktopLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: SizedBox(
          width: 1100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Image.asset('assets/kids.png', width: 400),
                    ),
                    const SizedBox(height: 24),
                    _title(),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // RIGHT PANEL (SCROLL SAFE)
              Expanded(
                flex: 4,
                child: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI PARTS =================

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
          fontSize: 30,
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
    ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
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
          if (currentStep == 1) ...[
            _label('Account Role'),
            _dropdown(
              hint: 'Choose Role',
              items: accountRole,
              value: selectedRole,
              onChanged: (v) => setState(() => selectedRole = v),
            ),
            const SizedBox(height: 16),

            _label('Region'),
            _dropdown(
              hint: 'Select Region',
              items: regionHierarchy.keys.toList(),
              value: selectedRegion,
              onChanged: (v) {
                setState(() {
                  selectedRegion = v;
                  selectedDivision = null;
                  selectedDistrict = null;
                });
              },
            ),
            const SizedBox(height: 16),

            _label('Division'),
            _dropdown(
              hint: 'Select Division',
              items: selectedRegion == null
                  ? []
                  : regionHierarchy[selectedRegion!]!.keys.toList(),
              value: selectedDivision,
              onChanged: selectedRegion == null
                  ? null
                  : (v) {
                      setState(() {
                        selectedDivision = v;
                        selectedDistrict = null;
                      });
                    },
            ),
            const SizedBox(height: 16),

            _label('District'),
            _dropdown(
              hint: 'Select District',
              items: (selectedRegion != null && selectedDivision != null)
                  ? regionHierarchy[selectedRegion!]![selectedDivision!]!
                  : [],
              value: selectedDistrict,
              onChanged: selectedDivision == null
                  ? null
                  : (v) => setState(() => selectedDistrict = v),
            ),
            const SizedBox(height: 16),

            _label('Institution / School Name'),
            _input(
              controller: institutionController,
              hint: 'e.g. San Isidro Child Development Center',
            ),
            const SizedBox(height: 24),

            _stepButton("Next", () {
              if (selectedRole == null ||
                  selectedRegion == null ||
                  selectedDivision == null ||
                  selectedDistrict == null ||
                  institutionController.text.trim().isEmpty) {
                _showSnackBar("Please complete all required fields");
                return;
              }
              setState(() => currentStep = 2);
            }),
          ],

          if (currentStep == 2) ...[
            _label('Your Name'),
            _input(controller: nameController, hint: 'Juan Dela Cruz'),
            const SizedBox(height: 18),

            _label('Your Email'),
            _input(controller: emailController, hint: 'juan@deped.gov.ph'),
            const SizedBox(height: 18),

            _label('Set Password'),
            _passwordInput(),
            const SizedBox(height: 24),

            _stepButton("Create Account", _handleCreateAccount),
            const SizedBox(height: 12),
            _stepButton("Back", () => setState(() => currentStep = 1)),
          ],

          const SizedBox(height: 24),

          Center(
            child: RichText(
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

  // ================= LOGIC =================

  Future<void> _handleCreateAccount() async {
    final db = DatabaseService.instance;

    if (selectedRole == "Teacher") {
      await db.createTeacher({
        "teacher_name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "school": institutionController.text.trim(),
        "district": selectedDistrict,
        "division": selectedDivision,
        "region": selectedRegion,
        "status": "active",
      });
    } else {
      await db.createAdmin({
        "admin_name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "school": institutionController.text.trim(),
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


import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({Key? key}): super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  bool obscure = true;

  String? selectedRole;
  String? selectedInstitution;
  String? selectedDistrict;
  String? selectedDivision;
  String? selectedRegion;

  final List<String> accountRole = ['Teacher', 'Admin'];
  final List<String> institutions = ['A','B','C'];
  final List<String> district = ['A', 'B'];
  final List <String> division = ['A', 'B'];
  final List<String> region = ['A', 'B'];


  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
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
          builder: (context, constraints){
            return constraints.maxWidth > 700
                ? _desktopLayout()
                : _mobileLayout();
          },
        ),
      ),
    );
  }
  // Phone Layout
Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal:24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height:80),

          Image.asset(
            'assets/kids.png',
            width: 220,
          ),
          const SizedBox(height:24),
          _title(),

          const SizedBox(height:40),

          _formHeader(),
          Align(
            alignment: Alignment.centerLeft,
            child: _form()
          ),
          const SizedBox(height:24),
        ],
      ),
    );
}
// Desktop Layout
Widget _desktopLayout(){
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
                    padding: const EdgeInsets.only(left:50),
                    child: Image.asset(
                      'assets/kids.png',
                      width: 400,
                    ),
                  ),
                  const SizedBox(height:22),
                  _title(),
                ],
              ),
            ),
            const SizedBox(width:30),

            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _formHeader(),
                        const SizedBox(height:20),
                        _form(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
// Title
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
// Form
Widget _formHeader(){
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "Create an Account",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

Widget _label(String text){
    return Padding(
      padding: const EdgeInsets.only(bottom:6),
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
      decoration:  InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item){
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item)
        );
      }).toList(),
      onChanged: onChanged,
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
        // prefixIcon: const Icon(Icons.lock_outline, size:20),
        suffixIcon: IconButton(
          icon: Icon(
              size: 20,
              obscure ? Icons.visibility_off : Icons.visibility
          ),
          onPressed: (){
            setState(() {
              obscure = !obscure;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(vertical:14, horizontal: 16),
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
    IconData ? icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        // prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

Widget _createAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: (){
          if (_formKey.currentState!.validate()){
            // Logic here
          }
        },
        child: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
      ),
      ),
    );
}

Widget _form(){
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Role
          _label('Please choose an account to access the portal'),
          _dropdown(
              hint: 'Choose an Account',
              items: accountRole,
              value: selectedRole,
              onChanged: (v) => setState(() => selectedRole = v),
          ),
              const SizedBox(height:16),
          // Institution
          _label('Choose Institution:'),
          _dropdown(
            hint: '',
            items: institutions,
            value: selectedInstitution,
            onChanged: (v) => setState(() => selectedInstitution = v),
          ),
            const SizedBox(height:16),

          // District, Division, and Region
          LayoutBuilder(
            builder: (context, constraints) {
              // MOBILE → stack vertically
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _dropdown(
                      hint: 'District',
                      items: district,
                      value: selectedDistrict,
                      onChanged: (v) => setState(() => selectedDistrict = v),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      hint: 'Division',
                      items: division,
                      value: selectedDivision,
                      onChanged: (v) => setState(() => selectedDivision = v),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      hint: 'Region',
                      items: region,
                      value: selectedRegion,
                      onChanged: (v) => setState(() => selectedRegion = v),
                    ),
                  ],
                );
              }

              // DESKTOP/TABLET → row
              return Row(
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
              );
            },
          ),

          const SizedBox(height:18),
          // Email
          _label('Your Email:'),
          _input(
            controller: emailController,
            hint: 'juan.delacruz@deped.gov.ph',
          ),
          const SizedBox(height:18),

          // Password
          _label('Set Password: '),
          _passwordInput(),

      const SizedBox(height: 24),

      _createAccountButton(),

      const SizedBox(height:16),

      Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Log in',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {
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



}
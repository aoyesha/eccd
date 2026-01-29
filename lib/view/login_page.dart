import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:eccd/view/register_page.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}): super(key: key);

  @override
  State<LoginPage> createState()=> _LoginPageState();
}

class _LoginPageState extends State<LoginPage> { // Key is used to validated email and password together and to block login until inputs are correct
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController(); //
  final passwordController = TextEditingController();

  bool obscure = true; // hide password
  String role = 'Teacher';

  @override
  void dispose() {
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
  // Mobile Layout
Widget _mobileLayout() {
   return SingleChildScrollView(
     padding: const EdgeInsets.symmetric(horizontal: 24),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
       children: [
         const SizedBox(height:80),

         Image.asset(
           'assets/kids.png',
           width: 220,
         ),
         const SizedBox(height: 24),
         _title(),

         const SizedBox(height:40),

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
  Widget _desktopLayout() {
    return Center(
      child: SizedBox(
        width: 1100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Expanded(
              flex:5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:50),
                    child: Image.asset(
                      'assets/kids.png',
                      width:400,
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
                   child: _form(),
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
            // icon: Icons.email_outlined,
          ),
          const SizedBox(height: 18),
          _label('Password:'),
          _passwordInput(),
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
                  const TextSpan(
                    text: "Don't have an account yet? "
                  ),
                  TextSpan(
                    text: "Sign Up",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = (){
                      Get.to(()=> const RegisterPage());
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
  // Label
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

// Password
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

// Role
Widget _roleSelector(){
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _radio('Teacher'),
          const SizedBox(width:35),
          _radio('Admin')
        ],
      ),
    );
}

Widget _radio(String value){
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: role,
          fillColor: MaterialStateProperty.resolveWith<Color>(
              (states){
                return Colors.white;
              },
          ),
          onChanged: (v){
            setState(() {
              role = v!;
            }
            );
          },
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
}

// Button
Widget _loginButton() {
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
        onPressed: () {
          if (_formKey.currentState!.validate()){
            // insert logic here
          }
        },
        child: const Text(
          'Log in',
            style: TextStyle(
                fontSize: 15,
                color: Colors.white,
            ),
        )
      )
    );
}



}
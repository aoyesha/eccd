import 'package:eccd/view/teacher_add_learner_profile.dart';
import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';

class CreateNewClassPage extends StatelessWidget {
  const CreateNewClassPage({Key? key})
  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
        selectedIndex: 1,
        onItemSelected: (_) {},
      )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > 700
              ? _desktopLayout(context)
              : _mobileLayout(context);
        },
      ),
    );
  }
  Widget _mobileLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(constraints:BoxConstraints (
              minHeight: MediaQuery.of(context).size.height,
            ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _form(context, maxWidth: 420),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _desktopLayout(BuildContext context){
    return Row(
      children: [
        Navbar(
          selectedIndex: 1,
          onItemSelected: (_) {},
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _form(context, maxWidth: 480),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context, {required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Create New Class",
              style:
                TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                ),
            ),
          ),
          const SizedBox(height: 32),

          _label("Level: *"),
          _input(),
          const SizedBox(height: 16),

          _label("School Year: *"),
          Row(
            children: [
              Expanded(
                child: _yearBox("Start Year")
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _yearBox("End Year")
              ),
            ],
          ),
          const SizedBox(height: 16),

          _label("Section: *"),
          _input(),
          const SizedBox(height:16),

          _label("Import Learner's Profile:"),
          _fileBox(),
          const SizedBox(height: 16),

          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherAddProfilePage(),
                  ),
                );
              },
              child: const Text(
              "Add Learner Profile",
              style: TextStyle(
                color: Color(0xFFE64843),
                fontWeight: FontWeight.w600,
    ),
              ),
            ),
          ),
        const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE64843),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: (){},
              child: const Text(
                  "Save",
                      style: TextStyle(
                      color: Colors.white
    )),
            ),
          ),
        ],
      )
    );
  }
  Widget _input() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
  Widget _yearBox(String hint){
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
  Widget _fileBox(){
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: ".csv / .xlsx",
        suffixIcon: const Icon(Icons.upload_file),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
  Widget _label(String text){
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
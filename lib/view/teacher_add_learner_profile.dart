import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';

class TeacherAddProfilePage extends StatefulWidget {
  const TeacherAddProfilePage({Key? key}) : super(key: key);

  @override
  State<TeacherAddProfilePage> createState() => _TeacherAddProfilePageState();
}

class _TeacherAddProfilePageState extends State<TeacherAddProfilePage> {
  static const sexOptions = ["Male", "Female"];
  static const birthOrderOptions = ["1st", "2nd", "3rd", "4th", "5th", "6th+"];
  static const siblingOptions = ["0", "1", "2", "3", "4", "5", "6+"];
  static const educationOptions = [
    "Elementary",
    "High School",
    "College",
    "Post Graduate"
  ];

  String? selectedHand;

  @override
  Widget build(BuildContext context){
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
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
                padding: const EdgeInsets.all(32),
                child: _form(context, maxWidth: 760),
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
              "Add Learner Profile",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          _section("Personal Information"),

          _row3(
            _field("Surname:*"),
            _field("First Name:*"),
            _field("Middle Name:*"),
          ),

          _row3(
            _dropdown("Sex:*", sexOptions),
            _field("Date of Birth:*"),
            _field("LRN:*"),
          ),

          _row2(
            _dropdown("Order of Birth:*", birthOrderOptions),
            _dropdown("Number of Siblings:*", siblingOptions),
          ),

          const SizedBox(height: 12),
          _label("Handedness"),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 400) {
                return Column(
                  children: [
                    _handButton("Left"),
                    const SizedBox(height: 8),
                    _handButton("Right"),
                    const SizedBox(height: 8),
                    _handButton("None yet"),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _handButton("Left")),
                  const SizedBox(width: 8),
                  Expanded(child: _handButton("Right")),
                  const SizedBox(width: 8),
                  Expanded(child: _handButton("None yet")),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _section("Address Information"),

          _row3(
            _field("City:*"),
            _field("Province:*"),
            _field("Barangay:*"),
          ),

          const SizedBox(height: 24),
          _section("Parents/Guardian Information"),

          const Text("Mother", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          _row3(
            _field("Full Name:*"),
            _field("Occupation:*"),
            _dropdown("Education:*", educationOptions),
          ),

          _row2(
            _field("Age at birth:*"),
            _field("Spouse Occupation:*"),
          ),

          const SizedBox(height: 16),
          const Text("Father", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          _row3(
            _field("Full Name:*"),
            _field("Occupation:*"),
            _dropdown("Education:*", educationOptions),
          ),

          _row2(
            _field("Age at birth:*"),
            _field("Spouse Occupation:*"),
          ),

          const SizedBox(height: 32),

          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Add New Student",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE64843),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
      )),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _field(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        _input(),
      ],
    );
  }

  Widget _dropdown(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (_) {},
          decoration: _decoration(),
        ),
      ],
    );
  }

  Widget _row2(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              a,
              const SizedBox(height: 12),
              b,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  Widget _row3(Widget a, Widget b, Widget c) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              a,
              const SizedBox(height: 12),
              b,
              const SizedBox(height: 12),
              c,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
            const SizedBox(width: 12),
            Expanded(child: c),
          ],
        );
      },
    );
  }

  Widget _input() {
    return TextField(decoration: _decoration());
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _handButton(String text) {
    final bool isSelected = selectedHand == text;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFE64843) : Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        setState(() {
          selectedHand = text;
        });
      },
      child: Text(
        text,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}

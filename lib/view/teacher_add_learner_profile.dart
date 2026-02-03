import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';

class TeacherAddProfilePage extends StatefulWidget {
  final int teacherId;
  final int classId;

  const TeacherAddProfilePage({Key? key, required this.teacherId, required  this.classId,}) : super(key: key);

  @override
  State<TeacherAddProfilePage> createState() => _TeacherAddProfilePageState();
}

class _TeacherAddProfilePageState extends State<TeacherAddProfilePage> {
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController givenNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lrnController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentOccupationController = TextEditingController();
  final TextEditingController ageMotherController = TextEditingController();
  final TextEditingController spouseOccupationController = TextEditingController();

  String? selectedSex;
  String? selectedBirthOrder;
  String? selectedSiblings;
  String? selectedHand;

  static const sexOptions = ["Male", "Female"];
  static const birthOrderOptions = ["1st", "2nd", "3rd", "4th", "5th", "6th+"];
  static const siblingOptions = ["0", "1", "2", "3", "4", "5", "6+"];
  static const educationOptions = [
    "Elementary",
    "High School",
    "College",
    "Post Graduate"
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
        selectedIndex: 1,
        onItemSelected: (_) {}, teacherId: widget.teacherId,
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
          teacherId: widget.teacherId,
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
            _field("Surname:*", surnameController),
            _field("First Name:*", givenNameController),
            _field("Middle Name:*", middleNameController),
          ),

          _row3(
            _dropdown("Sex:*", sexOptions, (v) => selectedSex = v),
            _field("Date of Birth:*", birthdayController),
            _field("LRN:*", lrnController),
          ),

          _row2(
            _dropdown("Order of Birth:*", birthOrderOptions,
                    (v) => selectedBirthOrder = v),
            _dropdown("Number of Siblings:*", siblingOptions,
                    (v) => selectedSiblings = v),
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
            _field("City:*", cityController),
            _field("Province:*", provinceController),
            _field("Barangay:*", barangayController),
          ),

          const SizedBox(height: 24),
          _section("Parents/Guardian Information"),

          const Text("Mother", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          _row3(
            _field("Parent Name:*", parentNameController),
            _field("Occupation:*", parentOccupationController),
            _dropdown("Education:*", educationOptions, (_) {}),
          ),

          _row2(
            _field("Age when gave birth:*", ageMotherController),
            _field("Spouse Occupation:*", spouseOccupationController),
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
                  onPressed: _addNewStudent,
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

  Future<void> _addNewStudent() async {
    // --- Validation logic ---
    if (surnameController.text.trim().isEmpty ||
        givenNameController.text.trim().isEmpty ||
        middleNameController.text.trim().isEmpty ||
        birthdayController.text.trim().isEmpty ||
        lrnController.text.trim().isEmpty ||
        selectedSex == null ||
        selectedBirthOrder == null ||
        selectedSiblings == null ||
        selectedHand == null ||
        cityController.text.trim().isEmpty ||
        provinceController.text.trim().isEmpty ||
        barangayController.text.trim().isEmpty ||
        parentNameController.text.trim().isEmpty ||
        parentOccupationController.text.trim().isEmpty ||
        ageMotherController.text.trim().isEmpty ||
        spouseOccupationController.text.trim().isEmpty) {
      _showErrorSnackBar("Please fill all required fields.");
      return;
    }

    // LRN must be 12 digits
    if (!RegExp(r'^\d{12}$').hasMatch(lrnController.text.trim())) {
      _showErrorSnackBar("LRN must be a 12-digit number.");
      return;
    }

    // Birthday validation MM/DD/YYYY
    if (!RegExp(r'^(0[1-9]|1[0-2])/([0-2][0-9]|3[01])/(\d{4})$')
        .hasMatch(birthdayController.text.trim())) {
      _showErrorSnackBar("Birthday must be in MM/DD/YYYY format.");
      return;
    }

    // Age when gave birth must be a number
    if (int.tryParse(ageMotherController.text.trim()) == null) {
      _showErrorSnackBar("Age when gave birth must be a number.");
      return;
    }

    try {
      final db = await DatabaseService.instance.getDatabase();

      // Check if LRN already exists
      final existingLRN = await db.query(
        'learner_information_table',
        where: 'lrn = ?',
        whereArgs: [int.parse(lrnController.text.trim())],
      );

      if (existingLRN.isNotEmpty) {
        _showErrorSnackBar("This LRN already exists. Please use a different one.");
        return;
      }

      // --- Prepare data ---
      final studentData = {
        'class_id': widget.classId,
        'surname': surnameController.text.trim(),
        'given_name': givenNameController.text.trim(),
        'middle_name': middleNameController.text.trim(),
        'sex': selectedSex,
        'lrn': int.parse(lrnController.text.trim()),
        'birthday': birthdayController.text.trim(),
        'handedness': selectedHand ?? 'RIGHT',
        'birth_order': selectedBirthOrder ?? '1st',
        'barangay': barangayController.text.trim(),
        'city': cityController.text.trim(),
        'province': provinceController.text.trim(),
        'parent_name': parentNameController.text.trim(),
        'parent_occupation': parentOccupationController.text.trim(),
        'age_mother_at_birth': int.parse(ageMotherController.text.trim()),
        'spouse_occupation': spouseOccupationController.text.trim(),
        'number_of_siblings': int.parse(selectedSiblings ?? '0'),
        'status': 'active',
      };

      await db.insert('learner_information_table', studentData);

      if (!mounted) return;

      Navigator.pop(context, true); // Return to class list page
      _showErrorSnackBar("New Student Successfully Added."); // success snackbar

    } catch (e) {
      _showErrorSnackBar("Failed to save student: $e");
    }
  }



  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _field(String label, [TextEditingController? controller]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(controller: controller, decoration: _decoration()),
      ],
    );
  }


  Widget _dropdown(String label, List<String> items, [Function(String?)? onChanged]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged == null
              ? (_) {}
              : (v) {
            setState(() {
              onChanged(v);
            });
          },
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

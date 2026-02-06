import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';

class TeacherAddProfilePage extends StatefulWidget {
  final int teacherId;
  final int classId;

  const TeacherAddProfilePage({
    Key? key,
    required this.teacherId,
    required this.classId,
  }) : super(key: key);

  @override
  State<TeacherAddProfilePage> createState() => _TeacherAddProfilePageState();
}

class _TeacherAddProfilePageState extends State<TeacherAddProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final surnameController = TextEditingController();
  final givenNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lrnController = TextEditingController();
  final birthdayController = TextEditingController();

  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final barangayController = TextEditingController();

  final parentNameController = TextEditingController();
  final parentOccupationController = TextEditingController();
  final ageMotherController = TextEditingController();
  final spouseOccupationController = TextEditingController();

  DateTime? selectedBirthDate;
  String? selectedSex;
  String? selectedBirthOrder;
  String? selectedSiblings;

  static const sexOptions = ["Male", "Female"];
  static const birthOrderOptions = ["1st", "2nd", "3rd", "4th", "5th", "6th+"];
  static const siblingOptions = ["0", "1", "2", "3", "4", "5", "6+"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              teacherId: widget.teacherId,
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > 700
              ? _desktopLayout()
              : _mobileLayout();
        },
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _form(),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Navbar(
          selectedIndex: 1,
          onItemSelected: (_) {},
          teacherId: widget.teacherId,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(child: SizedBox(width: 720, child: _form())),
          ),
        ),
      ],
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Add Learner Profile",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Student identifiers
          _field("Surname*", surnameController),
          _field("First Name*", givenNameController),
          _field("Middle Name*", middleNameController),

          _dropdown("Sex*", sexOptions, (v) => selectedSex = v),
          _dateField(),
          _field("LRN (12 digits)*", lrnController),

          _dropdown(
            "Birth Order*",
            birthOrderOptions,
            (v) => selectedBirthOrder = v,
          ),
          _dropdown(
            "Number of Siblings*",
            siblingOptions,
            (v) => selectedSiblings = v,
          ),

          const SizedBox(height: 16),

          // Address
          const Text(
            "Address Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          _field("Province*", provinceController),
          _field("City / Municipality*", cityController),
          _field("Barangay / Village*", barangayController),

          const SizedBox(height: 16),

          // Parents
          const Text(
            "Parent / Guardian Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          _field("Parent Name*", parentNameController),
          _field("Parent Occupation*", parentOccupationController),
          _field("Mother's Age at Birth*", ageMotherController),
          _field("Spouse Occupation*", spouseOccupationController),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _saveLearner,
              child: const Text("Save Learner"),
            ),
          ),
        ],
      ),
    );
  }

  // Save student info

  Future<void> _saveLearner() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSex == null ||
        selectedBirthOrder == null ||
        selectedSiblings == null ||
        selectedBirthDate == null) {
      _snack("Please complete all required fields.");
      return;
    }

    try {
      final db = await DatabaseService.instance.getDatabase();

      final existing = await db.query(
        'learner_information_table',
        where: 'lrn = ?',
        whereArgs: [lrnController.text.trim()],
      );

      if (existing.isNotEmpty) {
        _snack("LRN already exists.");
        return;
      }

      await db.insert('learner_information_table', {
        'class_id': widget.classId,
        'surname': surnameController.text.trim(),
        'given_name': givenNameController.text.trim(),
        'middle_name': middleNameController.text.trim(),
        'sex': selectedSex,
        'lrn': lrnController.text.trim(),
        'birthday': selectedBirthDate!.toIso8601String(),
        'birth_order': selectedBirthOrder,
        'number_of_siblings': int.parse(selectedSiblings!),

        'province': provinceController.text.trim(),
        'city': cityController.text.trim(),
        'barangay': barangayController.text.trim(),

        'parent_name': parentNameController.text.trim(),
        'parent_occupation': parentOccupationController.text.trim(),
        'age_mother_at_birth': int.parse(ageMotherController.text.trim()),
        'spouse_occupation': spouseOccupationController.text.trim(),
        'status': 'active',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Learner successfully added"),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.pop(context, true);
    } catch (e) {
      _snack("Error saving learner: $e");
    }
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => onChanged(v)),
        validator: (v) => v == null ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        readOnly: true,
        validator: (_) => selectedBirthDate == null ? "Required" : null,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2020),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              selectedBirthDate = picked;
              birthdayController.text =
                  "${picked.month}/${picked.day}/${picked.year}";
            });
          }
        },
        controller: birthdayController,
        decoration: InputDecoration(
          labelText: "Date of Birth*",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

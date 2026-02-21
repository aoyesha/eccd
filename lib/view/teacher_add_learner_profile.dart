import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../util/navbar.dart';

class TeacherAddLearnerProfilePage extends StatefulWidget {
  final String role;
  final int userId; // teacher_id

  final int classId;
  final int? learnerId; // null = add, not null = edit

  const TeacherAddLearnerProfilePage({
    Key? key,
    required this.role,
    required this.userId,
    required this.classId,
    this.learnerId,
  }) : super(key: key);

  @override
  State<TeacherAddLearnerProfilePage> createState() =>
      _TeacherAddLearnerProfilePageState();
}

class _TeacherAddLearnerProfilePageState
    extends State<TeacherAddLearnerProfilePage> {
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
  String? selectedHandedness;

  bool _loading = false;

  static const sexOptions = ["Male", "Female"];
  static const birthOrderOptions = ["1st", "2nd", "3rd", "4th", "5th", "6th+"];
  static const siblingOptions = ["0", "1", "2", "3", "4", "5", "6+"];
  static const handednessOptions = [
    "Right-handed",
    "Left-handed",
    "Ambidextrous",
    "None yet",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.learnerId != null) {
      _loadLearnerForEdit();
    }
  }

  @override
  void dispose() {
    surnameController.dispose();
    givenNameController.dispose();
    middleNameController.dispose();
    lrnController.dispose();
    birthdayController.dispose();

    provinceController.dispose();
    cityController.dispose();
    barangayController.dispose();

    parentNameController.dispose();
    parentOccupationController.dispose();
    ageMotherController.dispose();
    spouseOccupationController.dispose();
    super.dispose();
  }

  Future<void> _loadLearnerForEdit() async {
    setState(() => _loading = true);
    try {
      final db = await DatabaseService.instance.getDatabase();
      final rows = await db.query(
        'learner_information_table',
        where: 'learner_id = ?',
        whereArgs: [widget.learnerId],
        limit: 1,
      );

      if (rows.isEmpty) return;
      final l = rows.first;

      surnameController.text = (l['surname'] ?? '').toString();
      givenNameController.text = (l['given_name'] ?? '').toString();
      middleNameController.text = (l['middle_name'] ?? '').toString();

      lrnController.text = (l['lrn'] ?? '').toString();

      selectedSex = (l['sex'] ?? '').toString().isEmpty
          ? null
          : (l['sex'] as String);
      selectedHandedness = (l['handedness'] ?? '').toString().isEmpty
          ? null
          : (l['handedness'] as String);
      selectedBirthOrder = (l['birth_order'] ?? '').toString().isEmpty
          ? null
          : (l['birth_order'] as String);

      final sib = l['number_of_siblings'];
      selectedSiblings = sib == null ? null : sib.toString();

      provinceController.text = (l['province'] ?? '').toString();
      cityController.text = (l['city'] ?? '').toString();
      barangayController.text = (l['barangay'] ?? '').toString();

      parentNameController.text = (l['parent_name'] ?? '').toString();
      parentOccupationController.text = (l['parent_occupation'] ?? '')
          .toString();

      final ageMother = l['age_mother_at_birth'];
      ageMotherController.text = ageMother == null ? '' : ageMother.toString();

      spouseOccupationController.text = (l['spouse_occupation'] ?? '')
          .toString();

      final bday = l['birthday']?.toString();
      if (bday != null) {
        final dt = DateTime.tryParse(bday);
        if (dt != null) {
          selectedBirthDate = dt;
          birthdayController.text = "${dt.month}/${dt.day}/${dt.year}";
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      appBar: AppBar(
        title: Text(
          widget.learnerId == null
              ? "Add Learner Profile"
              : "Edit Learner Profile",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFE64843),
      ),
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
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _form(),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Navbar(
          selectedIndex: 1,
          onItemSelected: (_) {},
          role: widget.role,
          userId: widget.userId,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: SizedBox(
                width: 720,
                child: _loading ? const CircularProgressIndicator() : _form(),
              ),
            ),
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
          const SizedBox(height: 8),
          const Text(
            "Student Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          _field("Surname*", surnameController),
          _field("First Name*", givenNameController),
          _field("Middle Name*", middleNameController),

          _dropdown(
            "Sex*",
            sexOptions,
            selectedSex,
            (v) => setState(() => selectedSex = v),
          ),
          _dateField(),
          _field("LRN (12 digits)*", lrnController),

          _dropdown(
            "Handedness*",
            handednessOptions,
            selectedHandedness,
            (v) => setState(() => selectedHandedness = v),
          ),

          _dropdown(
            "Birth Order*",
            birthOrderOptions,
            selectedBirthOrder,
            (v) => setState(() => selectedBirthOrder = v),
          ),

          _dropdown(
            "Number of Siblings*",
            siblingOptions,
            selectedSiblings,
            (v) => setState(() => selectedSiblings = v),
          ),

          const SizedBox(height: 16),
          const Text(
            "Address Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          _field("Province*", provinceController),
          _field("City / Municipality*", cityController),
          _field("Barangay / Village*", barangayController),

          const SizedBox(height: 16),
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
              child: Text(
                widget.learnerId == null ? "Save Learner" : "Save Changes",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLearner() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSex == null ||
        selectedBirthOrder == null ||
        selectedSiblings == null ||
        selectedHandedness == null ||
        selectedBirthDate == null) {
      _snack("Please complete all required fields.");
      return;
    }

    final lrn = lrnController.text.trim();
    final ageMother = ageMotherController.text.trim();

    // Check LRN numeric
    if (lrn.isEmpty || int.tryParse(lrn) == null) {
      _snack("LRN must be a numerical value.");
      return;
    }

    // Check LRN length
    if (lrn.length != 12) {
      _snack("LRN must be exactly 12 digits.");
      return;
    }

    // Check Mother's Age numeric
    if (ageMother.isEmpty || int.tryParse(ageMother) == null) {
      _snack("Mother's age at birth must be a numerical value.");
      return;
    }

    try {
      final db = await DatabaseService.instance.getDatabase();

      // If adding, ensure LRN is unique
      if (widget.learnerId == null) {
        final existing = await db.query(
          'learner_information_table',
          where: 'lrn = ?',
          whereArgs: [lrn],
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
          'handedness': selectedHandedness,
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
      } else {
        // If editing, allow same LRN, but block conflicts with other learners
        final conflict = await db.query(
          'learner_information_table',
          where: 'lrn = ? AND learner_id != ?',
          whereArgs: [lrn, widget.learnerId],
        );
        if (conflict.isNotEmpty) {
          _snack("LRN already exists for another learner.");
          return;
        }

        await db.update(
          'learner_information_table',
          {
            'surname': surnameController.text.trim(),
            'given_name': givenNameController.text.trim(),
            'middle_name': middleNameController.text.trim(),
            'sex': selectedSex,
            'lrn': lrnController.text.trim(),
            'birthday': selectedBirthDate!.toIso8601String(),
            'handedness': selectedHandedness,
            'birth_order': selectedBirthOrder,
            'number_of_siblings': int.parse(selectedSiblings!),
            'province': provinceController.text.trim(),
            'city': cityController.text.trim(),
            'barangay': barangayController.text.trim(),
            'parent_name': parentNameController.text.trim(),
            'parent_occupation': parentOccupationController.text.trim(),
            'age_mother_at_birth': int.parse(ageMotherController.text.trim()),
            'spouse_occupation': spouseOccupationController.text.trim(),
          },
          where: 'learner_id = ?',
          whereArgs: [widget.learnerId],
        );
      }

      if (!mounted) return;

      _snack(
        widget.learnerId == null
            ? "Learner successfully added"
            : "Learner updated",
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 350));
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
    String? value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
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
        controller: birthdayController,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedBirthDate ?? DateTime(2020),
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
        decoration: InputDecoration(
          labelText: "Date of Birth*",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  void _snack(String msg, {bool isError = true}) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isError ? Colors.black : Colors.green[700],
      content: Row(
        children: [
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.white)),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      duration: const Duration(seconds: 5),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

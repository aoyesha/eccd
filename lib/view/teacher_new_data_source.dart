import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';
import '../services/csv_import_service.dart';
import 'landing_page.dart';

class CreateNewClassPage extends StatefulWidget {
  final int teacherId;

  const CreateNewClassPage({Key? key, required this.teacherId})
    : super(key: key);

  @override
  State<CreateNewClassPage> createState() => _CreateNewClassPageState();
}

class _CreateNewClassPageState extends State<CreateNewClassPage> {
  final _formKey = GlobalKey<FormState>();

  final gradeController = TextEditingController();
  final sectionController = TextEditingController();
  final startYearController = TextEditingController();
  final endYearController = TextEditingController();

  File? selectedCsvFile;

  @override
  void dispose() {
    gradeController.dispose();
    sectionController.dispose();
    startYearController.dispose();
    endYearController.dispose();
    super.dispose();
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: SizedBox(width: 520, child: _form()),
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
          const Center(
            child: Text(
              "Create New Class",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          _field("Grade *", gradeController),
          _field("Section *", sectionController),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _yearField("Start Year", startYearController)),
              const SizedBox(width: 12),
              Expanded(child: _yearField("End Year", endYearController)),
            ],
          ),

          const SizedBox(height: 20),

          _csvPicker(),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE64843),
              ),
              onPressed: _saveClass,
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CSV PICKER =================

  Widget _csvPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Import Learners (CSV only)",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickCsv,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCsvFile?.path.split('/').last ?? "Select .csv file",
                    style: TextStyle(
                      color: selectedCsvFile == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.upload_file),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedCsvFile = File(result.files.single.path!);
      });
    }
  }

  // Saving

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;

    final start = int.tryParse(startYearController.text.trim());
    final end = int.tryParse(endYearController.text.trim());

    if (start == null || end == null || start >= end) {
      _snack("Invalid school year range");
      return;
    }

    final db = await DatabaseService.instance.getDatabase();

    final classId = await db.insert('class_table', {
      'class_level': gradeController.text.trim(),
      'class_section': sectionController.text.trim(),
      'start_school_year': start.toString(),
      'end_school_year': end.toString(),
      'teacher_id': widget.teacherId,
      'status': 'active',
    });

    // file import (csv palang)
    if (selectedCsvFile != null) {
      try {
        await CsvImportService.importLearnersFromCsv(
          file: selectedCsvFile!,
          classId: classId,
        );
      } catch (e) {
        _snack("CSV import failed: $e");
        return;
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LandingPage(role: "Teacher", teacherId: widget.teacherId),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
        decoration: _decoration(label),
      ),
    );
  }

  Widget _yearField(String label, TextEditingController c) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      validator: (v) =>
          v == null || !RegExp(r'^\d{4}$').hasMatch(v) ? "YYYY" : null,
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.black));
  }
}

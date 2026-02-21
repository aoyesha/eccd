import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../util/navbar.dart';
import 'landing_page.dart';

class AdminNewDataSourcePage extends StatefulWidget {
  final String role;
  final int userId; // admin_id

  const AdminNewDataSourcePage({
    Key? key,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdminNewDataSourcePage> createState() => _AdminNewDataSourcePageState();
}

class _AdminNewDataSourcePageState extends State<AdminNewDataSourcePage> {
  final _formKey = GlobalKey<FormState>();
  final institutionController = TextEditingController();

  File? selectedCsvFile;

  @override
  void dispose() {
    institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      appBar: AppBar(
        title: const Text("Create New Data Source"),
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
      child: _form(),
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
              "Create New Data Source",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          _field("Institution *", institutionController),
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
              onPressed: _saveDataSource,
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _csvPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Import Summary CSV (from lower office)",
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
                    selectedCsvFile?.path.split(Platform.pathSeparator).last ??
                        "Select .csv file",
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

  Future<void> _saveDataSource() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCsvFile == null) {
      _snack("Please attach a CSV file.");
      return;
    }

    // Admin dataset ingestion requires DB tables not yet in current schema.
    _snack("Admin ingestion not wired yet (tables pending).");

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LandingPage(role: widget.role, userId: widget.userId),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
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

  void _snack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.black));
  }
}

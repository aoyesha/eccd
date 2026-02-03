import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';
import '../view/landing_page.dart';

class CreateNewClassPage extends StatefulWidget {
  final int teacherId;

  const CreateNewClassPage({Key? key, required this.teacherId}) : super(key: key);

  @override
  State<CreateNewClassPage> createState() => _CreateNewClassPageState();
}

class _CreateNewClassPageState extends State<CreateNewClassPage> {
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  late int _currentTeacherId;

  @override
  void initState() {
    super.initState();
    _currentTeacherId = widget.teacherId;
  }

  @override
  void dispose() {
    _levelController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 1, onItemSelected: (_) {}, teacherId: widget.teacherId)
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _form(context, maxWidth: 420),
      ),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        Navbar(selectedIndex: 1, onItemSelected: (_) {}, teacherId: widget.teacherId),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _form(context, maxWidth: 480),
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
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          _label("Level: *"),
          _input(_levelController),

          const SizedBox(height: 16),

          _label("Section: *"),
          _input(_sectionController),

          const SizedBox(height: 16),

          _label("School Year: *"),
          Row(
            children: [
              Expanded(child: _yearBox(_startYearController, "Start Year")),
              const SizedBox(width: 12),
              Expanded(child: _yearBox(_endYearController, "End Year")),
            ],
          ),

          const SizedBox(height: 16),

          _label("Import Learner's Profile:"),
          _fileBox(),

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
              onPressed: _saveClass,
              child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _decoration(),
    );
  }

  Widget _yearBox(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _decoration(hint: hint),
    );
  }

  Widget _fileBox() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              ".csv / .xlsx",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Icon(Icons.upload_file, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  void _saveClass() async {
    final String startText = _startYearController.text.trim();
    final String endText = _endYearController.text.trim();

    if (_levelController.text.trim().isEmpty ||
        _sectionController.text.trim().isEmpty ||
        startText.isEmpty ||
        endText.isEmpty) {
      _showErrorSnackBar("Please fill all required fields");
      return;
    }

    final numericRegex = RegExp(r'^\d{4}$');
    if (!numericRegex.hasMatch(startText) || !numericRegex.hasMatch(endText)) {
      _showErrorSnackBar("School Year must be exactly 4 digits");
      return;
    }

    final int startYear = int.parse(startText);
    final int endYear = int.parse(endText);

    if (startYear >= endYear) {
      _showErrorSnackBar("End School Year must be greater than Start School Year");
      return;
    }

    final classData = {
      'class_level': _levelController.text.trim(),
      'class_section': _sectionController.text.trim(),
      'start_school_year': startText,
      'end_school_year': endText,
      'status': 'active',
      'teacher_id': _currentTeacherId,
    };

    final db = await DatabaseService.instance.getDatabase();
    await db.insert('class_table', classData);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LandingPage(role: "Teacher", teacherId: widget.teacherId),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

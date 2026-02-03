import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';
import '../view/landing_page.dart';

class CreateNewClassPage extends StatefulWidget {
  final int teacherId; // teacher ID passed from login/landing page

  const CreateNewClassPage({Key? key, required this.teacherId}) : super(key: key);

  @override
  State<CreateNewClassPage> createState() => _CreateNewClassPageState();
}

class _CreateNewClassPageState extends State<CreateNewClassPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  late int _currentTeacherId; // initialized in initState

  @override
  void initState() {
    super.initState();
    _currentTeacherId = widget.teacherId; // get logged-in teacher ID
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
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
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

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        Navbar(selectedIndex: 1, onItemSelected: (_) {}, teacherId: widget.teacherId),
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
      child: Form(
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

            _label("Level: *"),
            _input(_levelController),

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

            _label("Section: *"),
            _input(_sectionController),

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
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorStyle: const TextStyle(height: 0),
        helperText: " ",
      ),
    );
  }

  Widget _yearBox(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorStyle: const TextStyle(height: 0),
        helperText: " ",
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child:
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  void _saveClass() async {
    final String startText = _startYearController.text.trim();
    final String endText = _endYearController.text.trim();

    if (startText.isEmpty || endText.isEmpty || _levelController.text
        .trim()
        .isEmpty || _sectionController.text
        .trim()
        .isEmpty) {
      _showErrorSnackBar("Please fill all required fields");
      return;
    }

    final numericRegex = RegExp(r'^\d{4}$');
    if (!numericRegex.hasMatch(startText) || !numericRegex.hasMatch(endText)) {
      _showErrorSnackBar("School Year must be exactly 4 numeric digits");
      return;
    }

    final int startYear = int.parse(startText);
    final int endYear = int.parse(endText);

    if (startYear == endYear) {
      _showErrorSnackBar("Start and End School Year cannot be equal");
      return;
    }

    if (startYear > endYear) {
      _showErrorSnackBar(
          "End School Year must be greater than Start School Year");
      return;
    }

    final classData = {
      'class_level': _levelController.text.trim(),
      'class_section': _sectionController.text.trim(),
      'start_school_year': startText,
      'end_school_year': endText,
      'status': 'active',
      'teacher_id': _currentTeacherId, // now dynamic
    };

    final db = await DatabaseService.instance.getDatabase();
    await db.insert('class_table', classData);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LandingPage(
                role: "Teacher",
                teacherId: widget.teacherId, // dynamic value
              ),
        ),
      );
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
}

import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import 'teacher_checklist_page.dart';

class TeacherClassReportPage extends StatelessWidget {
  final String gradeLevel;
  final String section;

  const TeacherClassReportPage({
    Key? key,
    required this.gradeLevel,
    required this.section,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 0, onItemSelected: (_) {})
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _content(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        Navbar(selectedIndex: 0, onItemSelected: (_) {}),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _content(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Class Report",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "$gradeLevel $section",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        _tableRow(context, [
          "NO.",
          "NAME OF LEARNER",
          "SEX",
          "AGE",
          "STANDARD SCORE",
          "INTERPRETATION",
          "",
        ], isHeader: true),

        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
        _tableRow(context, ["", "", "", "", "", "", ""]),
      ],
    );
  }

  Widget _tableRow(BuildContext context, List<String> cells,
      {bool isHeader = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      child: Row(
        children: [
          _cell(cells[0], flex: 1, isHeader: isHeader),
          _cell(cells[1], flex: 3, isHeader: isHeader),
          _cell(cells[2], flex: 1, isHeader: isHeader),
          _cell(cells[3], flex: 1, isHeader: isHeader),
          _cell(cells[4], flex: 2, isHeader: isHeader),
          _cell(cells[5], flex: 2, isHeader: isHeader),
          _actionCell(context, isHeader: isHeader),
        ],
      ),
    );
  }

  Widget _cell(String text, {required int flex, bool isHeader = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _actionCell(BuildContext context, {bool isHeader = false}) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: isHeader
            ? const SizedBox()
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE64843),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TeacherChecklistPage(),
              ),
            );
          },
          child: const Text(
            "View Details",
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

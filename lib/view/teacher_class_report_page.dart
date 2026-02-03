import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import 'teacher_checklist_page.dart';

class TeacherClassReportPage extends StatelessWidget {
  final String gradeLevel;
  final String section;
  final int teacherId;

  const TeacherClassReportPage({
    Key? key,
    required this.gradeLevel,
    required this.section,
    required this.teacherId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 0, onItemSelected: (_) {}, teacherId: teacherId)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return isMobile
              ? _mobileLayout(context, isMobile)
              : _desktopLayout(context, isMobile);
        },
      ),
    );
  }

  Widget _mobileLayout(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 56, 12, 12),
              child: _content(context, isMobile),
            ),
          ),
        ),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Navbar(selectedIndex: 0, onItemSelected: (_) {}, teacherId: teacherId),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _content(context, isMobile),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Class Report",
          style: TextStyle(
            fontSize: isMobile ? 18 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$gradeLevel $section",
          style: TextStyle(
            fontSize: isMobile ? 11 : 14,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        _tableRow(context, [
          "NO.",
          "NAME OF LEARNER",
          "SEX",
          "AGE",
          "STANDARD SCORE",
          "INTERPRETATION",
          "",
        ], isHeader: true, isMobile: isMobile),

        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
        _tableRow(context, ["", "", "", "", "", "", ""], isMobile: isMobile),
      ],
    );
  }

  Widget _tableRow(
      BuildContext context,
      List<String> cells, {
        bool isHeader = false,
        required bool isMobile,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      child: Row(
        children: [
          _cell(cells[0], flex: 1, isHeader: isHeader, isMobile: isMobile),
          _cell(cells[1], flex: 3, isHeader: isHeader, isMobile: isMobile),
          _cell(cells[2], flex: 1, isHeader: isHeader, isMobile: isMobile),
          _cell(cells[3], flex: 1, isHeader: isHeader, isMobile: isMobile),
          _cell(cells[4], flex: 2, isHeader: isHeader, isMobile: isMobile),
          _cell(cells[5], flex: 2, isHeader: isHeader, isMobile: isMobile),
          _actionCell(context, isHeader: isHeader, isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _cell(
      String text, {
        required int flex,
        bool isHeader = false,
        required bool isMobile,
      }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 8,
          vertical: isMobile ? 6 : 12,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 9 : 12,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _actionCell(
      BuildContext context, {
        bool isHeader = false,
        required bool isMobile,
      }) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 8,
          vertical: isMobile ? 4 : 8,
        ),
        child: isHeader
            ? const SizedBox()
            : SizedBox(
          height: isMobile ? 24 : 36,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE64843),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding:
              EdgeInsets.symmetric(horizontal: isMobile ? 6 : 15),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherChecklistPage(
                    teacherId: teacherId,
                  ),
                ),
              );
            },

            child: Text(
              "View",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 9 : 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

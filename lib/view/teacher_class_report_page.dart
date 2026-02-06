import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';
import 'teacher_checklist_page.dart';

class TeacherClassReportPage extends StatefulWidget {
  final String gradeLevel;
  final String section;
  final int teacherId;
  final int classId;

  const TeacherClassReportPage({
    Key? key,
    required this.gradeLevel,
    required this.section,
    required this.teacherId,
    required this.classId,
  }) : super(key: key);

  @override
  State<TeacherClassReportPage> createState() => _TeacherClassReportPageState();
}

class _TeacherClassReportPageState extends State<TeacherClassReportPage> {
  List<Map<String, dynamic>> learners = [];

  @override
  void initState() {
    super.initState();
    _loadLearners();
  }

  Future<void> _loadLearners() async {
    final db = await DatabaseService.instance.getDatabase();

    final result = await db.query(
      'learner_information_table',
      where: 'class_id = ?',
      whereArgs: [widget.classId],
    );

    setState(() => learners = result);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              teacherId: widget.teacherId,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Navbar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              teacherId: widget.teacherId,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _content(isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(bool isMobile) {
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
        Text(
          "${widget.gradeLevel} ${widget.section}",
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        _tableHeader(isMobile),

        ...learners.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final student = entry.value;

          return _tableRow(index, student, isMobile);
        }),
      ],
    );
  }

  Widget _tableHeader(bool isMobile) {
    return _row(
      isMobile,
      isHeader: true,
      cells: const [
        "No",
        "Learner Name",
        "Sex",
        "Age",
        "Score",
        "Interpretation",
        "",
      ],
    );
  }

  Widget _tableRow(int index, Map<String, dynamic> student, bool isMobile) {
    return _row(
      isMobile,
      cells: [
        index.toString(),
        "${student['surname']}, ${student['given_name']} ${student['middle_name'] ?? ''}",
        student['sex'] ?? '',
        _computeAge(student['birthday']),
        "--",
        "--",
        "",
      ],
      action: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherChecklistPage(
              teacherId: widget.teacherId,
              classId: widget.classId,
              learnerId: student['learner_id'],
              learnerName: "${student['surname']}, ${student['given_name']}",
            ),
          ),
        );
      },
    );
  }

  Widget _row(
    bool isMobile, {
    required List<String> cells,
    bool isHeader = false,
    VoidCallback? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade200 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _cell(cells[0], 1, isMobile, isHeader),
          _cell(cells[1], 3, isMobile, isHeader),
          _cell(cells[2], 1, isMobile, isHeader),
          _cell(cells[3], 1, isMobile, isHeader),
          _cell(cells[4], 2, isMobile, isHeader),
          _cell(cells[5], 2, isMobile, isHeader),
          Expanded(
            flex: 2,
            child: isHeader
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      onPressed: action,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE64843),
                      ),
                      child: const Text(
                        "View",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, int flex, bool isMobile, bool isHeader) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 6 : 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 10 : 13,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _computeAge(String? birthday) {
    if (birthday == null) return "--";
    final dob = DateTime.tryParse(birthday);
    if (dob == null) return "--";
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age.toString();
  }
}

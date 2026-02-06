import 'package:eccd/view/teacher_add_learner_profile.dart';
import 'package:eccd/view/teacher_checklist_page.dart';
import 'package:eccd/view/teacher_class_report_page.dart';
import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';

class ClassListPage extends StatefulWidget {
  final int classId;
  final String gradeLevel;
  final String section;
  final int teacherId;

  const ClassListPage({
    Key? key,
    required this.classId,
    required this.gradeLevel,
    required this.section,
    required this.teacherId,
  }) : super(key: key);

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final db = await DatabaseService.instance.getDatabase();

    final result = await db.query(
      'learner_information_table',
      where: 'class_id = ? AND status = ?',
      whereArgs: [widget.classId, 'active'],
      orderBy: 'surname ASC',
    );

    setState(() {
      students = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              teacherId: widget.teacherId,
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return Row(
            children: [
              if (!isMobile)
                Navbar(
                  selectedIndex: 0,
                  onItemSelected: (_) {},
                  teacherId: widget.teacherId,
                ),
              Expanded(child: isMobile ? _mobileLayout() : _desktopLayout()),
            ],
          );
        },
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(
      child: Column(children: [_classContent(), _rightPanel()]),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Expanded(flex: 5, child: _classContent()),
        Expanded(flex: 3, child: _rightPanel()),
      ],
    );
  }

  Widget _classContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${widget.gradeLevel} ${widget.section}",
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("No learners added yet."),
            ),

          ...students.map(_studentTile).toList(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8b1c23),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeacherAddProfilePage(
                      teacherId: widget.teacherId,
                      classId: widget.classId,
                    ),
                  ),
                );

                if (result == true) {
                  await _loadStudents();
                }
              },
              child: const Text(
                "Add Student",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    return Card(
      child: ListTile(
        title: Text("${student['surname']}, ${student['given_name']}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherChecklistPage(
                teacherId: widget.teacherId,
                classId: widget.classId,
                learnerId: student['learner_id'],
                learnerName:
                    "${student['surname']}, ${student['given_name']} ${student['middle_name'] ?? ''}",
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _rightPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8b1c23),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeacherClassReportPage(
                      gradeLevel: widget.gradeLevel,
                      section: widget.section,
                      teacherId: widget.teacherId,
                      classId: widget.classId,
                    ),
                  ),
                );
              },
              child: const Text(
                "Class Report",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

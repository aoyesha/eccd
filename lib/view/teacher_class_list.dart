import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import 'package:eccd/view/teacher_add_learner_profile.dart';
import 'package:eccd/view/teacher_checklist_page.dart';
import 'package:eccd/view/teacher_class_report_page.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final db = await DatabaseService.instance.getDatabase();

    final result = await db.query(
      'learner_information_table',
      orderBy: 'surname ASC',
    );

    // SAFE FILTERING
    final filtered = result.where((student) {
      final classId = student['class_id'];
      return classId != null && classId == widget.classId;
    }).toList();

    // Active students first
    filtered.sort((a, b) {
      final aActive = a['status'] == 'active';
      final bActive = b['status'] == 'active';

      if (aActive != bActive) {
        return aActive ? -1 : 1;
      }

      return (a['surname'] ?? '')
          .toString()
          .compareTo((b['surname'] ?? '').toString());
    });

    setState(() {
      students = List<Map<String, dynamic>>.from(filtered);
      isLoading = false;
    });
  }

  Future<void> _updateStudentStatus(
      int learnerId, String newStatus) async {
    final db = await DatabaseService.instance.getDatabase();

    await db.update(
      'learner_information_table',
      {'status': newStatus},
      where: 'learner_id = ?',
      whereArgs: [learnerId],
    );

    await _loadStudents();
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
              Expanded(
                child: isMobile ? _mobileLayout() : _desktopLayout(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _classContent(),
          _rightPanel(),
        ],
      ),
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
            style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("No learners added yet."),
            )
          else
            ...students.map(_studentTile).toList(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1C23),
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
    final bool isActive = student['status'] == 'active';

    return Card(
      elevation: 1,
      child: ListTile(
        tileColor:
        isActive ? Colors.white : Colors.grey.shade300,
        title: Text(
          "${student['surname']}, ${student['given_name']}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
            isActive ? Colors.black : Colors.grey.shade700,
          ),
        ),
        leading: CircleAvatar(
          radius: 6,
          backgroundColor:
          isActive ? Colors.green : Colors.red,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final newStatus =
            value == 'activate' ? 'active' : 'inactive';

            await _updateStudentStatus(
              student['learner_id'],
              newStatus,
            );
          },
          itemBuilder: (_) => [
            if (!isActive)
              const PopupMenuItem(
                value: 'activate',
                child: Text('Activate'),
              ),
            if (isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: Text('Deactivate'),
              ),
          ],
        ),
        onTap: isActive
            ? () {
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
        }
            : null,
      ),
    );
  }

  Widget _rightPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _statusCard(),
          const SizedBox(height: 16),
          _chartCard(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1C23),
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

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Status",
              style:
              TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: 0,
              strokeWidth: 14,
              color: const Color(0xFF4A1511),
              backgroundColor:
              Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            "Class Chart",
            style:
            TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                _bar(10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height) {
    return Expanded(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius:
            BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

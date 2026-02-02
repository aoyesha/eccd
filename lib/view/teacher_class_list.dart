import 'package:eccd/view/teacher_add_learner_profile.dart';
import 'package:eccd/view/teacher_checklist_page.dart';
import 'package:eccd/view/teacher_class_report_page.dart';
import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';

class ClassListPage extends StatefulWidget {
  final String gradeLevel;
  final String section;

  const ClassListPage({
    Key? key,
    required this.gradeLevel,
    required this.section,
  }) : super(key: key);

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  List<Map<String, dynamic>> students = [
    {"name": "Cruz, Adrain M", "active": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 0, onItemSelected: (_) {})
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return Row(
            children: [
              if (!isMobile)
                Navbar(selectedIndex: 0, onItemSelected: (_) {}),
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
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Column(
            children: students.map((s) => _studentTile(s)).toList(),
          ),

          const SizedBox(height: 16),

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherAddProfilePage()),
                );
              },
              child: const Text("Add Student", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    return Material(
      color: student["active"] ? Colors.white : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(student["name"], style: const TextStyle(fontSize: 14)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherChecklistPage()),
          );
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 12,
              color: student["active"] ? Colors.green : Colors.transparent,
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                setState(() {
                  student["active"] = value == "activate";
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "activate",
                  child: Text("Activate"),
                ),
                PopupMenuItem(
                  value: "deactivate",
                  child: Text("Deactivate"),
                ),
              ],
            ),
          ],
        ),
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
                    ),
                  ),
                );
              },
              child: const Text("Class Report", style: TextStyle(color: Colors.white)),
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: 0,
              strokeWidth: 14,
              color: const Color(0xFF4A1511),
              backgroundColor: Colors.grey.shade300,
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Class Chart", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

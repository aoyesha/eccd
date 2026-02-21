import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../util/navbar.dart';
import 'teacher_new_data_source.dart';
import 'teacher_class_list.dart';
import 'my_summary_page.dart';

class LandingPage extends StatefulWidget {
  final int userId;
  final String role; // "Teacher" | "Admin"

  const LandingPage({Key? key, required this.userId, required this.role})
    : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  List<Map<String, dynamic>> _activeClasses = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadClasses();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    if (widget.role != 'Teacher') {
      setState(() => _activeClasses = []);
      return;
    }

    final rows = await DatabaseService.instance.getActiveClassesByTeacher(
      widget.userId,
    );
    if (!mounted) return;
    setState(() => _activeClasses = rows);
  }

  Future<void> _deactivateClass(int classId) async {
    await DatabaseService.instance.setClassStatus(
      classId,
      DatabaseService.statusDeactivated,
    );
    await _loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          Navbar(
            selectedIndex: 0,
            onItemSelected: (_) {},
            userId: widget.userId,
            role: widget.role,
          ),
          Expanded(
            child: Column(
              children: [
                _topBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _myClassesTab(),
                      // IMPORTANT: summary is embedded here (no extra navbar)
                      MySummaryPage(
                        userId: widget.userId,
                        role: widget.role,
                        embedded: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Responsive headline size to avoid overflow on smaller widths
    final double titleSize = w < 900 ? 28 : 34;

    return Container(
      // Bring it down: taller bar + bottom aligned
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.bottomLeft,
      decoration: const BoxDecoration(color: AppColors.bg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          Text(
            'Early Childhood Development Checklist',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.maroon,
            tabs: const [
              Tab(text: 'My Classes'),
              Tab(text: 'My Summary'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _myClassesTab() {
    final cards = <Widget>[
      for (final c in _activeClasses)
        _NotebookCard(
          color: _pastelForClassId(c['class_id'] as int),
          schoolYear: '${c['start_school_year']}-${c['end_school_year']}',
          grade: '${c['class_level']}',
          section: '${c['class_section']}',
          onOpen: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClassListPage(
                  userId: widget.userId,
                  role: widget.role,
                  classId: c['class_id'] as int,
                  gradeLevel: (c['class_level'] ?? '').toString(),
                  section: (c['class_section'] ?? '').toString(),
                ),
              ),
            );
            _loadClasses();
          },
          onDeactivate: () async {
            final classId = c['class_id'] as int;

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Deactivate class?'),
                content: const Text(
                  'This will move the class to Archive. You can reactivate it later.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Deactivate'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await _deactivateClass(classId);
            }
          },
        ),

      _AddClassCard(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TeacherNewDataSourcePage(
                userId: widget.userId,
                role: widget.role,
              ),
            ),
          );
          _loadClasses();
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(spacing: 18, runSpacing: 18, children: cards),
      ),
    );
  }

  /// Pastel colors that look random but stay consistent per classId.
  Color _pastelForClassId(int classId) {
    const palette = <Color>[
      Color(0xFFE3F2FD), // light blue
      Color(0xFFE8F5E9), // light green
      Color(0xFFFFF3E0), // light orange
      Color(0xFFF3E5F5), // light purple
      Color(0xFFFFEBEE), // light red/pink
      Color(0xFFE0F2F1), // teal tint
      Color(0xFFFFFDE7), // light yellow
      Color(0xFFEDE7F6), // lavender tint
    ];
    return palette[classId.abs() % palette.length];
  }
}

class _AddClassCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddClassCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 260,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add, size: 44),
                SizedBox(height: 10),
                Text(
                  'Add Class',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a new class\nfor the school year',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotebookCard extends StatelessWidget {
  final Color color;
  final String schoolYear;
  final String grade;
  final String section;
  final VoidCallback onOpen;
  final VoidCallback onDeactivate;

  const _NotebookCard({
    required this.color,
    required this.schoolYear,
    required this.grade,
    required this.section,
    required this.onOpen,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 260,
      child: InkWell(
        onTap: onOpen,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.only(left: 18),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (v) {
                          if (v == 'open') onOpen();
                          if (v == 'deactivate') onDeactivate();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'open', child: Text('Open')),
                          PopupMenuItem(
                            value: 'deactivate',
                            child: Text('Deactivate'),
                          ),
                        ],
                      ),
                    ),

                    // This area expands/shrinks safely
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          Text(
                            schoolYear,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            grade,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Allow section to take remaining space but never overflow
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                section,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

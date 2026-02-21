import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../util/navbar.dart';
import 'teacher_class_list.dart';

class ArchivePage extends StatefulWidget {
  final String role;
  final int userId;

  const ArchivePage({Key? key, required this.role, required this.userId})
    : super(key: key);

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage>
    with TickerProviderStateMixin {
  late final TabController _topTab;
  late final TabController _classTab;
  late final TabController _learnerTab;

  @override
  void initState() {
    super.initState();
    _topTab = TabController(length: 2, vsync: this);
    _classTab = TabController(length: 3, vsync: this);
    _learnerTab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _topTab.dispose();
    _classTab.dispose();
    _learnerTab.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _classes(String status) async {
    if (widget.role != "Teacher") return [];
    return DatabaseService.instance.getClassesByTeacherAndStatus(
      widget.userId,
      status,
    );
  }

  Future<List<Map<String, dynamic>>> _learnersAllTeacher(String status) async {
    if (widget.role != "Teacher") return [];
    final db = await DatabaseService.instance.getDatabase();

    // get all teacher classes (any status) then query learners by status across them
    final classes = await db.query(
      DatabaseService.classTable,
      where: 'teacher_id = ?',
      whereArgs: [widget.userId],
    );

    final classIds = classes
        .map((e) => e['class_id'])
        .whereType<int>()
        .toList();
    if (classIds.isEmpty) return [];

    // WHERE class_id IN (...) AND status = ?
    final placeholders = List.filled(classIds.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT * FROM ${DatabaseService.learnerTable} '
      'WHERE class_id IN ($placeholders) AND status = ? '
      'ORDER BY class_id DESC, surname ASC, given_name ASC',
      [...classIds, status],
    );
    return rows;
  }

  Future<void> _setClassStatus(int classId, String status) async {
    await DatabaseService.instance.setClassStatus(classId, status);
    await DatabaseService.instance.setAllLearnersStatusForClass(
      classId,
      status,
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setLearnerStatus(int learnerId, String status) async {
    await DatabaseService.instance.setLearnerStatus(learnerId, status);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      appBar: AppBar(
        title: const Text("My Archive"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFE64843),
        bottom: TabBar(
          controller: _topTab,
          tabs: const [
            Tab(text: "Classes"),
            Tab(text: "Learners"),
          ],
        ),
      ),
      body: Row(
        children: [
          if (!isMobile)
            Navbar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            ),
          Expanded(
            child: TabBarView(
              controller: _topTab,
              children: [_classesPane(), _learnersPane()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _classesPane() {
    return Column(
      children: [
        TabBar(
          controller: _classTab,
          labelColor: Colors.black,
          indicatorColor: const Color(0xFFE64843),
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Deactivated"),
            Tab(text: "Archived"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _classTab,
            children: [
              _classList(DatabaseService.statusActive),
              _classList(DatabaseService.statusDeactivated),
              _classList(DatabaseService.statusArchived),
            ],
          ),
        ),
      ],
    );
  }

  Widget _classList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _classes(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) return Center(child: Text("No classes in $status."));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final c = list[i];
            final id = c['class_id'] as int;
            final level = (c['class_level'] ?? '').toString();
            final section = (c['class_section'] ?? '').toString();
            final year = "${c['start_school_year']}-${c['end_school_year']}";

            return ListTile(
              leading: const Icon(Icons.class_),
              title: Text("$level - $section"),
              subtitle: Text("SY: $year • Status: $status"),
              onTap: status == DatabaseService.statusActive
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassListPage(
                            role: widget.role,
                            userId: widget.userId,
                            classId: id,
                            gradeLevel: level,
                            section: section,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    }
                  : null,
              trailing: Wrap(
                spacing: 8,
                children: [
                  if (status == DatabaseService.statusActive) ...[
                    IconButton(
                      tooltip: "Deactivate",
                      icon: const Icon(Icons.pause_circle_outline),
                      onPressed: () => _setClassStatus(
                        id,
                        DatabaseService.statusDeactivated,
                      ),
                    ),
                    IconButton(
                      tooltip: "Archive",
                      icon: const Icon(Icons.archive_outlined),
                      onPressed: () =>
                          _setClassStatus(id, DatabaseService.statusArchived),
                    ),
                  ] else ...[
                    IconButton(
                      tooltip: status == DatabaseService.statusArchived
                          ? "Unarchive"
                          : "Reactivate",
                      icon: const Icon(Icons.play_circle_outline),
                      onPressed: () =>
                          _setClassStatus(id, DatabaseService.statusActive),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _learnersPane() {
    return Column(
      children: [
        TabBar(
          controller: _learnerTab,
          labelColor: Colors.black,
          indicatorColor: const Color(0xFFE64843),
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Deactivated"),
            Tab(text: "Archived"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _learnerTab,
            children: [
              _learnerList(DatabaseService.statusActive),
              _learnerList(DatabaseService.statusDeactivated),
              _learnerList(DatabaseService.statusArchived),
            ],
          ),
        ),
      ],
    );
  }

  Widget _learnerList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _learnersAllTeacher(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) return Center(child: Text("No learners in $status."));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final l = list[i];
            final id = l['learner_id'] as int;
            final classId = l['class_id'] as int?;
            final name = "${l['surname'] ?? ''}, ${l['given_name'] ?? ''}";

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(name),
              subtitle: Text("Class ID: ${classId ?? '-'} • Status: $status"),
              trailing: IconButton(
                tooltip: status == DatabaseService.statusArchived
                    ? "Unarchive"
                    : "Reactivate",
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () =>
                    _setLearnerStatus(id, DatabaseService.statusActive),
              ),
            );
          },
        );
      },
    );
  }
}

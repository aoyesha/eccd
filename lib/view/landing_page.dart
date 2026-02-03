import 'package:eccd/view/teacher_class_list.dart';
import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../util/data_source_tile.dart';
import '../util/right_panel.dart';
import '../services/database_service.dart';

class LandingPage extends StatelessWidget {
  final String role;
  final int teacherId;

  const LandingPage({
    Key? key,
    required this.role,
    required this.teacherId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchDataSources() async {
    final db = DatabaseService.instance;
    return await db.getAllClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
        selectedIndex: 0,
        onItemSelected: (_) {},
        teacherId: teacherId,
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
                  teacherId: teacherId,
                ),
              Expanded(
                child:
                isMobile ? _mobileLayout(context) : _desktopLayout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _centerContent(context),
          RightPanel(
            role: role,
            totalDataSource: 0,
            totalStudent: 0,
            overallProgress: 0,
            items: const [],
          ),
        ],
      ),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: _centerContent(context)),
        Expanded(
          flex: 2,
          child: RightPanel(
            role: role,
            totalDataSource: 0,
            totalStudent: 0,
            overallProgress: 0,
            items: const [],
          ),
        ),
      ],
    );
  }

  Widget _centerContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Early Childhood \nDevelopment Checklist",
            maxLines: 2,
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            "My Data Source",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("Manage your data source"),
          const SizedBox(height: 16),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchDataSources(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return const Text("No data sources found.");
              }

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: data.map((item) {
                  return DataSourceTile(
                    section: item["class_section"] ?? "",
                    schoolYear:
                    "${item["start_school_year"]}-${item["end_school_year"]}",
                    level: item["class_level"] ?? "",
                    color: Colors.white,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassListPage(
                            classId: item["class_id"] as int,
                            teacherId: teacherId,
                            gradeLevel: item["class_level"] ?? "",
                            section: item["class_section"] ?? "",
                          ),
                        ),
                      );
                    },

                    onActivate: () {}, onDeactivate: () {  },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

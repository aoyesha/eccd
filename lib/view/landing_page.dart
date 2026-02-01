import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../util/data_source_tile.dart';
import '../util/right_panel.dart';

class LandingPage extends StatelessWidget {
  final String role;

  const LandingPage({
    Key? key,
    required this.role,
  }) : super(key: key);

  static final List<Map<String, dynamic>> dataSources = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
        selectedIndex: 0,
        onItemSelected: (_) {},
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
          _centerContent(),
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

  Widget _desktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _centerContent(),
        ),
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

  Widget _centerContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Early Childhood \nDevelopment Checklist",
            maxLines: 2,
            style: TextStyle(fontSize: 38,
                fontWeight: FontWeight.bold,
            ),
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

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: dataSources.map((item) {
              return DataSourceTile(
                section: item['title'],
                schoolYear: item['schoolYear'],
                color: item['color'],
                onActivate: () {},
                onDeactivate: () {},
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

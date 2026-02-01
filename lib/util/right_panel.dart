import 'package:flutter/material.dart';

class RightPanel extends StatelessWidget {
  final String role;
  final int totalDataSource;
  final int totalStudent;
  final double overallProgress;
  final List<String> items;

  const RightPanel({
    Key? key,
    required this.role,
    required this.totalDataSource,
    required this.totalStudent,
    required this.overallProgress,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTeacher = role == "Teacher";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _panelTile("Data Source", totalDataSource.toString()),

          if (isTeacher)
            _panelTile("Total Students", totalStudent.toString()),

          _panelTile(
            "Overall Progress",
            "${overallProgress.toStringAsFixed(0)}%",
          ),

          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _panelTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

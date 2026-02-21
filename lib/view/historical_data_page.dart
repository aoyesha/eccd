import 'package:flutter/material.dart';

import '../util/navbar.dart';

class HistoricalDataPage extends StatelessWidget {
  final String role;
  final int userId;

  const HistoricalDataPage({Key? key, required this.role, required this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
              selectedIndex: 4,
              onItemSelected: (_) {},
              role: role,
              userId: userId,
            )
          : null,
      appBar: AppBar(
        title: const Text("Historical Data Analysis"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFE64843),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Row(
            children: [
              if (!isMobile)
                Navbar(
                  selectedIndex: 4,
                  onItemSelected: (_) {},
                  role: role,
                  userId: userId,
                ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Historical analysis wiring will be added after archive + summaries.",
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

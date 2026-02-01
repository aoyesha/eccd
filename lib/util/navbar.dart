import 'package:flutter/material.dart';

import '../view/landing_page.dart';
import '../view/login_page.dart';
import '../view/teacher_new_data_source.dart';

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({
    required this.icon,
    required this.label,
  });
}

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<NavItem> items = [
    NavItem(icon: Icons.home, label: 'Dashboard'),
    NavItem(icon: Icons.add, label: 'Add Data Source'),
    NavItem(icon: Icons.description, label: 'My Summary'),
    NavItem(icon: Icons.archive, label: 'My Archive'),
    NavItem(icon: Icons.analytics, label: 'Historical Data Analysis'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    if (isMobile) {
      return Drawer(
        backgroundColor: const Color(0xFF8B1C23),
        child: _content(context),
      );
    }

    return Container(
      width: 260,
      color: const Color(0xFF8B1C23),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 42, color: Colors.blue),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: ListView(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return ListTile(
                leading: Icon(item.icon, color: Colors.white),
                title: Text(item.label, style: const TextStyle(color: Colors.white)),
                selected: index == selectedIndex,
                selectedTileColor: const Color(0xFF6F151A),

                onTap: () {
                  onItemSelected(index);

                  if (MediaQuery.of(context).size.width < 700) {
                    Navigator.pop(context); // close drawer on mobile
                  }


                  switch (index) {
                    case 0:
                    Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LandingPage(role: "Teacher")));
                      break;
                    case 1:
                    Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CreateNewClassPage()));
                      break;
                    case 2:
                    // Navigator.push(context,
                    //   MaterialPageRoute(builder: (_) => MySummaryPage()));
                      break;
                    case 3:
                    // Navigator.push(context,
                    //   MaterialPageRoute(builder: (_) => MyArchivePage()));
                      break;
                    case 4:
                    // Navigator.push(context,
                    //   MaterialPageRoute(builder: (_) => HistoricalAnalysisPage()));
                      break;
                  }
                },
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            width: 160,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => LoginPage()));
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../view/landing_page.dart';
import '../view/settings_page.dart';
import '../view/teacher_new_data_source.dart';
import '../view/my_summary_page.dart';
import '../view/archive_page.dart';
import '../view/historical_data_page.dart';
import '../view/login_page.dart';

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
  final int teacherId;

  const Navbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.teacherId,
  }) : super(key: key);

  static const List<NavItem> items = [
    NavItem(icon: Icons.home, label: 'Dashboard'),
    NavItem(icon: Icons.add, label: 'Add Data Source'),
    NavItem(icon: Icons.description, label: 'My Summary'),
    NavItem(icon: Icons.archive, label: 'My Archive'),
    NavItem(icon: Icons.analytics, label: 'Historical Data Analysis'),
    NavItem(icon: Icons.settings, label: 'Account Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return isMobile
        ? Drawer(
      backgroundColor: const Color(0xFF8B1C23),
      child: _content(context, isMobile: true),
    )
        : Container(
      width: 260,
      color: const Color(0xFF8B1C23),
      child: _content(context, isMobile: false),
    );
  }

  Widget _content(BuildContext context, {required bool isMobile}) {
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
                title: Text(
                  item.label,
                  style: const TextStyle(color: Colors.white),
                ),
                selected: index == selectedIndex,
                selectedTileColor: const Color(0xFF6F151A),
                onTap: () {
                  onItemSelected(index);

                  if (isMobile) {
                    Navigator.pop(context);
                  }

                  switch (index) {
                    case 0:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LandingPage(
                            role: "Teacher",
                            teacherId: teacherId,
                          ),
                        ),
                      );
                      break;

                    case 1:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreateNewClassPage(teacherId: teacherId),
                        ),
                      );
                      break;

                    case 2:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SummaryPage(teacherId: teacherId),
                        ),
                      );
                      break;

                    case 3:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArchivePage(teacherId: teacherId),
                        ),
                      );
                      break;

                    case 4:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HistoricalDataPage(teacherId: teacherId),
                        ),
                      );
                      break;

                    case 5:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            userId: teacherId,
                            role: "Teacher",
                            email: "",
                          ),
                        ),
                      );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
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

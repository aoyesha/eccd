import 'package:flutter/material.dart';

import '../view/landing_page.dart';
import '../view/archive_page.dart';
import '../view/historical_data_page.dart';
import '../view/settings_page.dart';
import '../view/login_page.dart';

class AppColors {
  static const Color maroon = Color(0xFF7A1E22);
  static const Color maroonDark = Color(0xFF61171A);
  static const Color maroonLight = Color(0xFF8E2A2F);
  static const Color bg = Color(0xFFF7F4F6);
  static const Color white = Colors.white;
}

class NavItem {
  final IconData icon;
  final String label;
  final Widget Function() builder;

  const NavItem({
    required this.icon,
    required this.label,
    required this.builder,
  });
}

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  /// unified identifier (teacher_id or admin_id)
  final int userId;

  /// "Teacher" | "Admin"
  final String role;

  /// Back-compat flag for older call-sites.
  /// The navbar currently always navigates via pushReplacement.
  final bool useNavigator;

  const Navbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userId,
    required this.role,
    this.useNavigator = false,
  }) : super(key: key);

  double get _width => 280;

  @override
  Widget build(BuildContext context) {
    final items = <NavItem>[
      NavItem(
        icon: Icons.home,
        label: 'Dashboard',
        builder: () => LandingPage(userId: userId, role: role),
      ),
      NavItem(
        icon: Icons.archive,
        label: 'My Archive',
        builder: () => ArchivePage(userId: userId, role: role),
      ),
      NavItem(
        icon: Icons.analytics,
        label: 'Historical Data Analysis',
        builder: () => HistoricalDataPage(userId: userId, role: role),
      ),
      NavItem(
        icon: Icons.settings,
        label: 'Account Settings',
        builder: () => SettingsPage(userId: userId, role: role),
      ),
    ];

    return Container(
      width: _width,
      color: AppColors.maroon,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 44, color: Colors.blue),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final isSelected = i == selectedIndex;
                  return _NavTile(
                    icon: items[i].icon,
                    label: items[i].label,
                    selected: isSelected,
                    onTap: () {
                      onItemSelected(i);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => items[i].builder()),
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.maroonDark : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

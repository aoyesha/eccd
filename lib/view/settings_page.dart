import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../util/navbar.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  final int userId;
  final String role;

  const SettingsPage({Key? key, required this.userId, required this.role})
    : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    Map<String, dynamic>? row;
    if (widget.role == 'Teacher') {
      row = await DatabaseService.instance.getTeacherById(widget.userId);
    } else {
      row = await DatabaseService.instance.getAdminById(widget.userId);
    }

    if (!mounted) return;
    setState(() {
      _user = row;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          Navbar(
            selectedIndex: 3,
            onItemSelected: (_) {},
            userId: widget.userId,
            role: widget.role,
          ),
          Expanded(
            child: Column(
              children: [
                _appBar(context),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _content(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Container(
      height: 72,
      color: AppColors.maroon,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    final u = _user ?? {};
    final name = (widget.role == 'Teacher')
        ? (u['teacher_name'] ?? '—')
        : (u['admin_name'] ?? '—');

    return Padding(
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _kv('Role', widget.role),
                  _kv('Name', '$name'),
                  _kv('Email', '${u['email'] ?? '—'}'),
                  _kv('School', '${u['school'] ?? '—'}'),
                  _kv('District', '${u['district'] ?? '—'}'),
                  _kv('Division', '${u['division'] ?? '—'}'),
                  _kv('Region', '${u['region'] ?? '—'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _tile(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordPage(
                          userId: widget.userId,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                ),
                _divider(),
                _tile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () => _showDialog(
                    'Privacy Policy',
                    'Add your privacy policy text here.',
                  ),
                ),
                _divider(),
                _tile(
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  onTap: () => _showDialog(
                    'Terms & Conditions',
                    'Add your terms text here.',
                  ),
                ),
                _divider(),
                _tile(
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  onTap: () => _showDialog('FAQ', 'Add your FAQ here.'),
                ),
                _divider(),
                _tile(
                  icon: Icons.contact_mail,
                  title: 'Contact Us',
                  onTap: () => _showDialog(
                    'Contact Us',
                    'Email: example@deped.gov.ph\nPhone: (000) 000-0000',
                  ),
                ),
                _divider(),
                _tile(
                  icon: Icons.groups,
                  title: 'Developers',
                  onTap: () => _showDialog(
                    'Developers',
                    '• Vincent Yuri Jose\n• (Add other devs)\n\n(Replace this list with your team.)',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

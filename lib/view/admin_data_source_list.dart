import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../services/database_service.dart';

class InstitutionPage extends StatefulWidget {
  final int institutionId;
  final String institutionName;
  final int adminId;

  const InstitutionPage({
    Key? key,
    required this.institutionId,
    required this.institutionName,
    required this.adminId,
  }) : super(key: key);

  @override
  State<InstitutionPage> createState() => _InstitutionPageState();
}

class _InstitutionPageState extends State<InstitutionPage> {
  String? institution;
  bool _isActive = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstitution();
  }

  Future<void> _loadInstitution() async {
    final db = await DatabaseService.instance.getDatabase();

    final result = await db.query(
      'institution_table',
      where: 'institution_id = ?',
      whereArgs: [widget.institutionId],
    );

    if (result.isNotEmpty) {
      institution = result.first['institution_name']?.toString();
      _isActive = (result.first['status'] ?? 'active') == 'active';
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateInstitutionStatus(String newStatus) async {
    final db = await DatabaseService.instance.getDatabase();

    await db.update(
      'institution_table',
      {'status': newStatus},
      where: 'institution_id = ?',
      whereArgs: [widget.institutionId],
    );

    await _loadInstitution();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(
        selectedIndex: 0,
        onItemSelected: (_) {},
        teacherId: widget.adminId,
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
                  teacherId: widget.adminId,
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
          _content(),
          _rightPanel(),
        ],
      ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Expanded(flex: 5, child: _content()),
        Expanded(flex: 3, child: _rightPanel()),
      ],
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.institutionName,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (institution == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("No institution found."),
            )
          else
            Card(
              elevation: 1,
              child: ListTile(
                tileColor: Colors.white,
                title: Text(
                  institution!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                leading: CircleAvatar(
                  radius: 6,
                  backgroundColor: _isActive ? Colors.green : Colors.red,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    final newStatus = value == 'activate' ? 'active' : 'inactive';
                    await _updateInstitutionStatus(newStatus);
                  },
                  itemBuilder: (_) => [
                    if (!_isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text('Activate'),
                      ),
                    if (_isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Deactivate'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rightPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _statusCard(),
          const SizedBox(height: 16),
          _chartCard(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1C23),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Import action
              },
              child: const Text(
                "Import",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: 0,
              strokeWidth: 14,
              color: const Color(0xFF4A1511),
              backgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Institution Chart", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_bar(10)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

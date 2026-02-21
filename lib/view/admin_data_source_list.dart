import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../util/navbar.dart';

/// Admin list of uploaded/ingested data sources.
/// NOTE: Current DB schema you uploaded does NOT include institution_table.
/// This page will gracefully fallback if the table is missing.
class AdminDataSourceListPage extends StatefulWidget {
  final String role; // should be "Admin"
  final int userId; // admin_id

  const AdminDataSourceListPage({
    Key? key,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdminDataSourceListPage> createState() =>
      _AdminDataSourceListPageState();
}

class _AdminDataSourceListPageState extends State<AdminDataSourceListPage> {
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> institutions = [];

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  Future<void> _loadInstitutions() async {
    setState(() {
      isLoading = true;
      error = null;
      institutions = [];
    });

    try {
      final db = await DatabaseService.instance.getDatabase();

      // This table may not exist yet in your schema.
      final rows = await db.query(
        'institution_table',
        orderBy: 'institution_id DESC',
      );

      setState(() {
        institutions = rows;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Graceful fallback if schema not ready yet.
        error =
            "Admin data sources are not available yet.\n\nReason: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      appBar: AppBar(
        title: const Text("Admin Data Sources"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFE64843),
        actions: [
          IconButton(
            onPressed: _loadInstitutions,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (!isMobile)
                Navbar(
                  selectedIndex: 0,
                  onItemSelected: (_) {},
                  role: widget.role,
                  userId: widget.userId,
                ),
              Expanded(child: _body()),
            ],
          );
        },
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 36),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (institutions.isEmpty) {
      return const Center(child: Text("No data sources found."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: institutions.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final inst = institutions[index];
        final id = inst['institution_id'] as int?;
        final name = (inst['institution_name'] ?? "Unnamed").toString();
        final status = (inst['status'] ?? 'active').toString();

        return ListTile(
          leading: const Icon(Icons.apartment),
          title: Text(name),
          subtitle: Text("Status: $status"),
          trailing: const Icon(Icons.chevron_right),
          onTap: id == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstitutionPage(
                        role: widget.role,
                        userId: widget.userId,
                        institutionId: id,
                        institutionName: name,
                      ),
                    ),
                  ).then((_) => _loadInstitutions());
                },
        );
      },
    );
  }
}

/// Kept for compatibility: older code may navigate to InstitutionPage.
/// This also handles missing institution_table safely.
class InstitutionPage extends StatefulWidget {
  final String role;
  final int userId;

  final int institutionId;
  final String institutionName;

  const InstitutionPage({
    Key? key,
    required this.role,
    required this.userId,
    required this.institutionId,
    required this.institutionName,
  }) : super(key: key);

  @override
  State<InstitutionPage> createState() => _InstitutionPageState();
}

class _InstitutionPageState extends State<InstitutionPage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? record;

  @override
  void initState() {
    super.initState();
    _loadInstitution();
  }

  Future<void> _loadInstitution() async {
    setState(() {
      isLoading = true;
      error = null;
      record = null;
    });

    try {
      final db = await DatabaseService.instance.getDatabase();
      final rows = await db.query(
        'institution_table',
        where: 'institution_id = ?',
        whereArgs: [widget.institutionId],
        limit: 1,
      );

      setState(() {
        record = rows.isEmpty ? null : rows.first;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Unable to load institution.\n\nReason: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      appBar: AppBar(
        title: Text(widget.institutionName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFFE64843),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (!isMobile)
                Navbar(
                  selectedIndex: 0,
                  onItemSelected: (_) {},
                  role: widget.role,
                  userId: widget.userId,
                ),
              Expanded(child: _content()),
            ],
          );
        },
      ),
    );
  }

  Widget _content() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (record == null) {
      return const Center(child: Text("Institution not found."));
    }

    final status = (record!['status'] ?? 'active').toString();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.institutionName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Status: $status"),
          const SizedBox(height: 16),
          const Text(
            "Details view placeholder.\nNext step: show summary imported from lower office CSV.",
          ),
        ],
      ),
    );
  }
}

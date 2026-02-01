import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../util/data_source_tile.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  Future<List<Map<String, String>>> _fetchArchiveFromDb() async {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 0, onItemSelected: (_) {})
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > 700
                ? _desktopLayout()
                : _mobileLayout();
          },
        ),
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(child: _content(isMobile: true));
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Navbar(selectedIndex: 0, onItemSelected: (_) {}),
        Expanded(child: SingleChildScrollView(child: _content(isMobile: false))),
      ],
    );
  }

  Widget _content({required bool isMobile}) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _fetchArchiveFromDb(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            isMobile ? 16 : 16,
            isMobile ? 16 : 24,
            isMobile ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                "Early Childhood\nDevelopment Checklist",
                style: TextStyle(
                  fontSize: isMobile ? 22 : 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              /// HEADER
              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _archiveTitle(isMobile),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _yearControls(isMobile),
                  ),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _archiveTitle(isMobile),
                  const Spacer(),
                  _yearControls(isMobile),
                ],
              ),

              const SizedBox(height: 20),

              /// GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 5,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 140 / 210 : 140 / 180,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return DataSourceTile(
                    section: item["section"] ?? "",
                    schoolYear: item["year"] ?? "",
                    color: const Color(0xFFF2F2F2),
                    onActivate: () {},
                    onDeactivate: () {},
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _archiveTitle(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Archive",
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Archived Data Sources",
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _yearControls(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Select School Year",
          style: TextStyle(fontSize: isMobile ? 11 : 12),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _yearField("Start Year", isMobile),
            const SizedBox(width: 8),
            _yearField("End Year", isMobile),
          ],
        ),
      ],
    );
  }

  Widget _yearField(String hint, bool isMobile) {
    return SizedBox(
      width: isMobile ? 100 : 120,
      height: isMobile ? 34 : 36,
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: isMobile ? 11 : 12),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import '../util/data_source_tile.dart';

class ArchivePage extends StatefulWidget {
  final int teacherId;

  const ArchivePage({Key? key, required this.teacherId}) : super(key: key);

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
          ? Navbar(selectedIndex: 0, onItemSelected: (_) {}, teacherId: widget.teacherId)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > 700 ? _desktopLayout() : _mobileLayout();
        },
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(child: _content(isMobile: true));
  }

  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Navbar(selectedIndex: 0, onItemSelected: (_) {}, teacherId: widget.teacherId),
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
            isMobile ? 12 : 12,
            isMobile ? 16 : 24,
            isMobile ? 24 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Early Childhood \nDevelopment Checklist",
                maxLines: 2,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 12),

              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _archiveTitle(isMobile),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _yearControls(isMobile),
                  ),
                ],
              )
                  : Row(
                children: [
                  _archiveTitle(isMobile),
                  const Spacer(),
                  _yearControls(isMobile),
                ],
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 5,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 140 / 200 : 140 / 175,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return DataSourceTile(
                    section: item["section"] ?? "",
                    schoolYear: item["year"] ?? "",
                    level: "",
                    color: const Color(0xFFF2F2F2),
                    onTap: () {},
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
        Text("Select School Year", style: TextStyle(fontSize: isMobile ? 11 : 12)),
        const SizedBox(height: 6),
        Row(
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

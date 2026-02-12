import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';

class HistoricalDataPage extends StatelessWidget {
  final int teacherId;

  const HistoricalDataPage({Key? key, required this.teacherId}) : super(key: key);

  final List<String> mostLearnedHeaders = const [
    "THE THREE MOST LEARNED\nGROSS MOTOR",
    "THE THREE MOST LEARNED\nFINE MOTOR",
    "THE THREE MOST LEARNED\nSELF HELP",
    "THE THREE MOST LEARNED\nRECEPTIVE LANGUAGE",
    "THE THREE MOST LEARNED\nEXPRESSIVE LANGUAGE",
    "THE THREE MOST LEARNED\nCOGNITIVE DOMAIN",
    "THE THREE MOST LEARNED\nSOCIAL EMOTIONAL",
  ];

  final List<String> leastMasteredHeaders = const [
    "THE THREE LEAST MASTERED\nGROSS MOTOR",
    "THE THREE LEAST MASTERED\nFINE MOTOR",
    "THE THREE LEAST MASTERED\nSELF HELP",
    "THE THREE LEAST MASTERED\nRECEPTIVE LANGUAGE",
    "THE THREE LEAST MASTERED\nEXPRESSIVE LANGUAGE",
    "THE THREE LEAST MASTERED\nCOGNITIVE DOMAIN",
    "THE THREE LEAST MASTERED\nSOCIAL EMOTIONAL",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 4, onItemSelected: (_) {}, teacherId: teacherId)
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
        Navbar(selectedIndex: 4, onItemSelected: (_) {}, teacherId: teacherId),
        Expanded(child: SingleChildScrollView(child: _content(isMobile: false))),
      ],
    );
  }

  Widget _content({required bool isMobile}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? 1000 : 1400),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Early Childhood Development Checklist",
                maxLines: 2,
                style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 16),

              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _topButton("Import", true),
                      const SizedBox(width: 6),
                      _topButton("Export", true),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _yearField("Start Year", true),
                      const SizedBox(width: 6),
                      _yearField("End Year", true),
                    ],
                  ),
                ],
              )
                  : Row(
                children: [
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _topButton("Import", false),
                          const SizedBox(width: 12),
                          _topButton("Export", false),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _yearField("Start Year", false),
                          const SizedBox(width: 12),
                          _yearField("End Year", false),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Most Learned Skills",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    _tableHeader(mostLearnedHeaders),
                    _tableRow(),
                    _tableRow(),
                    _tableRow(),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Least Mastered Skills",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    _tableHeader(leastMasteredHeaders),
                    _tableRow(),
                    _tableRow(),
                    _tableRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topButton(String text, bool isMobile) {
    return SizedBox(
      height: isMobile ? 32 : 40,
      width: isMobile ? 95 : 110,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE64843),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _yearField(String hint, bool isMobile) {
    return SizedBox(
      width: isMobile ? 100 : 140,
      height: isMobile ? 32 : 40,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: isMobile ? 11 : 12),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(List<String> headers) {
    return Row(
      children: headers
          .map((h) => _cell(
        h,
        width: 180,
        isHeader: true,
      ))
          .toList(),
    );
  }

  Widget _tableRow() {
    return Row(
      children: List.generate(7, (_) => _cell("")),
    );
  }

  Widget _cell(String text, {double width = 180, bool isHeader = false}) {
    return Container(
      width: width,
      height: isHeader ? 72 : 48,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

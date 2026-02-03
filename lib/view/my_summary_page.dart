import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';

class SummaryPage extends StatelessWidget {
  final int teacherId;

  const SummaryPage({Key? key, required this.teacherId}) : super(key: key);

  final List<String> domains = const [
    "GROSS MOTOR",
    "FINE MOTOR",
    "SELF HELP",
    "RECEPTIVE\nLANGUAGE",
    "EXPRESSIVE\nLANGUAGE",
    "COGNITIVE",
    "SOCIO-EMOTIONAL",
    "GRAND TOTAL",
  ];

  final List<String> levels = const [
    "Suggested Significantly Delay in Overall Development (SSDD)",
    "Suggested Slight Delay in Overall Development (SSLD)",
    "Average Development (AD)",
    "Suggest Slightly Advance Development (SSAD)",
    "Suggest Highly Advanced Development (SHAD)",
    "TOTAL",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 700
          ? Navbar(selectedIndex: 0, onItemSelected: (_) {}, teacherId: teacherId)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > 700
              ? _desktopLayout()
              : _mobileLayout();
        },
      ),
    );
  }

  Widget _mobileLayout() {
    return SingleChildScrollView(child: _content());
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Navbar(selectedIndex: 0, onItemSelected: (_) {}, teacherId: teacherId),
        Expanded(child: SingleChildScrollView(child: _content())),
      ],
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
          const SizedBox(height: 8),

          Row(
            children: [
              const Text(
                "Teacher’s Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE64843),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Export",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                _tableHeader(),
                ...levels.map((e) => _dataRow(e)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Column(
      children: [
        Row(
          children: [
            _cell("LEVEL OF DEVELOPMENT", width: 220, isHeader: true),
            ...domains.map((d) => _groupHeader(d)).toList(),
          ],
        ),
        Row(
          children: [
            _cell("", width: 220, isHeader: true),
            ...domains.expand((_) => [
              _cell("F", isHeader: true),
              _cell("M", isHeader: true),
              _cell("TOTAL", isHeader: true),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _dataRow(String level) {
    return Row(
      children: [
        _cell(level, width: 220),
        ...domains.expand((_) => [
          _cell(""),
          _cell(""),
          _cell(""),
        ]),
      ],
    );
  }

  Widget _groupHeader(String text) {
    return Container(
      width: 180,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        color: Colors.grey.shade100,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cell(String text, {double width = 60, bool isHeader = false}) {
    return Container(
      width: width,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 13 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

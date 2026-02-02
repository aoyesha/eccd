import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import 'package:eccd/util/domain.dart';
import 'package:eccd/data/eccd_questions.dart';

class TeacherChecklistPage extends StatefulWidget {
  const TeacherChecklistPage({Key? key}) : super(key: key);

  @override
  State<TeacherChecklistPage> createState() => _TeacherChecklistPageState();
}

class _TeacherChecklistPageState extends State<TeacherChecklistPage> {
  String selectedLanguage = "English";
  String selectedAssessment = "Pre-Test";
  String? selectedDomain;
  DateTime? selectedDate;

  final TextEditingController _dateController = TextEditingController();
  final List<String> domains = EccdQuestions.domains;
  final Map<String, bool> yesValues = {};
  final Map<String, bool> noValues = {};

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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
    final lang = EccdQuestions.fromLabel(selectedLanguage);
    final visibleDomains =
    selectedDomain == null ? domains : [selectedDomain!];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _assessmentRow(isMobile),
          const SizedBox(height: 10),
          _headerRow(isMobile),
          const SizedBox(height: 14),

          DomainDropdown(
            domains: ["All Domains", ...domains],
            onChanged: (value) {
              setState(() {
                if (value == "All Domains") {
                  selectedDomain = null;
                } else {
                  selectedDomain = value;
                }
              });
            },
          ),

          const SizedBox(height: 20),

          ...visibleDomains.map((domain) {
            final questions = EccdQuestions.get(domain, lang);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _domainTitleAndProgress(domain, isMobile),
                const SizedBox(height: 10),

                ...List.generate(questions.length, (i) {
                  final key = "$domain-$i";
                  yesValues.putIfAbsent(key, () => false);
                  noValues.putIfAbsent(key, () => false);

                  return _questionRow(
                    number: i + 1,
                    question: questions[i],
                    keyId: key,
                    isMobile: isMobile,
                  );
                }),

                const SizedBox(height: 20),
              ],
            );
          }),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 130,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE64843),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Save",
                  style:
                  TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assessmentRow(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 320,
      child: DropdownButtonFormField<String>(
        value: selectedAssessment,
        items: ["Pre-Test", "Post-Test"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedAssessment = v!),
        decoration: _decoration("Assessment"),
      ),
    );
  }

  Widget _headerRow(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _studentInfo(isMobile)),
        const SizedBox(width: 16),
        _headerControls(isMobile),
      ],
    );
  }

  Widget _headerControls(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: isMobile ? 32 : 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE64843),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            onPressed: () {},
            child: Text(
              "Export Summary",
              style:
              TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: isMobile ? 130 : 170,
              child: DropdownButtonFormField<String>(
                value: selectedLanguage,
                items: ["English", "Tagalog"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedLanguage = v!),
                decoration: _decoration("Language"),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: isMobile ? 150 : 200,
              child: TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: _decoration("Date"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _studentInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cruz, Adrian M",
          style: TextStyle(
              fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          "Date of Birth: June 29, 2020, Age: 5",
          style: TextStyle(
              fontSize: isMobile ? 11 : 13, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: 0.8, minHeight: isMobile ? 6 : 8),
      ],
    );
  }

  Widget _domainTitleAndProgress(String domain, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Text(
            domain,
            style: TextStyle(
                fontSize: isMobile ? 14 : 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(value: 0, minHeight: isMobile ? 6 : 8),
        ),
      ],
    );
  }

  Widget _questionRow({
    required int number,
    required String question,
    required String keyId,
    required bool isMobile,
  }) {
    final yes = yesValues[keyId] ?? false;
    final no = noValues[keyId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              visualDensity: VisualDensity.compact,
              value: yes,
              onChanged: (v) {
                setState(() {
                  yesValues[keyId] = v ?? false;
                  if (v == true) noValues[keyId] = false;
                });
              },
            ),
            Text("YES", style: TextStyle(fontSize: isMobile ? 11 : 13)),
            const SizedBox(width: 6),
            Checkbox(
              visualDensity: VisualDensity.compact,
              value: no,
              onChanged: (v) {
                setState(() {
                  noValues[keyId] = v ?? false;
                  if (v == true) yesValues[keyId] = false;
                });
              },
            ),
            Text("NO", style: TextStyle(fontSize: isMobile ? 11 : 13)),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$number. $question",
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text =
        "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }
}

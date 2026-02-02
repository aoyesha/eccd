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
  String selectedDomain = "Gross Motor";
  DateTime? selectedDate;

  final TextEditingController _dateController = TextEditingController();

  final List<String> domains = EccdQuestions.domains;
  final Map<String, bool> yesValues = {};
  final Map<String, bool> noValues = {};
  final Map<String, TextEditingController> commentControllers = {};

  @override
  void dispose() {
    _dateController.dispose();
    for (final c in commentControllers.values) {
      c.dispose();
    }
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
        Expanded(
          child: SingleChildScrollView(child: _content(isMobile: false)),
        ),
      ],
    );
  }

  Widget _content({required bool isMobile}) {
    final lang = EccdQuestions.fromLabel(selectedLanguage);
    final questions = EccdQuestions.get(selectedDomain, lang);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _assessmentRow(isMobile),
          const SizedBox(height: 8),
          _headerRow(isMobile),
          const SizedBox(height: 12),

          DomainDropdown(
            domains: domains,
            onChanged: (value) {
              setState(() {
                selectedDomain = value ?? selectedDomain;
              });
            },
          ),

          const SizedBox(height: 14),
          _domainTitleAndProgress(selectedDomain),

          const SizedBox(height: 10),

          // questions
          ...List.generate(questions.length, (i) {
            final qText = questions[i];
            final qNumber = i + 1;
            final key = "$selectedDomain-$qNumber";

            yesValues.putIfAbsent(key, () => false);
            noValues.putIfAbsent(key, () => false);
            commentControllers.putIfAbsent(key, () => TextEditingController());

            return _questionRow(
              number: qNumber,
              text: qText,
              keyId: key,
              isMobile: isMobile,
            );
          }),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 110,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE64843),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
      width: isMobile ? double.infinity : 260,
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
    return isMobile
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _studentInfo(isMobile),
        const SizedBox(height: 8),
        _headerControls(isMobile),
      ],
    )
        : Row(
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
          height: 32,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE64843),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Export Summary",
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 130,
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
              width: 150,
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
        const Text(
          "Cruz, Adrian M",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          "Date of Birth: June 29, 2020, Age: 5",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: 0.8,
          minHeight: 6,
          color: Colors.green,
          backgroundColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _domainTitleAndProgress(String domain) {
    return Row(
      children: [
        Expanded(
          child: Text(
            domain,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: 0,
            minHeight: 6,
            color: Colors.green,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _questionRow({
    required int number,
    required String text,
    required String keyId,
    required bool isMobile,
  }) {
    final yes = yesValues[keyId] ?? false;
    final no = noValues[keyId] ?? false;
    final comment = commentControllers[keyId]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text(
                "$number.",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

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
            const Text("YES", style: TextStyle(fontSize: 11)),
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
            const Text("NO", style: TextStyle(fontSize: 11)),
            const SizedBox(width: 10),

            Expanded(
              child: SizedBox(
                height: 30,
                child: TextField(
                  controller: comment,
                  decoration: InputDecoration(
                    hintText: "Questions",
                    hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
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
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }
}

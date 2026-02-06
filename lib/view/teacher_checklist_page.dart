import 'package:flutter/material.dart';
import 'package:eccd/util/navbar.dart';
import 'package:eccd/util/domain.dart';
import 'package:eccd/data/eccd_questions.dart';
import '../services/assessment_service.dart';
import '../services/pdf_service.dart';

class TeacherChecklistPage extends StatefulWidget {
  final int teacherId;
  final int classId;
  final int learnerId;
  final String learnerName;

  const TeacherChecklistPage({
    Key? key,
    required this.teacherId,
    required this.classId,
    required this.learnerId,
    required this.learnerName,
  }) : super(key: key);

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
  void initState() {
    super.initState();
    _loadSavedAssessment();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // ================= LOAD SAVED DATA =================
  Future<void> _loadSavedAssessment() async {
    final results = await AssessmentService.getAssessment(
      learnerId: widget.learnerId,
      classId: widget.classId,
      assessmentType: selectedAssessment,
    );

    yesValues.clear();
    noValues.clear();

    for (final row in results) {
      final key = "${row['domain']}-${row['question_index']}";
      final isYes = row['answer'] == 1;

      yesValues[key] = isYes;
      noValues[key] = !isYes;
      selectedDate ??= DateTime.tryParse(row['date_taken']);
    }

    if (selectedDate != null) {
      _dateController.text =
          "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}";
    }

    setState(() {});
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      drawer: isMobile
          ? Navbar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              teacherId: widget.teacherId,
            )
          : null,
      body: SafeArea(child: isMobile ? _mobileLayout() : _desktopLayout()),
    );
  }

  Widget _mobileLayout() => SingleChildScrollView(child: _content(true));

  Widget _desktopLayout() {
    return Row(
      children: [
        Navbar(
          selectedIndex: 0,
          onItemSelected: (_) {},
          teacherId: widget.teacherId,
        ),
        Expanded(child: SingleChildScrollView(child: _content(false))),
      ],
    );
  }

  Widget _content(bool isMobile) {
    final lang = EccdQuestions.fromLabel(selectedLanguage);
    final visibleDomains = selectedDomain == null ? domains : [selectedDomain!];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _assessmentDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _datePicker()),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.learnerName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          LinearProgressIndicator(value: _overallProgress()),

          const SizedBox(height: 14),

          DomainDropdown(
            domains: ["All Domains", ...domains],
            onChanged: (v) =>
                setState(() => selectedDomain = v == "All Domains" ? null : v),
          ),

          const SizedBox(height: 20),

          ...visibleDomains.map((domain) {
            final questions = EccdQuestions.get(domain, lang);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domain,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LinearProgressIndicator(value: _domainProgress(domain)),
                const SizedBox(height: 8),

                ...List.generate(questions.length, (i) {
                  final key = "$domain-$i";
                  yesValues.putIfAbsent(key, () => false);
                  noValues.putIfAbsent(key, () => false);

                  return Row(
                    children: [
                      Checkbox(
                        value: yesValues[key],
                        onChanged: (v) {
                          setState(() {
                            yesValues[key] = v ?? false;
                            noValues[key] = false;
                          });
                        },
                      ),
                      const Text("YES"),
                      Checkbox(
                        value: noValues[key],
                        onChanged: (v) {
                          setState(() {
                            noValues[key] = v ?? false;
                            yesValues[key] = false;
                          });
                        },
                      ),
                      const Text("NO"),
                      Expanded(child: Text("${i + 1}. ${questions[i]}")),
                    ],
                  );
                }),

                const Divider(),
              ],
            );
          }),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: _saveAssessment,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _exportSummary,
                child: const Text(
                  "Export PDF",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  Widget _assessmentDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedAssessment,
      items: const [
        DropdownMenuItem(value: "Pre-Test", child: Text("Pre-Test")),
        DropdownMenuItem(value: "Post-Test", child: Text("Post-Test")),
      ],
      onChanged: (v) async {
        selectedAssessment = v!;
        await _loadSavedAssessment();
      },
      decoration: const InputDecoration(labelText: "Assessment"),
    );
  }

  Widget _datePicker() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: const InputDecoration(labelText: "Date"),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2015),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
            _dateController.text =
                "${picked.month}/${picked.day}/${picked.year}";
          });
        }
      },
    );
  }

  Future<void> _saveAssessment() async {
    if (selectedDate == null) return;

    await AssessmentService.saveAssessment(
      learnerId: widget.learnerId,
      classId: widget.classId,
      assessmentType: selectedAssessment,
      date: selectedDate!,
      yesValues: yesValues,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Assessment saved"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _exportSummary() async {
    final file = await PdfService.generateReport(
      widget.learnerName,
      _computeProgress(),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("PDF saved: ${file.path}")));
  }

  Map<String, double> _computeProgress() {
    final Map<String, List<bool>> map = {};
    yesValues.forEach((k, v) {
      final d = k.split('-').first;
      map.putIfAbsent(d, () => []);
      map[d]!.add(v);
    });

    return map.map(
      (k, v) => MapEntry(
        k,
        v.isEmpty ? 0 : (v.where((e) => e).length / v.length) * 100,
      ),
    );
  }

  double _domainProgress(String domain) {
    final entries = yesValues.entries.where((e) => e.key.startsWith(domain));
    if (entries.isEmpty) return 0;
    return entries.where((e) => e.value).length / entries.length;
  }

  double _overallProgress() {
    if (yesValues.isEmpty) return 0;
    return yesValues.values.where((v) => v).length / yesValues.length;
  }
}

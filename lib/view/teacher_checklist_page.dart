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
      body: SafeArea(
        child: Stack(
          children: [
            isMobile ? _mobileLayout() : _desktopLayout(),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _stickyBottomBar(isMobile),
            ),
          ],
        ),
      ),
    );

  }

  Widget _mobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _content(true),
          ),
        ),
      ],
    );
  }


  Widget _desktopLayout() {
    return Row(
      children: [
        Navbar(
          selectedIndex: 0,
          onItemSelected: (_) {},
          teacherId: widget.teacherId,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _content(false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _content(bool isMobile) {
    final lang = EccdQuestions.fromLabel(selectedLanguage);
    final visibleDomains = selectedDomain == null ? domains : [selectedDomain!];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 34,
        isMobile ? 12 : 34,
        isMobile ? 12 : 34,
        140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _assessmentRow(isMobile),
          const SizedBox(height: 6),

          _headerRow(isMobile),
          const SizedBox(height: 8),

          LinearProgressIndicator(value: _overallProgress()),
          const SizedBox(height: 10),

          DomainDropdown(
            domains: ["All Domains", ...domains],
            onChanged: (v) =>
                setState(() => selectedDomain = v == "All Domains" ? null : v),
          ),

          const SizedBox(height: 14),

          ...visibleDomains.map((domain) {
            final questions = EccdQuestions.get(domain, lang);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domain,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LinearProgressIndicator(value: _domainProgress(domain)),
                const SizedBox(height: 6),

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
                      const Text("YES",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),

                      Checkbox(
                        value: noValues[key],
                        onChanged: (v) {
                          setState(() {
                            noValues[key] = v ?? false;
                            yesValues[key] = false;
                          });
                        },
                      ),
                      const Text("NO ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                      Expanded(
                        child: Text(
                          "${i + 1}. ${questions[i]}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _assessmentRow(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 320,
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }

  Widget _headerRow(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _studentInfo(isMobile)),
        const SizedBox(width: 8),
        _headerControls(isMobile),
      ],
    );
  }

  Widget _studentInfo(bool isMobile) {
    return Text(
      widget.learnerName,
      style: TextStyle(
        fontSize: isMobile ? 14 : 36,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _headerControls(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: isMobile ? 28 : 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            onPressed: _exportSummary,
            child: Text(
              "Export Summary",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 10 : 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: isMobile ? 110 : 170,
              child: DropdownButtonFormField<String>(
                value: selectedLanguage,
                items: const [
                  DropdownMenuItem(value: "English", child: Text("English")),
                  DropdownMenuItem(value: "Tagalog", child: Text("Tagalog")),
                ],
                onChanged: (v) => setState(() => selectedLanguage = v!),
                decoration: const InputDecoration(labelText: "Language"),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: isMobile ? 120 : 200,
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date"),
                onTap: _pickDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stickyBottomBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: isMobile ? 36 : 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: _saveAssessment,
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: isMobile ? 36 : 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _exportSummary,
              child: const Text(
                "Export Summary",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _pickDate() async {
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
      const SnackBar(content: Text("Assessment saved")),
    );
  }

  Future<void> _exportSummary() async {
    final file = await PdfService.generateReport(
      widget.learnerName,
      _computeProgress(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF saved: ${file.path}")),
    );
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
        v.isEmpty ? 0 : v.where((e) => e).length / v.length,
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

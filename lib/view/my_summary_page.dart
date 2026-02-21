import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/eccd_questions.dart';
import '../services/assessment_service.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../util/navbar.dart';

class MySummaryPage extends StatefulWidget {
  final String role;
  final int userId;

  /// When true: renders as a "section" inside another page (e.g., Dashboard tab)
  /// - no Scaffold
  /// - no Navbar
  /// - no back button / headline bar
  final bool embedded;

  const MySummaryPage({
    Key? key,
    required this.role,
    required this.userId,
    this.embedded = false,
  }) : super(key: key);

  @override
  State<MySummaryPage> createState() => _MySummaryPageState();
}

class _MySummaryPageState extends State<MySummaryPage> {
  String _assessmentType = 'Pre-Test';
  bool _loading = true;

  List<Map<String, dynamic>> _classes = [];
  int? _selectedClassId; // null = ALL active classes

  final Map<String, Map<String, int>> _counts = {};
  List<_SkillRate> _topMost = [];
  List<_SkillRate> _topLeast = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadClasses();
    await _loadSummary();
  }

  Future<void> _loadClasses() async {
    if (widget.role != 'Teacher') {
      // Admin summary must use admin datasource tables, not teacher classes.
      setState(() => _classes = []);
      return;
    }

    final cls = await DatabaseService.instance.getActiveClassesByTeacher(
      widget.userId,
    );
    if (!mounted) return;
    setState(() => _classes = cls);
  }

  String _classTitleById(int classId) {
    final c = _classes.firstWhere(
      (e) => (e['class_id'] as int) == classId,
      orElse: () => {'grade_level': '', 'section': ''},
    );

    // Support both naming styles (your DB rows vary across files)
    final grade = (c['grade_level'] ?? c['class_level'] ?? '').toString();
    final section = (c['section'] ?? c['class_section'] ?? '').toString();
    return 'Grade $grade - $section';
  }

  String? _questionText(String domain, int qIndex1Based) {
    final list = EccdQuestions.get(domain, EccdLanguage.english);
    final idx = qIndex1Based - 1;
    if (idx < 0 || idx >= list.length) return null;
    return list[idx];
  }

  List<_SkillRate> _allPossibleSkills() {
    final all = <_SkillRate>[];
    for (final d in EccdQuestions.domains) {
      final list = EccdQuestions.get(d, EccdLanguage.english);
      for (int i = 0; i < list.length; i++) {
        all.add(
          _SkillRate(domain: d, questionIndex: i + 1, text: list[i], rate: 0),
        );
      }
    }
    return all;
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);

    final classIds = _selectedClassId == null
        ? _classes.map((c) => c['class_id'] as int).toList()
        : [_selectedClassId!];

    final domainBuckets = <String, Map<String, int>>{
      'Gross Motor': {},
      'Fine Motor': {},
      'Self-Help': {},
      'Receptive Language': {},
      'Expressive Language': {},
      'Cognitive': {},
      'Socio-Emotional': {},
      'Overall': {},
    };

    final Map<String, int> yesCounts = {};
    int learnersWithAssessment = 0;

    for (final classId in classIds) {
      final learners = await DatabaseService.instance.getLearnersByClass(
        classId,
      );

      for (final l in learners) {
        final status = (l['status'] ?? DatabaseService.statusActive).toString();
        if (status != DatabaseService.statusActive) continue;

        final learnerId = l['learner_id'] as int;

        final assessmentId = await AssessmentService.getLatestAssessmentId(
          learnerId: learnerId,
          classId: classId,
          assessmentType: _assessmentType,
        );
        if (assessmentId == null) continue;

        final ecd = await AssessmentService.getEcdSummary(
          assessmentId: assessmentId,
        );
        if (ecd == null) continue;

        learnersWithAssessment++;

        void add(String domainKey, String? interp) {
          final key = (interp ?? 'No Data').trim();
          domainBuckets[domainKey]![key] =
              (domainBuckets[domainKey]![key] ?? 0) + 1;
        }

        add('Gross Motor', ecd['gmd_interpretation'] as String?);
        add('Fine Motor', ecd['fms_interpretation'] as String?);
        add('Self-Help', ecd['shd_interpretation'] as String?);
        add('Receptive Language', ecd['rl_interpretation'] as String?);
        add('Expressive Language', ecd['el_interpretation'] as String?);
        add('Cognitive', ecd['cd_interpretation'] as String?);
        add('Socio-Emotional', ecd['sed_interpretation'] as String?);
        add('Overall', ecd['interpretation'] as String?);

        final results =
            await AssessmentService.getAssessmentResultsByAssessmentId(
              assessmentId,
            );
        for (final r in results) {
          final ans = int.tryParse(r['answer'].toString()) ?? 0;
          if (ans != 1) continue;

          final domain = (r['domain']?.toString() ?? '').trim();
          final qIndex = int.tryParse(r['question_index'].toString()) ?? 0;
          if (domain.isEmpty || qIndex <= 0) continue;

          final key = '$domain|$qIndex';
          yesCounts[key] = (yesCounts[key] ?? 0) + 1;
        }
      }
    }

    // most/least mastered
    final allSkillRates = <_SkillRate>[];
    if (learnersWithAssessment > 0) {
      for (final entry in yesCounts.entries) {
        final parts = entry.key.split('|');
        if (parts.length != 2) continue;
        final domain = parts[0];
        final qIndex = int.tryParse(parts[1]) ?? 0;

        final text = _questionText(domain, qIndex);
        if (text == null) continue;

        allSkillRates.add(
          _SkillRate(
            domain: domain,
            questionIndex: qIndex,
            text: text,
            rate: entry.value / learnersWithAssessment,
          ),
        );
      }
    }

    allSkillRates.sort((a, b) => b.rate.compareTo(a.rate));
    final topMost = allSkillRates.take(3).toList();

    final leastList = <_SkillRate>[];
    if (learnersWithAssessment > 0) {
      final possible = _allPossibleSkills();
      final Map<String, double> rateMap = {
        for (final s in allSkillRates) '${s.domain}|${s.questionIndex}': s.rate,
      };
      for (final s in possible) {
        final k = '${s.domain}|${s.questionIndex}';
        leastList.add(
          _SkillRate(
            domain: s.domain,
            questionIndex: s.questionIndex,
            text: s.text,
            rate: rateMap[k] ?? 0.0,
          ),
        );
      }
      leastList.sort((a, b) => a.rate.compareTo(b.rate));
    }

    if (!mounted) return;
    setState(() {
      _counts
        ..clear()
        ..addAll(domainBuckets);
      _topMost = topMost;
      _topLeast = leastList.take(3).toList();
      _loading = false;
    });
  }

  // ---------- EXPORTS ----------
  // Keep exports available in standalone mode. In embedded mode, you can keep them too,
  // but they should not render a second navbar/appbar.

  Future<void> _exportCsv() async {
    try {
      if (_loading) return;

      final selectedLabel = _selectedClassId == null
          ? 'ALL_ACTIVE_CLASSES'
          : 'CLASS_${_selectedClassId!}';

      final suggestedName =
          'my_summary_${selectedLabel}_${_assessmentType.replaceAll(' ', '_')}.csv';

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save My Summary (CSV)',
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      if (path == null) return;

      final rows = <List<dynamic>>[];
      rows.add(['ECCD Checklist - My Summary']);
      rows.add(['TeacherId', widget.userId]);
      rows.add(['Assessment', _assessmentType]);
      rows.add([
        'Selection',
        _selectedClassId == null
            ? 'All Active Classes'
            : _classTitleById(_selectedClassId!),
      ]);
      rows.add(['Generated', DateTime.now().toIso8601String()]);
      rows.add([]);

      rows.add(['Domain', 'Level', 'Count', 'Percent']);
      for (final domain in _counts.keys) {
        final c = _counts[domain] ?? {};
        final total = c.values.fold<int>(0, (a, b) => a + b);
        final entries = c.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (entries.isEmpty) {
          rows.add([domain, 'No Data', 0, 0]);
          continue;
        }

        for (final e in entries) {
          final pct = total == 0 ? 0 : (e.value / total) * 100;
          rows.add([domain, e.key, e.value, pct.toStringAsFixed(0)]);
        }
      }

      rows.add([]);
      rows.add(['Most Mastered Skills (Top 3)']);
      rows.add(['Domain', 'Question #', 'Percent', 'Skill']);
      for (final s in _topMost) {
        rows.add([
          s.domain,
          s.questionIndex,
          (s.rate * 100).toStringAsFixed(0),
          s.text,
        ]);
      }

      rows.add([]);
      rows.add(['Least Mastered Skills (Top 3)']);
      rows.add(['Domain', 'Question #', 'Percent', 'Skill']);
      for (final s in _topLeast) {
        rows.add([
          s.domain,
          s.questionIndex,
          (s.rate * 100).toStringAsFixed(0),
          s.text,
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      await File(path).writeAsString(csv);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV saved: $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _exportPdf() async {
    try {
      if (_loading) return;

      final selectedLabel = _selectedClassId == null
          ? 'ALL_ACTIVE_CLASSES'
          : 'CLASS_${_selectedClassId!}';

      final suggestedName =
          'my_summary_${selectedLabel}_${_assessmentType.replaceAll(' ', '_')}.pdf';

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save My Summary (PDF)',
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (path == null) return;

      final classTitles = _selectedClassId == null
          ? _classes.map((c) => _classTitleById(c['class_id'] as int)).toList()
          : [_classTitleById(_selectedClassId!)];

      final bytes = await PdfService.buildMySummaryPdfBytes(
        teacherLabel: 'Teacher #${widget.userId}',
        assessmentType: _assessmentType,
        classTitles: classTitles,
        counts: _counts,
      );

      await File(path).writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved: $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    // Embedded mode: return just the content (no scaffold/navbar/appbar).
    if (widget.embedded) {
      return _embeddedBody();
    }

    // Standalone mode: full page
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      drawer: !isDesktop
          ? Navbar(
              selectedIndex: 2,
              onItemSelected: (_) {},
              role: widget.role,
              userId: widget.userId,
            )
          : null,
      backgroundColor: AppColors.bg,
      body: isDesktop
          ? Row(
              children: [
                Navbar(
                  selectedIndex: 2,
                  onItemSelected: (_) {},
                  role: widget.role,
                  userId: widget.userId,
                ),
                Expanded(child: _standaloneRight()),
              ],
            )
          : _standaloneRight(),
    );
  }

  Widget _standaloneRight() {
    return Column(
      children: [
        _standaloneAppBar(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(child: _content(showBigHeader: true)),
        ),
      ],
    );
  }

  Widget _standaloneAppBar() {
    return Container(
      height: 72,
      color: AppColors.maroon,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "My Summary",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _controlsRow(showExportIcons: true),
        ],
      ),
    );
  }

  Widget _embeddedBody() {
    // No navbar, no extra headers; uses same content with a small control row on top.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small dashboard controls row (no big bar)
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _controlsRow(
                      showExportIcons: true,
                    ), // set false if you want no export in dashboard tab
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: _content(showBigHeader: false),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _controlsRow({required bool showExportIcons}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _assessmentType,
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: 'Pre-Test', child: Text('Pre-Test')),
              DropdownMenuItem(value: 'Post-Test', child: Text('Post-Test')),
              DropdownMenuItem(
                value: 'Conditional',
                child: Text('Conditional'),
              ),
            ],
            onChanged: (v) async {
              if (v == null) return;
              setState(() => _assessmentType = v);
              await _loadSummary();
            },
          ),
        ),
        const SizedBox(width: 10),
        _classFilterDropdown(),
        if (showExportIcons) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.table_view),
            onPressed: _exportCsv,
          ),
          IconButton(
            tooltip: 'Export PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          ),
        ],
      ],
    );
  }

  Widget _classFilterDropdown() {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('All Active Classes'),
      ),
      ..._classes.map((c) {
        final id = c['class_id'] as int;
        return DropdownMenuItem<int?>(
          value: id,
          child: Text(_classTitleById(id)),
        );
      }),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedClassId,
          items: items,
          onChanged: (v) async {
            setState(() => _selectedClassId = v);
            await _loadSummary();
          },
        ),
      ),
    );
  }

  Widget _content({required bool showBigHeader}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBigHeader) ...[
          const Text(
            "Early Childhood Development Checklist",
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 10),
        ],
        Text(
          "Teacher’s Summary ($_assessmentType)",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Development Level Summary',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ..._counts.keys.map(
                  (domain) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _domainRow(domain, _counts[domain] ?? {}),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _skillsCard(),
      ],
    );
  }

  Widget _domainRow(String domain, Map<String, int> counts) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(domain, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (total == 0)
          const Text(
            'No assessments saved yet.',
            style: TextStyle(color: Colors.black54),
          )
        else
          Column(
            children: entries.map((e) {
              final pct = e.value / total;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // ✅ Removed ellipsis/overflow truncation as requested
                    SizedBox(width: 280, child: Text(e.key)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 10,
                          backgroundColor: Colors.black12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '${(pct * 100).toStringAsFixed(0)}% (${e.value})',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _skillsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most / Least Mastered Skills (Top 3)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _skillList(title: 'Most Mastered', items: _topMost),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _skillList(title: 'Least Mastered', items: _topLeast),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillList({required String title, required List<_SkillRate> items}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('No data.', style: TextStyle(color: Colors.black54))
          else
            ...items.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.domain} • Q${s.questionIndex} • ${(s.rate * 100).toStringAsFixed(0)}%',
                    ),
                    // ✅ No ellipsis; show full text
                    Text(s.text, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillRate {
  final String domain;
  final int questionIndex;
  final String text;
  final double rate;

  _SkillRate({
    required this.domain,
    required this.questionIndex,
    required this.text,
    required this.rate,
  });
}

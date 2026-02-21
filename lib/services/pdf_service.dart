import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<File> generateReport(
    String learnerName,
    Map<String, double> domainProgress,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Early Childhood Development Checklist',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Progress Report'),
            pw.SizedBox(height: 12),
            pw.Text('Learner: $learnerName'),
            pw.Divider(),
            pw.SizedBox(height: 12),
            ...domainProgress.entries.map(
              (e) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(e.key),
                  pw.Text('${e.value.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final file = File('eccd_${learnerName.replaceAll(" ", "_")}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ================= SUMMARY EXPORTS =================

  /// Builds a PDF for a class-level summary (same data as TeacherClassReportPage).
  static Future<Uint8List> buildClassSummaryPdfBytes({
    required String classTitle,
    required String assessmentType,
    required Map<String, Map<String, int>> counts,
    required List<Map<String, dynamic>> topMost,
    required List<Map<String, dynamic>> topLeast,
    DateTime? generatedAt,
  }) async {
    final pdf = pw.Document();
    final ts = generatedAt ?? DateTime.now();

    pw.Widget domainBlock(String domain, Map<String, int> c) {
      final total = c.values.fold<int>(0, (a, b) => a + b);
      final entries = c.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.6),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              domain,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            if (total == 0)
              pw.Text('No assessments saved yet.')
            else
              pw.Table(
                border: pw.TableBorder.symmetric(
                  inside: const pw.BorderSide(width: 0.3),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Level',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Count',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '%',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...entries.map((e) {
                    final pct = total == 0 ? 0 : (e.value / total) * 100;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(e.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${e.value}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(pct.toStringAsFixed(0)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      );
    }

    pw.Widget skillsBlock(String title, List<Map<String, dynamic>> items) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.6),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            if (items.isEmpty)
              pw.Text('No data.')
            else
              pw.Column(
                children: items.map((m) {
                  final domain = (m['domain'] ?? '').toString();
                  final q = (m['questionIndex'] ?? '').toString();
                  final rate = (m['rate'] ?? 0.0) as double;
                  final text = (m['text'] ?? '').toString();
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '$domain • Q$q • ${(rate * 100).toStringAsFixed(0)}%',
                        ),
                        pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            'ECCD Checklist • Class Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Class: $classTitle'),
          pw.Text('Assessment: $assessmentType'),
          pw.Text('Generated: ${ts.toIso8601String()}'),
          pw.Divider(),
          ...counts.entries.map((e) => domainBlock(e.key, e.value)),
          pw.SizedBox(height: 8),
          pw.Text(
            'Most / Least Mastered Skills (Top 3)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: skillsBlock('Most Mastered', topMost)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: skillsBlock('Least Mastered', topLeast)),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Builds a PDF for a teacher-level "My Summary" across selected classes.
  static Future<Uint8List> buildMySummaryPdfBytes({
    required String teacherLabel,
    required String assessmentType,
    required List<String> classTitles,
    required Map<String, Map<String, int>> counts,
    DateTime? generatedAt,
  }) async {
    final pdf = pw.Document();
    final ts = generatedAt ?? DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            'ECCD Checklist • My Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Teacher: $teacherLabel'),
          pw.Text('Assessment: $assessmentType'),
          pw.Text(
            'Classes Included: ${classTitles.isEmpty ? "None" : classTitles.join(", ")}',
          ),
          pw.Text('Generated: ${ts.toIso8601String()}'),
          pw.Divider(),
          ...counts.entries.map((e) {
            final total = e.value.values.fold<int>(0, (a, b) => a + b);
            final entries = e.value.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.6),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    e.key,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 6),
                  if (total == 0)
                    pw.Text('No assessments saved yet.')
                  else
                    pw.Table(
                      border: pw.TableBorder.symmetric(
                        inside: const pw.BorderSide(width: 0.3),
                      ),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Level',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Count',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '%',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...entries.map((r) {
                          final pct = total == 0 ? 0 : (r.value / total) * 100;
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(r.key),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text('${r.value}'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(pct.toStringAsFixed(0)),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    return pdf.save();
  }
}

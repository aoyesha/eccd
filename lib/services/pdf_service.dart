import 'dart:io';
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
}

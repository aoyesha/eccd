import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class FileExportService {

  Future<void> saveCsv({
    required String filename,
    required String csvText,
  }) async {
    final bytes = Uint8List.fromList(csvText.codeUnits);

    await FileSaver.instance.saveAs(
      name: filename,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  Future<void> savePdf({
    required String filename,
    required Uint8List pdfBytes,
  }) async {
    await FileSaver.instance.saveAs(
      name: filename,
      bytes: pdfBytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
  }
}
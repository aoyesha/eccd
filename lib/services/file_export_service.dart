import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';

class FileExportService {

  // ================= CSV =================
  Future<bool> saveCsv({
    required String filename,
    required String csvText,
  }) async {
    final bytes = Uint8List.fromList(csvText.codeUnits);
    return _saveFile(filename, bytes, 'csv');
  }

  // ================= XLSX =================
  Future<bool> saveXlsx({
    required String filename,
    required Uint8List xlsxBytes,
  }) async {
    return _saveFile(filename, xlsxBytes, 'xlsx');
  }

  // ================= PDF =================
  Future<bool> savePdf({
    required String filename,
    required Uint8List pdfBytes,
  }) async {
    return _saveFile(filename, pdfBytes, 'pdf');
  }

  // ================= CORE SAVE LOGIC =================
  Future<bool> _saveFile(String filename, Uint8List bytes, String ext) async {

    MimeType mimeFor(String e) {
      if (e == 'pdf') return MimeType.pdf;
      if (e == 'xlsx') return MimeType.microsoftExcel;
      return MimeType.csv;
    }

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
        ext: ext,
        mimeType: mimeFor(ext),
      );
      return true;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
        ext: ext,
        mimeType: mimeFor(ext),
      );
      return true;
    }

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save file',
      fileName: '$filename.$ext',
    );

    if (path == null) return false; // user cancelled

    final file = File(path);
    await file.writeAsBytes(bytes);
    return true;
  }
}

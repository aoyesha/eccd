import 'dart:io';
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class CsvImportService {
  /// Import learners from CSV file
  static Future<void> importLearnersFromCsv({
    required File file,
    required int classId,
  }) async {
    final db = await DatabaseService.instance.getDatabase();

    final raw = await file.readAsString();
    final rows = const CsvToListConverter(eol: '\n').convert(raw);

    if (rows.isEmpty) {
      throw Exception('CSV file is empty');
    }

    // Normalizing for consistencyy
    final headers = rows.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

    final requiredHeaders = [
      'surname',
      'given_name',
      'middle_name',
      'sex',
      'lrn',
      'birthday',
      'birth_order',
      'number_of_siblings',
      'province',
      'city',
      'barangay',
      'parent_name',
      'parent_occupation',
      'age_mother_at_birth',
      'spouse_occupation',
    ];

    for (final h in requiredHeaders) {
      if (!headers.contains(h)) {
        throw Exception('Missing required column: $h');
      }
    }

    final batch = db.batch();

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      if (row.length != headers.length) continue;

      final Map<String, dynamic> data = {};
      for (int j = 0; j < headers.length; j++) {
        data[headers[j]] = row[j] == null ? null : row[j].toString().trim();
      }

      if (data['surname'] == null ||
          data['given_name'] == null ||
          data['lrn'] == null) {
        continue; // skip invalid row
      }

      // Insert learner
      batch.insert('learner_information_table', {
        'class_id': classId,
        'surname': data['surname'],
        'given_name': data['given_name'],
        'middle_name': data['middle_name'],
        'sex': data['sex'],
        'lrn': data['lrn'],
        'birthday': data['birthday'],
        'birth_order': data['birth_order'],
        'number_of_siblings':
            int.tryParse(data['number_of_siblings'] ?? '0') ?? 0,
        'province': data['province'],
        'city': data['city'],
        'barangay': data['barangay'],
        'parent_name': data['parent_name'],
        'parent_occupation': data['parent_occupation'],
        'age_mother_at_birth':
            int.tryParse(data['age_mother_at_birth'] ?? '0') ?? 0,
        'spouse_occupation': (data['spouse_occupation']?.isNotEmpty ?? false)
            ? data['spouse_occupation']
            : 'N/A',
        'status': 'active',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await batch.commit(noResult: true);
  }
}

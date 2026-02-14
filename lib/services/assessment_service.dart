import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'assessment_scoring.dart';

class AssessmentService {
  // ================= SAVE ASSESSMENT =================
  static Future<void> saveAssessment({
    required int learnerId,
    required int classId,
    required String assessmentType,
    required DateTime date,
    required Map<String, bool> yesValues,
  }) async {
    final db = await DatabaseService.instance.getDatabase();

    try {
      // 1️⃣ Get learner birthday to compute age
      final learner = await db.query(
        DatabaseService.learnerTable,
        where: 'learner_id = ?',
        whereArgs: [learnerId],
      );
      if (learner.isEmpty) throw Exception("Learner not found");
      final dobStr = learner.first['birthday'] as String?;
      if (dobStr == null) throw Exception("Learner's birthday is missing");
      final dob = DateTime.parse(dobStr);

      int totalDays = date.difference(dob).inDays;
      int years = totalDays ~/ 365;
      int remainingDays = totalDays % 365;
      double months = remainingDays / 30;
      double ageAsOfAssessment = years + months / 12;

      // 2️⃣ Insert assessment_header
      int assessmentId = await db.insert('assessment_header', {
        'learner_id': learnerId,
        'class_id': classId,
        'assessment_type': assessmentType,
        'date_taken': date.toIso8601String(),
        'age_as_of_assessment': ageAsOfAssessment,
      });

      // 3️⃣ Insert answers into assessment_results
      final batch = db.batch();
      yesValues.forEach((key, value) {
        final parts = key.split('-');
        final domain = parts[0];
        final questionIndex = int.parse(parts[1]);

        batch.insert('assessment_results', {
          'assessment_id': assessmentId,
          'domain': domain,
          'question_index': questionIndex,
          'answer': value ? 1 : 0,
        });
      });
      await batch.commit(noResult: true);

      // 4️⃣ Map full domain names to short codes
      const domainMap = {
        'Gross Motor': 'gmd',
        'Fine Motor': 'fms',
        'Self Help': 'shd',
        'Dressing': 'shd',
        'Toilet': 'shd',
        'Receptive Language': 'rl',
        'Expressive Language': 'el',
        'Cognitive': 'cd',
        'Social Emotional': 'sed',
      };

// 5️⃣ Compute domain totals
      Map<String, int> domainTotals = {
        'gmd': 0,
        'fms': 0,
        'shd': 0,
        'rl': 0,
        'el': 0,
        'cd': 0,
        'sed': 0,
      };

      yesValues.forEach((key, value) {
        if (!value) return; // only count YES
        final domainShort = domainMap[key.trim()]; // trim to avoid extra spaces
        if (domainShort != null) {
          domainTotals[domainShort] = domainTotals[domainShort]! + 1;
        }
      });


      // 5️⃣ Call AssessmentScoring
      final ecdResult = AssessmentScoring.calculate(
        ageInYears: ageAsOfAssessment,
        gmdRaw: domainTotals['gmd']!,
        fmsRaw: domainTotals['fms']!,
        shdRaw: domainTotals['shd']!,
        rlRaw: domainTotals['rl']!,
        elRaw: domainTotals['el']!,
        cdRaw: domainTotals['cd']!,
        sedRaw: domainTotals['sed']!,
      );

      // 6️⃣ Insert into learner_ecd_table
      await db.insert('learner_ecd_table', {
        'assessment_id': assessmentId,
        ...ecdResult, // ensure keys match your table columns
      });
    } catch (e) {
      print("Error saving assessment: $e"); // <-- this will show errors in console
      rethrow; // let the UI know
    }
  }

  // ================= GET ASSESSMENT RESULTS =================
  static Future<List<Map<String, dynamic>>> getAssessment({
    required int learnerId,
    required int classId,
    required String assessmentType,
  }) async {
    final db = await DatabaseService.instance.getDatabase();

    final header = await db.query(
      'assessment_header',
      where: 'learner_id = ? AND class_id = ? AND assessment_type = ?',
      whereArgs: [learnerId, classId, assessmentType],
      orderBy: 'date_taken DESC',
      limit: 1,
    );

    if (header.isEmpty) return [];

    final assessmentId = header.first['id'] ?? header.first['assessment_id'];

    final results = await db.query(
      'assessment_results',
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
      orderBy: 'domain ASC, question_index ASC',
    );

    // attach date_taken to each row for UI
    return results.map((row) {
      row['date_taken'] = header.first['date_taken'];
      return row;
    }).toList();
  }

  // ================= GET ECD SUMMARY =================
  static Future<Map<String, dynamic>?> getEcdSummary({required int assessmentId}) async {
    final db = await DatabaseService.instance.getDatabase();
    final result = await db.query(
      'learner_ecd_table',
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );
    if (result.isEmpty) return null;
    return result.first;
  }
}

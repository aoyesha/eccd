import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

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

    // Remove old answers (overwrite behavior)
    await db.delete(
      DatabaseService.assessmentTable,
      where: 'learner_id = ? AND class_id = ? AND assessment_type = ?',
      whereArgs: [learnerId, classId, assessmentType],
    );

    final batch = db.batch();

    yesValues.forEach((key, value) {
      final parts = key.split('-');
      final domain = parts[0];
      final questionIndex = int.parse(parts[1]);

      batch.insert(DatabaseService.assessmentTable, {
        'learner_id': learnerId,
        'class_id': classId,
        'domain': domain,
        'question_index': questionIndex,
        'answer': value ? 1 : 0,
        'assessment_type': assessmentType,
        'date_taken': date.toIso8601String(),
      });
    });

    await batch.commit(noResult: true);
  }

  // ================= GET ASSESSMENT =================
  static Future<List<Map<String, dynamic>>> getAssessment({
    required int learnerId,
    required int classId,
    required String assessmentType,
  }) async {
    final db = await DatabaseService.instance.getDatabase();

    return await db.query(
      DatabaseService.assessmentTable,
      where: 'learner_id = ? AND class_id = ? AND assessment_type = ?',
      whereArgs: [learnerId, classId, assessmentType],
      orderBy: 'domain ASC, question_index ASC',
    );
  }
}

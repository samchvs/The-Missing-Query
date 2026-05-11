import 'package:graphics_project/domain/entities/diary_table.dart';

abstract class DiaryRepository {
  /// Loads the saved table for [caseKey] + [userId], or null if none.
  Future<DiaryTable?> loadTable(String caseKey, String userId);

  /// Persists [table] for [caseKey] + [userId].
  Future<void> saveTable(DiaryTable table, String caseKey, String userId);

  /// Returns true if a table already exists for [caseKey] + [userId].
  Future<bool> tableExists(String caseKey, String userId);
}

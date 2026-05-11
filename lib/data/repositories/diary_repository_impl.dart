import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphics_project/domain/entities/diary_table.dart';
import 'package:graphics_project/domain/repositories/diary_repository.dart';
import 'package:graphics_project/data/models/diary_table_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  static String _key(String caseKey, String userId) =>
      'diary_${caseKey}_$userId';

  @override
  Future<bool> tableExists(String caseKey, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key(caseKey, userId));
  }

  @override
  Future<DiaryTable?> loadTable(String caseKey, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(caseKey, userId));
    if (raw == null) return null;
    return DiaryTableModel.decode(raw).toEntity();
  }

  @override
  Future<void> saveTable(
      DiaryTable table, String caseKey, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = DiaryTableModel.encode(DiaryTableModel.fromEntity(table));
    await prefs.setString(_key(caseKey, userId), encoded);
  }

  @override
  Future<void> deleteTable(String caseKey, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(caseKey, userId));
  }
}

import 'dart:convert';
import 'package:graphics_project/domain/entities/diary_table.dart';

class DiaryTableModel {
  final String name;
  final List<String> columns;
  final List<Map<String, String>> rows;

  const DiaryTableModel({
    required this.name,
    required this.columns,
    required this.rows,
  });

  factory DiaryTableModel.fromEntity(DiaryTable entity) {
    return DiaryTableModel(
      name: entity.name,
      columns: entity.columns,
      rows: entity.rows,
    );
  }

  DiaryTable toEntity() {
    return DiaryTable(name: name, columns: columns, rows: rows);
  }

  factory DiaryTableModel.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'] as List<dynamic>? ?? [];
    return DiaryTableModel(
      name: json['name'] as String,
      columns: List<String>.from(json['columns'] as List<dynamic>),
      rows: rawRows
          .map((r) => Map<String, String>.from(r as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'columns': columns,
        'rows': rows,
      };

  static String encode(DiaryTableModel model) => jsonEncode(model.toJson());

  static DiaryTableModel decode(String raw) =>
      DiaryTableModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

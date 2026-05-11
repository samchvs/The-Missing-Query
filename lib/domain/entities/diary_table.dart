/// Represents one user-created table inside the CRUD Diary.
class DiaryTable {
  final String name;
  final List<String> columns;
  final List<Map<String, String>> rows;

  const DiaryTable({
    required this.name,
    required this.columns,
    required this.rows,
  });

  DiaryTable copyWith({
    String? name,
    List<String>? columns,
    List<Map<String, String>>? rows,
  }) {
    return DiaryTable(
      name: name ?? this.name,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
    );
  }
}

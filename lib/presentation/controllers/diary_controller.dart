import 'package:flutter/material.dart';
import 'package:graphics_project/domain/entities/diary_table.dart';
import 'package:graphics_project/domain/repositories/diary_repository.dart';
import 'package:graphics_project/data/repositories/diary_repository_impl.dart';

/// Result of executing a diary SQL command.
class DiaryResult {
  final bool success;
  final String message;
  /// Non-null for SELECT queries — the rows to display.
  final List<Map<String, String>>? rows;
  final List<String>? columns;

  const DiaryResult({
    required this.success,
    required this.message,
    this.rows,
    this.columns,
  });
}

class DiaryController extends ChangeNotifier {
  final DiaryRepository _repo;
  final String caseKey;
  final String userId;

  DiaryTable? _table;
  DiaryTable? get table => _table;
  bool get hasTable => _table != null;

  DiaryController({
    required this.caseKey,
    required this.userId,
    DiaryRepository? repository,
  }) : _repo = repository ?? DiaryRepositoryImpl();

  Future<void> loadExisting() async {
    _table = await _repo.loadTable(caseKey, userId);
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Main entry point: parse and execute any SQL
  // ─────────────────────────────────────────────
  Future<DiaryResult> execute(String rawSql) async {
    final clean = rawSql
        .trim()
        .replaceAll(RegExp(r'[\n\r\t]+'), ' ')
        .replaceAll(RegExp(r' +'), ' ');
    final upperClean = clean.toUpperCase();

    if (upperClean.startsWith('CREATE TABLE')) {
      return _handleCreate(clean);
    } else if (upperClean.startsWith('ALTER TABLE')) {
      return _handleAlter(clean);
    } else if (upperClean.startsWith('INSERT INTO')) {
      return _handleInsert(clean);
    } else if (upperClean.startsWith('SELECT')) {
      return _handleSelect(clean);
    } else if (upperClean.startsWith('UPDATE')) {
      return _handleUpdate(clean);
    } else if (upperClean.startsWith('DELETE FROM')) {
      return _handleDelete(clean);
    }

    return const DiaryResult(
      success: false,
      message: 'Unsupported command. Supported: CREATE TABLE, ALTER TABLE, INSERT INTO, SELECT, UPDATE, DELETE FROM.',
    );
  }

  // ─────────────────────────────────────────────
  // CREATE TABLE
  // ─────────────────────────────────────────────
  Future<DiaryResult> _handleCreate(String sql) async {
    if (_table != null) {
      return DiaryResult(
        success: false,
        message:
            'You already created a table for this case: "${_table!.name}". You can only CREATE TABLE once per case.',
      );
    }

    // CREATE TABLE table_name ( col1 datatype, col2 datatype, ... );
    final match = RegExp(
      r'CREATE\s+TABLE\s+(\w+)\s*\((.+)\)',
      caseSensitive: false,
    ).firstMatch(sql);

    if (match == null) {
      return const DiaryResult(
        success: false,
        message:
            'Invalid CREATE TABLE syntax.\nExpected:\nCREATE TABLE name (\n  col1 datatype,\n  col2 datatype\n);',
      );
    }

    final tableName = match.group(1)!.trim().toLowerCase();
    final colDefs = match.group(2)!;

    final columns = _parseColumnDefs(colDefs);
    if (columns.isEmpty) {
      return const DiaryResult(
        success: false,
        message: 'No columns defined. Add at least one column.',
      );
    }

    _table = DiaryTable(name: tableName, columns: columns, rows: []);
    await _repo.saveTable(_table!, caseKey, userId);
    notifyListeners();

    return DiaryResult(
      success: true,
      message: 'Table "${_table!.name}" created successfully.',
      rows: [],
      columns: columns,
    );
  }

  // ─────────────────────────────────────────────
  // ALTER TABLE … ADD column datatype
  // ─────────────────────────────────────────────
  Future<DiaryResult> _handleAlter(String sql) async {
    if (_table == null) {
      return const DiaryResult(
        success: false,
        message: 'No table exists yet. Use CREATE TABLE first.',
      );
    }

    final match = RegExp(
      r'ALTER\s+TABLE\s+(\w+)\s+ADD\s+(\w+)\s+\w+',
      caseSensitive: false,
    ).firstMatch(sql);

    if (match == null) {
      return const DiaryResult(
        success: false,
        message:
            'Invalid ALTER TABLE syntax.\nExpected:\nALTER TABLE name\nADD column_name datatype;',
      );
    }

    final targetTable = match.group(1)!.trim().toLowerCase();
    if (targetTable != _table!.name.toLowerCase()) {
      return DiaryResult(
        success: false,
        message: 'Table "$targetTable" does not exist. Your table is "${_table!.name}".',
      );
    }

    final newCol = match.group(2)!.trim().toLowerCase();
    if (_table!.columns.contains(newCol)) {
      return DiaryResult(
        success: false,
        message: 'Column "$newCol" already exists in table "${_table!.name}".',
      );
    }

    final updatedCols = [..._table!.columns, newCol];
    final updatedRows = _table!.rows
        .map((r) => {...r, newCol: ''})
        .toList();

    _table = _table!.copyWith(columns: updatedCols, rows: updatedRows);
    await _repo.saveTable(_table!, caseKey, userId);
    notifyListeners();

    return DiaryResult(
      success: true,
      message: 'Column "$newCol" added to "${_table!.name}".',
      rows: _table!.rows,
      columns: _table!.columns,
    );
  }

  // ─────────────────────────────────────────────
  // INSERT INTO table (col1, col2) VALUES (v1, v2)
  // ─────────────────────────────────────────────
  Future<DiaryResult> _handleInsert(String sql) async {
    if (_table == null) {
      return const DiaryResult(
        success: false,
        message: 'No table exists yet. Use CREATE TABLE first.',
      );
    }

    final match = RegExp(
      r'INSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)',
      caseSensitive: false,
    ).firstMatch(sql);

    if (match == null) {
      return const DiaryResult(
        success: false,
        message:
            'Invalid INSERT INTO syntax.\nExpected:\nINSERT INTO name (col1, col2)\nVALUES (val1, val2);',
      );
    }

    final targetTable = match.group(1)!.trim().toLowerCase();
    if (targetTable != _table!.name.toLowerCase()) {
      return DiaryResult(
        success: false,
        message: 'Table "$targetTable" does not exist. Your table is "${_table!.name}".',
      );
    }

    final colNames = _splitCsv(match.group(2)!);
    final values = _splitCsv(match.group(3)!);

    if (colNames.length != values.length) {
      return const DiaryResult(
        success: false,
        message: 'Number of columns and values do not match.',
      );
    }

    for (final col in colNames) {
      if (!_table!.columns.contains(col.toLowerCase())) {
        return DiaryResult(
          success: false,
          message: 'Unknown column "$col". Available: ${_table!.columns.join(', ')}.',
        );
      }
    }

    // Build new row: fill all columns, use '' for unspecified ones
    final newRow = <String, String>{
      for (final col in _table!.columns) col: '',
    };
    for (int i = 0; i < colNames.length; i++) {
      newRow[colNames[i].toLowerCase()] = values[i];
    }

    final updatedRows = [..._table!.rows, newRow];
    _table = _table!.copyWith(rows: updatedRows);
    await _repo.saveTable(_table!, caseKey, userId);
    notifyListeners();

    return DiaryResult(
      success: true,
      message: '1 row inserted into "${_table!.name}".',
      rows: _table!.rows,
      columns: _table!.columns,
    );
  }

  // ─────────────────────────────────────────────
  // SELECT
  // ─────────────────────────────────────────────
  Future<DiaryResult> _handleSelect(String sql) async {
    if (_table == null) {
      return const DiaryResult(
        success: false,
        message: 'No table exists yet. Use CREATE TABLE first.',
      );
    }

    final upper = sql.toUpperCase();

    // Extract FROM table
    final fromMatch = RegExp(r'\bFROM\b', caseSensitive: false).firstMatch(sql);
    if (fromMatch == null) {
      return const DiaryResult(success: false, message: 'Missing FROM clause.');
    }

    final afterFrom = sql.substring(fromMatch.end).trim();
    final whereMatch = RegExp(r'\bWHERE\b', caseSensitive: false).firstMatch(afterFrom);

    final parsedTable = whereMatch != null
        ? afterFrom.substring(0, whereMatch.start).trim().toLowerCase()
        : afterFrom.trim().toLowerCase();

    if (parsedTable != _table!.name.toLowerCase()) {
      return DiaryResult(
        success: false,
        message: 'Table "$parsedTable" does not exist. Your table is "${_table!.name}".',
      );
    }

    // Columns
    final selectPart = sql.substring(6, fromMatch.start).trim();
    List<String> selectedCols;

    if (selectPart == '*') {
      selectedCols = List.from(_table!.columns);
    } else {
      selectedCols = _splitCsv(selectPart).map((c) => c.toLowerCase()).toList();
      for (final col in selectedCols) {
        if (!_table!.columns.contains(col)) {
          return DiaryResult(
            success: false,
            message: 'Unknown column "$col". Available: ${_table!.columns.join(', ')}.',
          );
        }
      }
    }

    List<Map<String, String>> resultRows = List.from(_table!.rows);

    // WHERE clause
    if (whereMatch != null) {
      final whereClause = afterFrom.substring(whereMatch.end).trim();
      try {
        resultRows = resultRows.where((row) => _evalWhere(row, whereClause)).toList();
      } catch (e) {
        return DiaryResult(success: false, message: 'Invalid WHERE clause: $e');
      }
    }

    // Project columns
    final projected = resultRows.map((row) {
      return {for (final col in selectedCols) col: row[col] ?? ''};
    }).toList();

    return DiaryResult(
      success: true,
      message: '${projected.length} row(s) returned.',
      rows: projected,
      columns: selectedCols,
    );
  }

  // ─────────────────────────────────────────────
  // UPDATE table SET col=val WHERE condition
  // ─────────────────────────────────────────────
  Future<DiaryResult> _handleUpdate(String sql) async {
    if (_table == null) {
      return const DiaryResult(
        success: false,
        message: 'No table exists yet. Use CREATE TABLE first.',
      );
    }

    final match = RegExp(
      r'UPDATE\s+(\w+)\s+SET\s+(.+?)\s+WHERE\s+(.+)',
      caseSensitive: false,
    ).firstMatch(sql);

    // Also support UPDATE without WHERE
    final matchNoWhere = match == null
        ? RegExp(r'UPDATE\s+(\w+)\s+SET\s+(.+)', caseSensitive: false)
            .firstMatch(sql)
        : null;

    final targetTable =
        (match?.group(1) ?? matchNoWhere?.group(1))?.trim().toLowerCase();
    if (targetTable == null) {
      return const DiaryResult(
        success: false,
        message:
            'Invalid UPDATE syntax.\nExpected:\nUPDATE name\nSET col1 = val1\nWHERE condition;',
      );
    }

    if (targetTable != _table!.name.toLowerCase()) {
      return DiaryResult(
        success: false,
        message: 'Table "$targetTable" does not exist. Your table is "${_table!.name}".',
      );
    }

    final setPart = (match?.group(2) ?? matchNoWhere?.group(2))!.trim();
    final wherePart = match?.group(3)?.trim();

    // Parse SET assignments: col1 = 'val1', col2 = val2
    final assignments = <String, String>{};
    final assignRegex = RegExp(
      r"""(\w+)\s*=\s*('([^']*)'|"([^"]*)"|([^,]+))""",
    );
    for (final m in assignRegex.allMatches(setPart)) {
      final col = m.group(1)!.toLowerCase().trim();
      final val = (m.group(3) ?? m.group(4) ?? m.group(5) ?? '').trim();
      if (!_table!.columns.contains(col)) {
        return DiaryResult(
          success: false,
          message: 'Unknown column "$col" in SET clause.',
        );
      }
      assignments[col] = val;
    }

    if (assignments.isEmpty) {
      return const DiaryResult(success: false, message: 'No valid SET assignments found.');
    }

    int count = 0;
    final updatedRows = _table!.rows.map((row) {
      final matches = wherePart == null || _evalWhere(row, wherePart);
      if (matches) {
        count++;
        return {...row, ...assignments};
      }
      return row;
    }).toList();

    _table = _table!.copyWith(rows: updatedRows);
    await _repo.saveTable(_table!, caseKey, userId);
    notifyListeners();

    return DiaryResult(
      success: true,
      message: '$count row(s) updated in "${_table!.name}".',
      rows: _table!.rows,
      columns: _table!.columns,
    );
  }

  // ─────────────────────────────────────────────
  // DELETE FROM table WHERE condition
  // ─────────────────────────────────────────────
  Future<DiaryResult> _handleDelete(String sql) async {
    if (_table == null) {
      return const DiaryResult(
        success: false,
        message: 'No table exists yet. Use CREATE TABLE first.',
      );
    }

    final match = RegExp(
      r'DELETE\s+FROM\s+(\w+)\s+WHERE\s+(.+)',
      caseSensitive: false,
    ).firstMatch(sql);

    if (match == null) {
      return const DiaryResult(
        success: false,
        message:
            'Invalid DELETE syntax.\nExpected:\nDELETE FROM name\nWHERE condition;',
      );
    }

    final targetTable = match.group(1)!.trim().toLowerCase();
    if (targetTable != _table!.name.toLowerCase()) {
      return DiaryResult(
        success: false,
        message: 'Table "$targetTable" does not exist. Your table is "${_table!.name}".',
      );
    }

    final wherePart = match.group(2)!.trim();
    final before = _table!.rows.length;
    final updatedRows = _table!.rows
        .where((row) => !_evalWhere(row, wherePart))
        .toList();
    final deleted = before - updatedRows.length;

    _table = _table!.copyWith(rows: updatedRows);
    await _repo.saveTable(_table!, caseKey, userId);
    notifyListeners();

    return DiaryResult(
      success: true,
      message: '$deleted row(s) deleted from "${_table!.name}".',
      rows: _table!.rows,
      columns: _table!.columns,
    );
  }

  // ─────────────────────────────────────────────
  // WHERE evaluator (simple: col = 'val', col != 'val')
  // ─────────────────────────────────────────────
  bool _evalWhere(Map<String, String> row, String clause) {
    // Handle AND
    final andParts = clause.split(RegExp(r'\s+AND\s+', caseSensitive: false));
    if (andParts.length > 1) {
      return andParts.every((part) => _evalCondition(row, part.trim()));
    }

    // Handle OR
    final orParts = clause.split(RegExp(r'\s+OR\s+', caseSensitive: false));
    if (orParts.length > 1) {
      return orParts.any((part) => _evalCondition(row, part.trim()));
    }

    return _evalCondition(row, clause.trim());
  }

  bool _evalCondition(Map<String, String> row, String condition) {
    // col = 'val' or col = val
    final eqMatch = RegExp(
      r"""^(\w+)\s*(=|!=|<>|>=|<=|>|<)\s*('([^']*)'|"([^"]*)"|(\S+))$""",
      caseSensitive: false,
    ).firstMatch(condition);

    if (eqMatch != null) {
      final col = eqMatch.group(1)!.toLowerCase();
      final op = eqMatch.group(2)!;
      final val = (eqMatch.group(4) ?? eqMatch.group(5) ?? eqMatch.group(6) ?? '').trim();
      final actual = (row[col] ?? '').trim();

      final numA = double.tryParse(actual);
      final numB = double.tryParse(val);

      if (numA != null && numB != null) {
        switch (op) {
          case '=': return numA == numB;
          case '!=': case '<>': return numA != numB;
          case '>': return numA > numB;
          case '<': return numA < numB;
          case '>=': return numA >= numB;
          case '<=': return numA <= numB;
        }
      }

      switch (op) {
        case '=': return actual.toUpperCase() == val.toUpperCase();
        case '!=': case '<>': return actual.toUpperCase() != val.toUpperCase();
        case '>': return actual.compareTo(val) > 0;
        case '<': return actual.compareTo(val) < 0;
        case '>=': return actual.compareTo(val) >= 0;
        case '<=': return actual.compareTo(val) <= 0;
      }
    }

    // LIKE
    final likeMatch = RegExp(
      r"""^(\w+)\s+LIKE\s+['"]([^'"]+)['"]$""",
      caseSensitive: false,
    ).firstMatch(condition);

    if (likeMatch != null) {
      final col = likeMatch.group(1)!.toLowerCase();
      final pattern = likeMatch.group(2)!;
      final actual = row[col] ?? '';
      final regexPat =
          '^${RegExp.escape(pattern).replaceAll('%', '.*').replaceAll('_', '.')}' r'$';
      return RegExp(regexPat, caseSensitive: false).hasMatch(actual);
    }

    return false;
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  /// Parses column definitions from CREATE TABLE body, returns column names only.
  List<String> _parseColumnDefs(String colDefs) {
    return colDefs
        .split(',')
        .map((part) {
          final tokens = part.trim().split(RegExp(r'\s+'));
          return tokens.isNotEmpty ? tokens.first.toLowerCase() : '';
        })
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Splits comma-separated values, respecting quoted strings.
  List<String> _splitCsv(String raw) {
    final result = <String>[];
    final regex = RegExp(r"""'[^']*'|"[^"]*"|[^,]+""");
    for (final match in regex.allMatches(raw)) {
      var val = match.group(0)!.trim();
      if ((val.startsWith("'") && val.endsWith("'")) ||
          (val.startsWith('"') && val.endsWith('"'))) {
        val = val.substring(1, val.length - 1);
      }
      result.add(val);
    }
    return result;
  }
}

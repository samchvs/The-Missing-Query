import 'package:flutter/material.dart';

class SqlQueryResult {
  final List<Map<String, String>> rows;
  final List<String> columns;

  const SqlQueryResult({required this.rows, required this.columns});
}

class SimpleSqlEngine {
  final String tableName;
  final List<String> headers;
  final List<Map<String, String>> rows;
  final Set<String> numericColumns;
  final Set<String> timeColumns;

  const SimpleSqlEngine({
    required this.tableName,
    required this.headers,
    required this.rows,
    this.numericColumns = const {},
    this.timeColumns = const {},
  });

  SqlQueryResult execute(String rawQuery) {
    final query = rawQuery.trim().replaceAll(RegExp(r';\s*$'), '');
    final upper = query.toUpperCase();

    if (!upper.startsWith('SELECT ')) {
      throw Exception('Only SELECT queries are supported.');
    }

    final fromMatch = RegExp(
      r'\bFROM\b',
      caseSensitive: false,
    ).firstMatch(query);
    if (fromMatch == null) {
      throw Exception('Missing FROM clause.');
    }

    final selectPart = query.substring(6, fromMatch.start).trim();
    final afterFrom = query.substring(fromMatch.end).trim();

    final whereMatch = RegExp(
      r'\bWHERE\b',
      caseSensitive: false,
    ).firstMatch(afterFrom);
    final orderByMatch = RegExp(
      r'\bORDER\s+BY\b',
      caseSensitive: false,
    ).firstMatch(afterFrom);
    final limitMatch = RegExp(
      r'\bLIMIT\b',
      caseSensitive: false,
    ).firstMatch(afterFrom);

    int cutIndex = afterFrom.length;
    for (final match in [whereMatch, orderByMatch, limitMatch]) {
      if (match != null && match.start < cutIndex) {
        cutIndex = match.start;
      }
    }

    final parsedTableName = afterFrom
        .substring(0, cutIndex)
        .trim()
        .toLowerCase();
    if (parsedTableName != tableName.toLowerCase()) {
      throw Exception('Unknown table.');
    }

    final isCountAll = RegExp(
      r'^COUNT\s*\(\s*\*\s*\)$',
      caseSensitive: false,
    ).hasMatch(selectPart);

    List<String> selectedColumns;
    if (isCountAll) {
      selectedColumns = const ['count'];
    } else if (selectPart == '*') {
      selectedColumns = List.from(headers);
    } else {
      selectedColumns = selectPart
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      for (final col in selectedColumns) {
        if (!headers.contains(col)) {
          throw Exception('Unknown column: $col');
        }
      }
    }

    String? whereClause;
    String? orderByColumn;
    bool orderDescending = false;
    int? limit;

    if (whereMatch != null) {
      final start = whereMatch.end;
      int end = afterFrom.length;

      if (orderByMatch != null && orderByMatch.start > whereMatch.start) {
        end = orderByMatch.start;
      } else if (limitMatch != null && limitMatch.start > whereMatch.start) {
        end = limitMatch.start;
      }

      whereClause = afterFrom.substring(start, end).trim();
    }

    if (orderByMatch != null) {
      final start = orderByMatch.end;
      int end = afterFrom.length;

      if (limitMatch != null && limitMatch.start > orderByMatch.start) {
        end = limitMatch.start;
      }

      final orderClause = afterFrom.substring(start, end).trim();
      final parts = orderClause.split(RegExp(r'\s+'));

      if (parts.isNotEmpty) {
        orderByColumn = parts.first.toLowerCase();

        if (!headers.contains(orderByColumn)) {
          throw Exception('Unknown ORDER BY column.');
        }

        if (parts.length > 1) {
          orderDescending = parts[1].toUpperCase() == 'DESC';
        }
      }
    }

    if (limitMatch != null) {
      final limitText = afterFrom.substring(limitMatch.end).trim();
      limit = int.tryParse(limitText.split(RegExp(r'\s+')).first);
    }

    List<Map<String, String>> filteredRows = List.from(rows);

    if (whereClause != null && whereClause.isNotEmpty) {
      final clause = whereClause;
      filteredRows = filteredRows
          .where((row) => _evaluateWhereClause(row, clause))
          .toList();
    }

    if (isCountAll) {
      return SqlQueryResult(
        rows: [
          {'count': filteredRows.length.toString()},
        ],
        columns: const ['count'],
      );
    }

    if (orderByColumn != null) {
      filteredRows.sort((a, b) {
        final av = a[orderByColumn] ?? '';
        final bv = b[orderByColumn] ?? '';

        if (numericColumns.contains(orderByColumn)) {
          final an = _numericValueIfPossible(av);
          final bn = _numericValueIfPossible(bv);

          if (an != null && bn != null) {
            return orderDescending ? bn.compareTo(an) : an.compareTo(bn);
          }
        }

        if (timeColumns.contains(orderByColumn)) {
          return orderDescending ? bv.compareTo(av) : av.compareTo(bv);
        }

        final au = av.toUpperCase();
        final bu = bv.toUpperCase();
        return orderDescending ? bu.compareTo(au) : au.compareTo(bu);
      });
    }

    if (limit != null && limit >= 0 && limit < filteredRows.length) {
      filteredRows = filteredRows.take(limit).toList();
    }

    return SqlQueryResult(rows: filteredRows, columns: selectedColumns);
  }

  TextSpan buildHighlightedSqlText(String text, {bool isHint = false}) {
    if (isHint) {
      return const TextSpan(
        text: 'ENTER SQL QUERY...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontFamily: 'Consolas',
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      );
    }

    const keywordStyle = TextStyle(
      color: Color(0xFF7B1FA2),
      fontSize: 14,
      fontFamily: 'Consolas',
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    const columnStyle = TextStyle(
      color: Color(0xFF1565C0),
      fontSize: 14,
      fontFamily: 'Consolas',
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    const stringStyle = TextStyle(
      color: Color(0xFF2E7D32),
      fontSize: 14,
      fontFamily: 'Consolas',
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    const normalStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontFamily: 'Consolas',
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    final tokens = RegExp(
      '''('[^']*'|"[^"]*"|\\w+|[=,*();<>!]+|\\s+|.)''',
    ).allMatches(text).map((m) => m.group(0)!).toList();

    const keywords = {
      'SELECT',
      'FROM',
      'WHERE',
      'AND',
      'OR',
      'LIKE',
      'ORDER',
      'BY',
      'ASC',
      'DESC',
      'LIMIT',
      'IN',
      'BETWEEN',
      'COUNT',
    };

    final spans = <TextSpan>[];

    for (final token in tokens) {
      final upper = token.toUpperCase();

      if ((token.startsWith("'") && token.endsWith("'")) ||
          (token.startsWith('"') && token.endsWith('"'))) {
        spans.add(TextSpan(text: token, style: stringStyle));
      } else if (keywords.contains(upper)) {
        spans.add(TextSpan(text: token, style: keywordStyle));
      } else if (headers.contains(token.toLowerCase())) {
        spans.add(TextSpan(text: token, style: columnStyle));
      } else {
        spans.add(TextSpan(text: token, style: normalStyle));
      }
    }

    return TextSpan(children: spans);
  }

  bool _evaluateWhereClause(Map<String, String> row, String clause) {
    final orParts = clause.split(RegExp(r'\s+OR\s+', caseSensitive: false));

    for (final orPart in orParts) {
      final andParts = orPart.split(RegExp(r'\s+AND\s+', caseSensitive: false));
      bool andResult = true;

      for (final condition in andParts) {
        if (!_evaluateCondition(row, condition.trim())) {
          andResult = false;
          break;
        }
      }

      if (andResult) return true;
    }

    return false;
  }

  bool _evaluateCondition(Map<String, String> row, String condition) {
    final likeMatch = RegExp(
      '^([a-zA-Z_][a-zA-Z0-9_]*)\\s+LIKE\\s+[\'"]([^\'"]*)[\'"]\$',
      caseSensitive: false,
    ).firstMatch(condition);

    if (likeMatch != null) {
      final column = likeMatch.group(1)!.toLowerCase();
      final pattern = likeMatch.group(2)!;
      final value = row[column] ?? '';

      if (!headers.contains(column)) return false;

      final regexPattern =
          '^${RegExp.escape(pattern).replaceAll('%', '.*').replaceAll('_', '.')}\$';
      return RegExp(regexPattern, caseSensitive: false).hasMatch(value);
    }

    final inMatch = RegExp(
      '^([a-zA-Z_][a-zA-Z0-9_]*)\\s+IN\\s*\\((.+)\\)\$',
      caseSensitive: false,
    ).firstMatch(condition);

    if (inMatch != null) {
      final column = inMatch.group(1)!.toLowerCase();
      final rawValues = inMatch.group(2)!;

      if (!headers.contains(column)) return false;

      final parsedValues = _parseInList(rawValues);
      final actual = (row[column] ?? '').toUpperCase();

      return parsedValues.any((v) => actual == v.toUpperCase());
    }

    final betweenMatch = RegExp(
      '^([a-zA-Z_][a-zA-Z0-9_]*)\\s+BETWEEN\\s+[\'"]?([^\'"]+)[\'"]?\\s+AND\\s+[\'"]?([^\'"]+)[\'"]?\$',
      caseSensitive: false,
    ).firstMatch(condition);

    if (betweenMatch != null) {
      final column = betweenMatch.group(1)!.toLowerCase();
      final lowerRaw = betweenMatch.group(2)!.trim();
      final upperRaw = betweenMatch.group(3)!.trim();

      if (!headers.contains(column)) return false;

      if (numericColumns.contains(column)) {
        final actual = _numericValueIfPossible(row[column] ?? '');
        final lower = _numericValueIfPossible(lowerRaw);
        final upper = _numericValueIfPossible(upperRaw);

        if (actual == null || lower == null || upper == null) return false;
        return actual >= lower && actual <= upper;
      }

      if (timeColumns.contains(column)) {
        final actual = row[column] ?? '';
        return actual.compareTo(lowerRaw) >= 0 &&
            actual.compareTo(upperRaw) <= 0;
      }

      final actual = (row[column] ?? '').toUpperCase();
      return actual.compareTo(lowerRaw.toUpperCase()) >= 0 &&
          actual.compareTo(upperRaw.toUpperCase()) <= 0;
    }

    final eqMatch = RegExp(
      '^([a-zA-Z_][a-zA-Z0-9_]*)\\s*(=|!=|<>)\\s+[\'"]([^\'"]*)[\'"]\$',
      caseSensitive: false,
    ).firstMatch(condition);

    if (eqMatch != null) {
      final column = eqMatch.group(1)!.toLowerCase();
      final op = eqMatch.group(2)!;
      final expected = eqMatch.group(3)!;
      final actual = row[column] ?? '';

      if (!headers.contains(column)) return false;

      switch (op) {
        case '=':
          return actual.toUpperCase() == expected.toUpperCase();
        case '!=':
        case '<>':
          return actual.toUpperCase() != expected.toUpperCase();
      }
    }

    final compareMatch = RegExp(
      '^([a-zA-Z_][a-zA-Z0-9_]*)\\s*(>=|<=|>|<)\\s+[\'"]([^\'"]*)[\'"]\$',
      caseSensitive: false,
    ).firstMatch(condition);

    if (compareMatch != null) {
      final column = compareMatch.group(1)!.toLowerCase();
      final op = compareMatch.group(2)!;
      final expectedRaw = compareMatch.group(3)!;

      if (!headers.contains(column)) return false;

      if (numericColumns.contains(column)) {
        final actual = _numericValueIfPossible(row[column] ?? '');
        final expected = _numericValueIfPossible(expectedRaw);

        if (actual == null || expected == null) return false;

        switch (op) {
          case '>':
            return actual > expected;
          case '<':
            return actual < expected;
          case '>=':
            return actual >= expected;
          case '<=':
            return actual <= expected;
        }
      }

      if (timeColumns.contains(column)) {
        final actual = row[column] ?? '';
        final compare = actual.compareTo(expectedRaw);

        switch (op) {
          case '>':
            return compare > 0;
          case '<':
            return compare < 0;
          case '>=':
            return compare >= 0;
          case '<=':
            return compare <= 0;
        }
      }
    }

    return false;
  }

  List<String> _parseInList(String rawValues) {
    final matches = RegExp(r'''('[^']*'|"[^"]*"|[^,]+)''')
        .allMatches(rawValues)
        .map((m) => m.group(0)!.trim())
        .where((v) => v.isNotEmpty)
        .map((v) {
          if ((v.startsWith("'") && v.endsWith("'")) ||
              (v.startsWith('"') && v.endsWith('"'))) {
            return v.substring(1, v.length - 1);
          }
          return v;
        })
        .toList();

    return matches;
  }

  double? _numericValueIfPossible(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('\$', '').trim();
    return double.tryParse(cleaned);
  }
}

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
    // Normalize query: remove semicolon, replace newlines/tabs with spaces
    final cleanQuery = rawQuery
        .trim()
        .replaceAll(';', '')
        .replaceAll(RegExp(r'[\n\r\t]+'), ' ');
    final upper = cleanQuery.toUpperCase();

    if (!upper.startsWith('SELECT ')) {
      throw Exception('Only SELECT queries are supported.');
    }

    final fromMatch = RegExp(
      r'\bFROM\b',
      caseSensitive: false,
    ).firstMatch(cleanQuery);
    if (fromMatch == null) {
      throw Exception('Missing FROM clause.');
    }

    final selectPart = cleanQuery.substring(6, fromMatch.start).trim();
    final afterFrom = cleanQuery.substring(fromMatch.end).trim();

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
      debugPrint(
        'SQL Engine: Expected table "${tableName.toLowerCase()}", but got "$parsedTableName"',
      );
      throw Exception('Unknown table: $parsedTableName');
    }

    bool isCountAll = RegExp(
      r'^COUNT\s*\(\s*\*\s*\)$',
      caseSensitive: false,
    ).hasMatch(selectPart);

    String? sumColumn;
    String? sumAlias;
    final sumMatch = RegExp(
      r'^SUM\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)(\s+AS\s+([a-zA-Z_][a-zA-Z0-9_]*))?$',
      caseSensitive: false,
    ).firstMatch(selectPart);

    if (sumMatch != null) {
      sumColumn = sumMatch.group(1)!.toLowerCase();
      sumAlias = sumMatch.group(3) ?? 'sum(${sumMatch.group(1)})';
      if (!headers.contains(sumColumn)) {
        throw Exception('Unknown column for SUM: $sumColumn');
      }
    }

    List<String> selectedColumns;
    if (isCountAll) {
      selectedColumns = const ['count'];
    } else if (sumColumn != null) {
      selectedColumns = [sumAlias!];
    } else if (selectPart == '*') {
      selectedColumns = List.from(headers);
    } else {
      selectedColumns = selectPart
          .split(',')
          .map((e) {
            final part = e.trim();
            final asMatch = RegExp(
              r'\s+AS\s+',
              caseSensitive: false,
            ).firstMatch(part);
            if (asMatch != null) {
              return part.substring(0, asMatch.start).trim().toLowerCase();
            }
            return part.toLowerCase();
          })
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

    debugPrint('SQL Engine: selectPart: "$selectPart"');
    debugPrint('SQL Engine: whereClause: "$whereClause"');

    List<Map<String, String>> filteredRows = List.from(rows);

    if (whereClause != null && whereClause.isNotEmpty) {
      final clause = whereClause;
      filteredRows = filteredRows.where((row) {
        final result = _evaluateWhereClause(row, clause);
        if (result) {
          debugPrint(
            'SQL Engine: Row PASSED: ${row.values.take(2).join(", ")}...',
          );
        }
        return result;
      }).toList();
    }
    debugPrint('SQL Engine: Total filtered rows: ${filteredRows.length}');

    if (isCountAll) {
      return SqlQueryResult(
        rows: [
          {'count': filteredRows.length.toString()},
        ],
        columns: const ['count'],
      );
    }

    if (sumColumn != null) {
      double total = 0;
      for (final row in filteredRows) {
        final val = _numericValueIfPossible(row[sumColumn] ?? '0');
        if (val != null) {
          total += val;
        }
      }
      return SqlQueryResult(
        rows: [
          {sumAlias!: total.toStringAsFixed(total == total.toInt() ? 0 : 2)},
        ],
        columns: [sumAlias],
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

  TextSpan buildHighlightedSqlText(
    String text, {
    bool isHint = false,
    TextStyle? baseStyle,
  }) {
    if (isHint) {
      return TextSpan(
        text: 'ENTER SQL QUERY...',
        style: (baseStyle ?? const TextStyle()).copyWith(
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

    final normalStyle = (baseStyle ?? const TextStyle()).copyWith(
      color: Colors.black,
      fontSize: 14,
      fontFamily: 'Consolas',
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    final tokens = RegExp(
      """('[^']*'|"[^"]*"|\\w+|[=,*();<>!]+|\\s+|.)""",
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
      'SUM',
      'AS',
    };

    final spans = <TextSpan>[];

    for (final token in tokens) {
      final upper = token.toUpperCase();

      if ((token.startsWith("'") && token.endsWith("'")) ||
          (token.startsWith('"') && token.endsWith('"'))) {
        spans.add(TextSpan(text: token, style: stringStyle));
      } else if (keywords.contains(upper)) {
        spans.add(TextSpan(text: upper, style: keywordStyle));
      } else if (headers.contains(token.toLowerCase())) {
        spans.add(TextSpan(text: token, style: columnStyle));
      } else {
        spans.add(TextSpan(text: token, style: normalStyle));
      }
    }

    return TextSpan(style: baseStyle, children: spans);
  }

  bool _evaluateWhereClause(Map<String, String> row, String clause,
      [List<String>? externalInLists]) {
    debugPrint('SQL Engine: Evaluating WHERE: "$clause"');
    String processedClause = clause.trim();
    final inLists = externalInLists ?? <String>[];

    if (externalInLists == null) {
      // Step 1: Protect IN(...) lists robustly (handling balanced parens)
      // This only happens at the top-level call.
      int searchPos = 0;
      while (true) {
        final inMatch = RegExp(r'\bIN\s*\(', caseSensitive: false)
            .firstMatch(processedClause.substring(searchPos));
        if (inMatch == null) break;

        final startIdx = searchPos + inMatch.start;
        final openParenIdx = searchPos + inMatch.end - 1;
        final closeParenIdx = _findClosingParen(processedClause, openParenIdx);

        if (closeParenIdx == -1) {
          throw const FormatException("Unmatched opening parenthesis in WHERE clause");
        }

        final fullIn = processedClause.substring(startIdx, closeParenIdx + 1);
        final placeholder = '___IN_LIST_${inLists.length}___';
        inLists.add(fullIn);
        processedClause = processedClause.substring(0, startIdx) +
            placeholder +
            processedClause.substring(closeParenIdx + 1);
        searchPos = startIdx + placeholder.length;
      }
    }

    // Step 2: Resolve remaining parentheses (grouped AND/OR logic).
    // IN lists are already protected so their parens won't be consumed here.
    final parenRegex = RegExp(r'\(([^()]+)\)');
    while (parenRegex.hasMatch(processedClause)) {
      final match = parenRegex.firstMatch(processedClause)!;
      final inner = match.group(1)!;

      // If it starts with SELECT, it's a subquery, don't evaluate it here
      if (inner.trim().toUpperCase().startsWith('SELECT ')) {
        break;
      }

      processedClause = processedClause.replaceFirstMapped(parenRegex, (m) {
        final innerMatch = m.group(1)!;
        return _evaluateWhereClause(row, innerMatch, inLists) ? 'TRUE' : 'FALSE';
      });
    }

    // Step 3: Handle OR parts
    final orParts = processedClause.split(
      RegExp(r'\s+OR\s+', caseSensitive: false),
    );

    for (final orPart in orParts) {
      if (orPart.trim().toUpperCase() == 'TRUE') return true;
      if (orPart.trim().toUpperCase() == 'FALSE') continue;

      // Handle AND
      String processedOrPart = orPart;
      final betweenMatches = RegExp(
        r"""\bBETWEEN\b\s+['"]?([^'"]+)['"]?\s+\bAND\b\s+['"]?([^'"]+)['"]?""",
        caseSensitive: false,
      ).allMatches(orPart);

      for (final match in betweenMatches) {
        final fullMatch = match.group(0)!;
        final protectedMatch = fullMatch.replaceFirst(
          RegExp(r'\bAND\b', caseSensitive: false),
          '___BETWEEN_AND___',
        );
        processedOrPart = processedOrPart.replaceFirst(
          fullMatch,
          protectedMatch,
        );
      }

      final andParts = processedOrPart.split(
        RegExp(r'\s+AND\s+', caseSensitive: false),
      );
      bool andResult = true;

      for (String condition in andParts) {
        final trimmed = condition.trim();
        if (trimmed.toUpperCase() == 'TRUE') continue;
        if (trimmed.toUpperCase() == 'FALSE') {
          andResult = false;
          break;
        }

        // Restore placeholders
        String restored = trimmed.replaceAll('___BETWEEN_AND___', 'AND');
        for (int i = 0; i < inLists.length; i++) {
          restored = restored.replaceFirst('___IN_LIST_${i}___', inLists[i]);
        }

        if (!_evaluateCondition(row, restored)) {
          andResult = false;
          break;
        }
      }

      if (andResult) return true;
    }

    return false;
  }

  bool _evaluateCondition(Map<String, String> row, String condition) {
    debugPrint('SQL Engine: Evaluating condition: "$condition"');
    final likeMatch = RegExp(
      r"""^([a-zA-Z_][a-zA-Z0-9_]*)\s+LIKE\s+['"]([^'"]*)['"]$""",
      caseSensitive: false,
    ).firstMatch(condition);

    if (likeMatch != null) {
      final column = likeMatch.group(1)!.toLowerCase();
      final pattern = likeMatch.group(2)!;
      final value = row[column] ?? '';

      if (!headers.contains(column)) return false;

      final regexPattern =
          '^${RegExp.escape(pattern).replaceAll('%', '.*').replaceAll('_', '.')}'
          r'$';
      return RegExp(regexPattern, caseSensitive: false).hasMatch(value);
    }

    final inMatch = RegExp(
      r"""^([a-zA-Z_][a-zA-Z0-9_]*)\s+IN\s*\((.+)\)$""",
      caseSensitive: false,
    ).firstMatch(condition);

    if (inMatch != null) {
      final column = inMatch.group(1)!.toLowerCase();
      String rawValues = inMatch.group(2)!;

      if (!headers.contains(column)) return false;

      // Handle Subquery in IN: IN (SELECT ...)
      if (rawValues.trim().toUpperCase().startsWith('SELECT ')) {
        try {
          final subResult = execute(rawValues);
          if (subResult.columns.isEmpty) return false;
          final firstCol = subResult.columns.first;
          final actual = (row[column] ?? '').toUpperCase();
          return subResult.rows.any((subRow) {
            final val = subRow[firstCol] ?? '';
            return actual == val.toUpperCase();
          });
        } catch (e) {
          debugPrint('SQL Engine: Subquery in IN failed: $e');
          return false;
        }
      }

      final parsedValues = _parseInList(rawValues);
      final actual = (row[column] ?? '').toUpperCase();

      return parsedValues.any((v) => actual == v.toUpperCase());
    }

    final betweenMatch = RegExp(
      r"""^([a-zA-Z_][a-zA-Z0-9_]*)\s+BETWEEN\s+['"]?([^'"]+)['"]?\s+AND\s+['"]?([^'"]+)['"]?$""",
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
        final actual = _normalizeTimeValue(row[column] ?? '');
        final lower = _normalizeTimeValue(lowerRaw);
        final upper = _normalizeTimeValue(upperRaw);

        if (lower.compareTo(upper) > 0) {
          // Crosses midnight (e.g. 23:00 to 03:00)
          return actual.compareTo(lower) >= 0 || actual.compareTo(upper) <= 0;
        } else {
          // Normal range (e.g. 03:00 to 23:00)
          return actual.compareTo(lower) >= 0 && actual.compareTo(upper) <= 0;
        }
      }

      final actual = (row[column] ?? '').toUpperCase();
      return actual.compareTo(lowerRaw.toUpperCase()) >= 0 &&
          actual.compareTo(upperRaw.toUpperCase()) <= 0;
    }

    final eqMatch = RegExp(
      r"""^([a-zA-Z_][a-zA-Z0-9_]*)\s*(=|!=|<>)\s*(.+)$""",
      caseSensitive: false,
    ).firstMatch(condition);

    if (eqMatch != null) {
      final column = eqMatch.group(1)!.toLowerCase();
      final op = eqMatch.group(2)!;
      String rawExpected = eqMatch.group(3)!.trim();

      if (!headers.contains(column)) return false;

      String expected;
      // Handle Subquery in Equality: = (SELECT ...)
      if (rawExpected.startsWith('(') &&
          rawExpected.endsWith(')') &&
          rawExpected
              .substring(1, rawExpected.length - 1)
              .trim()
              .toUpperCase()
              .startsWith('SELECT ')) {
        final subQuery = rawExpected
            .substring(1, rawExpected.length - 1)
            .trim();
        try {
          final subResult = execute(subQuery);
          if (subResult.rows.isEmpty || subResult.columns.isEmpty) return false;
          final firstCol = subResult.columns.first;
          expected = subResult.rows.first[firstCol] ?? '';
        } catch (e) {
          debugPrint('SQL Engine: Subquery in equality failed: $e');
          return false;
        }
      } else {
        // Strip quotes if present
        expected = rawExpected;
        if ((expected.startsWith("'") && expected.endsWith("'")) ||
            (expected.startsWith('"') && expected.endsWith('"'))) {
          expected = expected.substring(1, expected.length - 1);
        }
      }

      final actual = (row[column] ?? '').trim();

      switch (op) {
        case '=':
          return actual.toUpperCase() == expected.toUpperCase();
        case '!=':
        case '<>':
          return actual.toUpperCase() != expected.toUpperCase();
      }
    }

    final compareMatch = RegExp(
      r"""^([a-zA-Z_][a-zA-Z0-9_]*)\s*(>=|<=|>|<)\s*['"]?([^'"]*)['"]?$""",
      caseSensitive: false,
    ).firstMatch(condition);

    if (compareMatch != null) {
      final column = compareMatch.group(1)!.toLowerCase();
      final op = compareMatch.group(2)!;
      final expectedRaw = compareMatch.group(3)!.trim();
      final actualRaw = (row[column] ?? '').trim();

      if (!headers.contains(column)) return false;

      if (numericColumns.contains(column)) {
        final actual = _numericValueIfPossible(actualRaw);
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
        final expected = _normalizeTimeValue(expectedRaw);
        final compare = actual.compareTo(expected);

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
    final matches = RegExp(r"""('[^']*'|"[^"]*"|[^,]+)""")
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

  String _normalizeTimeValue(String value) {
    // If it's a simple HH:MM or HH:MM:SS format, ensure it's zero-padded
    final parts = value.split(':');
    if (parts.length >= 2) {
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      final s = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
      return '$h:$m:$s';
    }
    return value;
  }
  int _findClosingParen(String text, int openPos) {
    int closePos = openPos;
    int counter = 1;
    while (counter > 0) {
      closePos++;
      if (closePos >= text.length) return -1;
      if (text[closePos] == '(') {
        counter++;
      } else if (text[closePos] == ')') {
        counter--;
      }
    }
    return closePos;
  }
}

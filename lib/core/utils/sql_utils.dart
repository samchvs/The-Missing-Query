import 'package:flutter/services.dart';

class SqlUtils {
  static const Set<String> keywords = {
    'SELECT', 'FROM', 'WHERE', 'ORDER', 'BY', 'LIMIT',
    'LIKE', 'BETWEEN', 'AS', 'DISTINCT', 'COUNT', 'SUM', 'AVG',
    'MIN', 'MAX', 'GROUP', 'HAVING', 'JOIN', 'LEFT', 'RIGHT', 'INNER',
     'DESC', 'ASC', 'UNION', 'INSERT', 'INTO', 'VALUES', 'COLUMN',
    'UPDATE', 'SET', 'DELETE', 'CREATE', 'DROP', 'ALTER', 'VARCHAR', 'INT', 'PRIMARY KEY'
  };

  static String formatSql(String input, [TextRange? _]) {
    if (input.isEmpty) return input;

    final regex = RegExp(r'\b\w+\b', caseSensitive: false);
    
    return input.replaceAllMapped(regex, (match) {
      final word = match.group(0)!;
      final upper = word.toUpperCase();
      if (keywords.contains(upper)) {
        return upper;
      }
      return word;
    });
  }
}

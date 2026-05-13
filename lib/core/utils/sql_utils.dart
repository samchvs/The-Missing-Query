import 'package:flutter/services.dart';

class SqlUtils {
  static const Set<String> keywords = {
    'SELECT', 'FROM', 'WHERE', 'ORDER', 'BY', 'LIMIT',
    'LIKE', 'BETWEEN', 'AS', 'DISTINCT', 'COUNT', 'SUM', 'AVG',
    'MIN', 'MAX', 'GROUP', 'HAVING', 'JOIN', 'LEFT', 'RIGHT', 'INNER',
    'DESC', 'ASC', 'UNION', 'INSERT', 'INTO', 'VALUES', 'COLUMN',
    'UPDATE', 'SET', 'DELETE', 'CREATE', 'DROP', 'ALTER', 'VARCHAR',
    'INT', 'INTEGER', 'TABLE', 'PRIMARY', 'KEY', 'TEXT', 'NULL', 'NOT', 'DEFAULT', 'ALL',
    'PRIMARY_KEY', 'FOREIGN_KEY', 'AUTO_INCREMENT', 'AND', 'OR', 'IN'
  };

  static String formatSql(String input, [TextRange? _]) {
    if (input.isEmpty) return input;

    // Matches string literals or words
    final regex = RegExp(r"('.*?'|\b\w+\b)", caseSensitive: false);
    
    return input.replaceAllMapped(regex, (match) {
      final matchStr = match.group(0)!;
      
      // If it's a string literal, return as-is
      if (matchStr.startsWith("'") && matchStr.endsWith("'")) {
        return matchStr;
      }

      final upper = matchStr.toUpperCase();
      if (keywords.contains(upper)) {
        // Auto-uppercase if it's all lowercase OR if it starts with at least two uppercase letters
        // (which indicates it's a "ghost" of a previous auto-caps match, e.g. "INT" + "o" = "INTo").
        bool shouldUppercase = matchStr == matchStr.toLowerCase();
        if (!shouldUppercase && matchStr.length >= 2) {
          final firstTwo = matchStr.substring(0, 2);
          if (firstTwo == firstTwo.toUpperCase()) {
            shouldUppercase = true;
          }
        }

        if (shouldUppercase) {
          return upper;
        }
        return matchStr;
      }
      
      for (final kw in keywords) {
        if (matchStr.startsWith(kw) && matchStr.length > kw.length) {
          // If the part AFTER the keyword contains lowercase letters, it's likely an "infection" 
          // (e.g. "INT" + "e" = "INTe"). We normalize these back to lowercase.
          // If it's all uppercase or neutral (e.g. "SET_"), we assume intentionality.
          final rest = matchStr.substring(kw.length);
          if (rest != rest.toUpperCase()) {
            return matchStr.toLowerCase();
          }
          return matchStr;
        }
      }
      
      return matchStr; // Preserve user's intended case (e.g. "Intelligence")
    });
  }
}

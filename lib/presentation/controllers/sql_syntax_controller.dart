import 'package:flutter/material.dart';
import 'package:graphics_project/domain/usecases/simple_sql_engine.dart';

class SqlSyntaxController extends TextEditingController {
  final SimpleSqlEngine sqlEngine;
  bool _isUpdating = false;

  static const Set<String> _keywords = {
    'SELECT',
    'FROM',
    'WHERE',
    'AND',
    'OR',
    'ORDER',
    'BY',
    'LIMIT',
    'LIKE',
    'IN',
    'BETWEEN',
    'AS',
    'DISTINCT',
    'COUNT',
    'SUM',
    'AVG',
    'MIN',
    'MAX',
  };

  SqlSyntaxController({required this.sqlEngine, super.text}) {
    addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (_isUpdating) return;

    final currentText = text;
    if (currentText.isEmpty) return;

    final transformed = _uppercaseKeywords(currentText);

    if (transformed != currentText) {
      _isUpdating = true;
      final currentSelection = selection;
      value = value.copyWith(
        text: transformed,
        selection: currentSelection,
      );
      _isUpdating = false;
    }
  }

  String _uppercaseKeywords(String input) {
    // Basic regex to identify words, while being aware of strings in quotes
    // This matches:
    // 1. Strings in single quotes: '[^']*'
    // 2. Strings in double quotes: "[^"]*"
    // 3. Words: \b\w+\b
    // 4. Everything else: .
    final regex = RegExp(r"('[^']*'|""[^""]*""|\b\w+\b|.)", dotAll: true);
    
    return regex.allMatches(input).map((m) {
      final match = m.group(0)!;
      // If it's a word (not starting with quotes)
      if (match.isNotEmpty && !match.startsWith("'") && !match.startsWith('"')) {
        final upper = match.toUpperCase();
        if (_keywords.contains(upper)) {
          return upper;
        }
      }
      return match;
    }).join('');
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // If the text is empty, let the TextField handle the hintText styling natively.
    if (text.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    // Use the existing engine logic to build the highlighted span tree.
    // We pass the provided 'style' as the base to ensure consistency.
    return sqlEngine.buildHighlightedSqlText(text, baseStyle: style);
  }

  @override
  void dispose() {
    removeListener(_handleTextChange);
    super.dispose();
  }
}

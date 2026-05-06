import 'package:flutter/material.dart';
import 'package:graphics_project/domain/usecases/simple_sql_engine.dart';
import 'package:graphics_project/core/utils/sql_utils.dart';

/// Specialized controller for Mystery/Gameplay screens.
class MysterySqlController extends TextEditingController {
  final SimpleSqlEngine sqlEngine;
  bool _isUpdating = false;

  MysterySqlController({required this.sqlEngine, super.text}) {
    addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (_isUpdating) return;

    final currentText = text;
    if (currentText.isEmpty) return;

    // Use the shared smart formatter
    final transformed = SqlUtils.formatSql(currentText, TextRange.empty);

    if (transformed != currentText) {
      _isUpdating = true;
      final currentSelection = selection;
      final currentComposing = value.composing;
      
      value = value.copyWith(
        text: transformed,
        selection: currentSelection,
        composing: currentComposing,
      );
      _isUpdating = false;
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    // We can also force uppercase in the rendering here if we wanted, 
    // but the sqlEngine handles highlighting. 
    // Let's ensure the sqlEngine highlights case-insensitively.
    return sqlEngine.buildHighlightedSqlText(text, baseStyle: style);
  }

  @override
  void dispose() {
    removeListener(_handleTextChange);
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_colors.dart';

/// A [TextEditingController] that highlights SQL keywords and can show a ghost hint.
class SQLSyntaxController extends TextEditingController {
  String? _hintText;
  String? get hintText => _hintText;
  set hintText(String? value) {
    _hintText = value;
    notifyListeners();
  }

  SQLSyntaxController({super.text, String? hintText}) : _hintText = hintText;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> spans = [];

    // 1. Process existing text for syntax highlighting
    final regex = RegExp(
      r"(\bSELECT\b|\bFROM\b|\bWHERE\b|\bUPDATE\b|\bSET\b|\bCREATE\b|\bTABLE\b|\bINSERT\b|\bINTO\b|\bVALUES\b|\bbalance\b|\bname\b|\bdetails\b|\bid\b|\bclue\b|\*|\b\d+\b|'.*?')",
      caseSensitive: false,
    );

    const colorRed = Color(0xFFFD1F23);
    const colorGreen = Color(0xFF0EFF3B);
    const colorBlue = Color(0xFF3700FF);

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final String matchText = match[0]!;
        final String upperMatch = matchText.toUpperCase();
        Color color = style?.color ?? Colors.black;

        if (upperMatch == 'SELECT' ||
            upperMatch == 'FROM' ||
            upperMatch == 'UPDATE' ||
            upperMatch == 'SET' ||
            upperMatch == 'INSERT' ||
            upperMatch == 'INTO' ||
            upperMatch == 'VALUES') {
          color = (upperMatch == 'SELECT' || upperMatch == 'FROM' || upperMatch == 'UPDATE' || upperMatch == 'SET') 
              ? AppColors.sqlFromKeyword 
              : colorBlue;
        } else if (upperMatch == 'CREATE' || upperMatch == 'TABLE') {
          color = colorBlue;
        } else if (upperMatch == 'WHERE') {
          color = colorGreen;
        } else if (upperMatch == 'BALANCE' ||
            upperMatch == 'NAME' ||
            upperMatch == 'DETAILS' ||
            upperMatch == 'ID' ||
            upperMatch == 'CLUE' ||
            matchText.startsWith("'") ||
            RegExp(r'^\d+$').hasMatch(matchText)) {
          color = colorRed;
        } else if (matchText == '*') {
          color = AppColors.sqlStar;
        }

        spans.add(
          TextSpan(
            text: matchText,
            style: (style ?? const TextStyle()).copyWith(color: color),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: style));
        return '';
      },
    );

    // 2. Append ghost hint if text is shorter than hintText
    if (hintText != null && text.length < hintText!.length) {
      final String remainingHint = hintText!.substring(text.length);
      spans.add(
        TextSpan(
          text: remainingHint,
          style: (style ?? const TextStyle()).copyWith(
            color: Colors.grey.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return TextSpan(style: style, children: spans);
  }
}


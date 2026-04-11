import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_colors.dart';

/// A [TextEditingController] that highlights SQL keywords with syntax colors.
///
/// - SELECT → blue [AppColors.sqlSelectKeyword]
/// - *      → red  [AppColors.sqlStar]
/// - FROM   → purple [AppColors.sqlFromKeyword]
class SQLSyntaxController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'(\bSELECT\b)|(\*)|(\bFROM\b)', caseSensitive: false);

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final String matchText = match[0]!;
        final String upperMatch = matchText.toUpperCase();

        Color color = style?.color ?? Colors.black;
        if (upperMatch == 'SELECT') {
          color = AppColors.sqlSelectKeyword;
        } else if (matchText == '*') {
          color = AppColors.sqlStar;
        } else if (upperMatch == 'FROM') {
          color = AppColors.sqlFromKeyword;
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

    return TextSpan(style: style, children: spans);
  }
}

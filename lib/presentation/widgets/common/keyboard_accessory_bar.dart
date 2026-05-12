import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/core/utils/sql_utils.dart';

/// Custom controller that renders ghost/hint text inline with the user's input
/// by overriding [buildTextSpan].
///
/// Layout (single scrolling row):
///   [typed text ──────────────── cursor │ ghost hint continues →]
///
/// Flutter's single-line TextField automatically scrolls left so the cursor
/// stays visible. The ghost text is always rendered right after the cursor,
/// meaning it slides into view naturally as the user types.
class _GhostTextController extends TextEditingController {
  String? hintText;
  final TextStyle baseStyle;
  final Color ghostColor;

  _GhostTextController({
    required this.hintText,
    required this.baseStyle,
    required this.ghostColor,
    String? initialText,
  }) : super(text: initialText) {
    addListener(_handleTextChange);
  }

  bool _isUpdating = false;

  void _handleTextChange() {
    if (_isUpdating) return;
    final currentText = text;
    if (currentText.isEmpty) return;

    final transformed = SqlUtils.formatSql(currentText, TextRange.empty);
    if (transformed != currentText) {
      _isUpdating = true;
      value = value.copyWith(
        text: transformed,
        selection: selection,
        composing: value.composing,
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
    final String input = text;
    final String? hintRaw = hintText;
    final TextStyle resolved = style ?? baseStyle;
    final displayedInput = SqlUtils.formatSql(input, TextRange.empty);

    if (hintRaw == null) return TextSpan(style: resolved, text: displayedInput);

    // 1. Normalize both for a flexible "on track" check
    // We collapse all whitespace to single spaces and lowercase everything.
    String normInput = input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    String normHint = hintRaw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    // If the user has typed something that doesn't match the hint (ignoring whitespace/case),
    // we stop showing the ghost hint to avoid confusion.
    // We use trimRight() on input so that a trailing space doesn't break the match
    // if the hint doesn't have a space at that exact position yet.
    if (!normHint.startsWith(normInput.trimRight())) {
      return TextSpan(style: resolved, text: displayedInput);
    }

    // 2. Determine how much of the original hint to skip.
    // We walk through both strings, matching non-whitespace characters.
    int hintIdx = 0;
    int inputIdx = 0;
    while (inputIdx < input.length && hintIdx < hintRaw.length) {
      final String charIn = input[inputIdx];
      final String charHint = hintRaw[hintIdx];

      if (charIn.trim().isEmpty) {
        // User typed whitespace; skip all consecutive whitespace in both
        inputIdx++;
        while (hintIdx < hintRaw.length && hintRaw[hintIdx].trim().isEmpty) {
          hintIdx++;
        }
      } else if (charHint.trim().isEmpty) {
        // Hint has whitespace here but user hasn't typed it yet; skip it in hint
        hintIdx++;
      } else if (charIn.toLowerCase() == charHint.toLowerCase()) {
        // Characters match (case-insensitive); move both forward
        inputIdx++;
        hintIdx++;
      } else {
        // Real mismatch found during walk
        break;
      }
    }

    // 3. The ghost text is the remainder of the hint, with newlines replaced by spaces
    // for the single-line accessory bar display.
    if (hintIdx >= hintRaw.length) {
      return TextSpan(style: resolved, text: displayedInput);
    }

    final String ghost = hintRaw.substring(hintIdx).replaceAll('\n', ' ');

    return TextSpan(
      style: resolved,
      children: [
        TextSpan(
          text: displayedInput,
          style: resolved.copyWith(color: AppColors.primary),
        ),
        TextSpan(
          text: ghost,
          style: resolved.copyWith(color: ghostColor),
        ),
      ],
    );
  }
}

/// A floating accessory bar shown above the on-screen keyboard.
///
/// Displays a single scrolling line:
///   [typed text] [cursor] [ghost hint] … [DONE]
///
/// As the user types, Flutter scrolls the content so the cursor stays in view,
/// which causes the ghost text to shift left — always visible next to the cursor.
class KeyboardAccessoryBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final bool obscureText;
  final String? hintText;
  final bool isMultiline;

  const KeyboardAccessoryBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.textStyle,
    this.obscureText = false,
    this.hintText,
    this.isMultiline = false,
  });

  @override
  State<KeyboardAccessoryBar> createState() => _KeyboardAccessoryBarState();
}

class _KeyboardAccessoryBarState extends State<KeyboardAccessoryBar> {
  late FocusNode _internalFocus;
  late _GhostTextController _ghostController;

  TextStyle get _baseStyle =>
      widget.textStyle ??
      GoogleFonts.inconsolata(
        fontSize: 18,
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      );

  @override
  void initState() {
    super.initState();
    _internalFocus = FocusNode();

    _ghostController = _GhostTextController(
      hintText: widget.hintText,
      baseStyle: _baseStyle,
      ghostColor: AppColors.primary.withValues(alpha: 0.3),
      initialText: widget.controller.text,
    );

    widget.controller.addListener(_syncFromSource);
    _ghostController.addListener(_syncToSource);
    widget.focusNode?.addListener(_onMainFocusChange);

    if (widget.focusNode?.hasFocus ?? false) {
      _internalFocus.requestFocus();
    }
  }

  /// Source controller changed → mirror into ghost controller.
  void _syncFromSource() {
    if (_ghostController.text != widget.controller.text) {
      _ghostController.value = widget.controller.value;
    }
  }

  /// Ghost controller changed (user typed in bar) → mirror into source.
  void _syncToSource() {
    if (widget.controller.text != _ghostController.text) {
      widget.controller.value = _ghostController.value;
    }
  }

  void _onMainFocusChange() {
    if (mounted && (widget.focusNode?.hasFocus ?? false)) {
      _internalFocus.requestFocus();
    }
  }

  @override
  void didUpdateWidget(KeyboardAccessoryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hintText != widget.hintText) {
      _ghostController.hintText = widget.hintText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromSource);
    _ghostController.removeListener(_syncToSource);
    widget.focusNode?.removeListener(_onMainFocusChange);
    _internalFocus.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight <= 0) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: Listenable.merge([
        if (widget.focusNode != null) widget.focusNode!,
        _internalFocus,
      ]),
      builder: (context, _) {
        final bool hasFocus =
            (widget.focusNode?.hasFocus ?? true) || _internalFocus.hasFocus;
        if (!hasFocus) return const SizedBox.shrink();

        return Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenHeight = MediaQuery.of(context).size.height;
              // Automatically determine if parent stack is scaled by comparing screen height to stack max height
              final double scaleY = screenHeight > 0 && constraints.maxHeight > 0
                  ? (screenHeight / constraints.maxHeight)
                  : 1.0;
              final double localBottom = keyboardHeight / scaleY;

              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: localBottom),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: _ghostController,
                        focusNode: _internalFocus,
                        obscureText: widget.obscureText,
                        maxLines: widget.isMultiline ? null : 1,
                        keyboardType: widget.isMultiline ? TextInputType.multiline : TextInputType.text,
                        cursorColor: AppColors.primaryLight,
                        showCursor: true,
                        style: _baseStyle,
                        onChanged: (val) {
                          final formatted = SqlUtils.formatSql(val, TextRange.empty);
                          if (formatted != val) {
                            _ghostController.value = _ghostController.value.copyWith(
                              text: formatted,
                              selection: _ghostController.selection,
                            );
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                  ),
                  TextButton(
                    onPressed: () {
                      _internalFocus.unfocus();
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'DONE',
                      style: GoogleFonts.londrinaSolid(
                        color: AppColors.primaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_colors.dart';

/// A floating accessory bar that appears above the on-screen keyboard.
/// Shows the current text of the given [controller] and dismisses focus on Done.
class KeyboardAccessoryBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle? textStyle;

  const KeyboardAccessoryBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode ?? FocusNode(),
      builder: (context, child) {
        final bool hasFocus = focusNode?.hasFocus ?? true;
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        if (keyboardHeight <= 0 || !hasFocus) return const SizedBox.shrink();

        return Positioned(
          left: 0,
          right: 0,
          bottom: keyboardHeight,
          child: Material(
            color: AppColors.transparent,
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
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        return Text(
                          value.text,
                          style: textStyle ??
                              GoogleFonts.inconsolata(
                                fontSize: 18,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

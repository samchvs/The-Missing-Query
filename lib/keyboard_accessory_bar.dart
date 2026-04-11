import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart'; // For BouncingButton

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
      listenable: focusNode ?? FocusNode(), // Dummy if null
      builder: (context, child) {
        final bool hasFocus = focusNode?.hasFocus ?? true;
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        
        // Only show when keyboard is visible AND this field has focus (if focusNode provided)
        if (keyboardHeight <= 0 || !hasFocus) return const SizedBox.shrink();

        return Positioned(
      left: 0,
      right: 0,
      bottom: keyboardHeight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: const BoxDecoration(
            color: Colors.white,
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
                            color: const Color(0xFF542E2E),
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

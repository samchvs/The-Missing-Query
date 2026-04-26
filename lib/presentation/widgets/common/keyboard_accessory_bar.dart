import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_colors.dart';

/// A floating accessory bar that appears above the on-screen keyboard.
/// Shows the current text of the given [controller] and dismisses focus on Done.
class KeyboardAccessoryBar extends StatefulWidget {
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
  State<KeyboardAccessoryBar> createState() => _KeyboardAccessoryBarState();
}

class _KeyboardAccessoryBarState extends State<KeyboardAccessoryBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.controller.addListener(_scrollToEnd);
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      // Small delay to ensure the text is updated in the field
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollToEnd);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight <= 0) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: widget.focusNode ?? FocusNode(),
      builder: (context, child) {
        final bool hasFocus = widget.focusNode?.hasFocus ?? true;
        if (!hasFocus) return const SizedBox.shrink();

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
                    child: TextField(
                      controller: widget.controller,
                      scrollController: _scrollController,
                      maxLines: 1,
                      cursorColor: AppColors.primaryLight,
                      showCursor: true,
                      autofocus: false,
                      style: widget.textStyle ??
                          GoogleFonts.inconsolata(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    child: Text(
                      "DONE",
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
        );
      },
    );
  }
}

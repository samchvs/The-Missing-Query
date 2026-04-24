import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

class QueryTerminal extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRun;
  final VoidCallback onClear;
  final VoidCallback onShowTables;
  final VoidCallback onClose;
  final String? targetQuery;
  final double width;

  const QueryTerminal({
    super.key,
    required this.controller,
    required this.onRun,
    required this.onClear,
    required this.onShowTables,
    required this.onClose,
    this.targetQuery,
    this.width = 550,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Terminal Background
          Image.asset(AppAssets.tutorialQueryDisplay, width: width),

          // Text Area
          Positioned(
            top: 75,
            left: 45,
            right: 45,
            bottom: 80,
            child: Stack(
              children: [
                // Ghost Text (Hint)
                if (targetQuery != null)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      final String userInput = value.text;
                      String ghostText = '';
                      if (userInput.length < targetQuery!.length) {
                        ghostText = ' ' * userInput.length +
                            targetQuery!.substring(userInput.length);
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          ghostText,
                          style: GoogleFonts.inconsolata(
                            fontSize: 18,
                            color: Colors.grey.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                // User Input
                TextField(
                  controller: controller,
                  maxLines: null,
                  autofocus: true,
                  style: GoogleFonts.inconsolata(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),

          // Close Button (Upper Right)
          Positioned(
            top: 10,
            right: 15,
            child: BouncingButton(
              onPressed: onClose,
              child: Image.asset(AppAssets.closeBtn, width: 25),
            ),
          ),

          // Action Buttons (Bottom)
          Positioned(
            bottom: 5,
            left: 20,
            right: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: onShowTables,
                  child: Image.asset(AppAssets.tablesBtn, width: 110),
                ),
                const Spacer(),
                BouncingButton(
                  onPressed: onClear,
                  child: Image.asset(AppAssets.clearBtn, width: 90),
                ),
                const SizedBox(width: 12),
                BouncingButton(
                  onPressed: onRun,
                  child: Image.asset(AppAssets.runBtn, width: 120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

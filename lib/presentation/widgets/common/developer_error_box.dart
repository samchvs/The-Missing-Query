import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:graphics_project/core/config/supabase_config.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class DeveloperErrorBox extends StatelessWidget {
  const DeveloperErrorBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        // Only show this box in debug mode
        if (!SupabaseConfig.debugMode) {
          return const SizedBox.shrink();
        }

        final friendlyError = auth.errorMessage;
        final debugError = auth.debugErrorMessage;

        // If no error at all, stay hidden
        if (friendlyError == null && debugError == null) {
          return const SizedBox.shrink();
        }

        // Determine what to show based on debug mode
        final bool showDebug = debugError != null;
        final String displayMessage = (showDebug) ? debugError : friendlyError!;

        return Positioned(
          left: 20,
          bottom: 20,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: showDebug
                          ? Colors.redAccent.withValues(alpha: 0.5)
                          : Colors.orangeAccent.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            showDebug
                                ? Icons.bug_report_rounded
                                : Icons.error_outline_rounded,
                            color: showDebug
                                ? Colors.redAccent
                                : Colors.orangeAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            showDebug ? 'DEVELOPER DEBUG' : 'MESSAGE',
                            style: TextStyle(
                              color: showDebug
                                  ? Colors.redAccent.shade100
                                  : Colors.orangeAccent.shade100,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => auth.clearError(),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      Text(
                        displayMessage,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: showDebug ? 'monospace' : null,
                          height: 1.4,
                        ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showDebug && friendlyError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'User saw: "$friendlyError"',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


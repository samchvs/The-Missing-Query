import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case10_screen.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'dart:async';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

class TutorialCase9Screen extends StatefulWidget {
  const TutorialCase9Screen({super.key});

  @override
  State<TutorialCase9Screen> createState() => _TutorialCase9ScreenState();
}

class _TutorialCase9ScreenState extends State<TutorialCase9Screen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _showNotebook = false;
  bool _isNotebookTaskComplete = false;
  bool _isDiaryTableShown = false;
  bool _isTableUnlocked = false;
  bool _hasShownGuidePop8 = false;
  bool _showGuidePop8 = false;
  bool _showGuidePop9 = false;
  bool _showMyNotesDetails = false;
  bool _notebookOpenedOnce = false;
  bool _showGuidePop3 = false;
  bool _hasShownGuidePop3 = false;
  bool _showGuidePop1 = false;
  bool _hasShownGuidePop1 = false;
  bool _showNextButton = false;

  late SQLSyntaxController _queryController;
  final String _notebookTarget =
      "UPDATE My_Notes\nSET details = 'SCAN-98 belongs to Broccoliandro'\nWHERE id = 1;";

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _queryController = SQLSyntaxController(
      hintText: _notebookTarget,
      text: _notebookTarget, // DEBUG PREFILL
    );

    _queryController.addListener(() {
      if (_isNotebookTaskComplete) return;
      final String userInput = _queryController.text.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final String targetNormalized = _notebookTarget.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );

      if (userInput == targetNormalized ||
          userInput == targetNormalized.replaceAll(';', '')) {
        setState(() {
          _isNotebookTaskComplete = true;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showGuidePop9 = true;
        });
        _fadeController.forward();
      }
    });
  }

  void _validateAndRunQuery() {
    final String userInput = _queryController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final String targetNormalized = _notebookTarget.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    if (userInput == targetNormalized ||
        userInput == targetNormalized.replaceAll(';', '')) {
      setState(() {
        _isTableUnlocked = true;
        _isDiaryTableShown = true;
        if (!_hasShownGuidePop8) {
          _showGuidePop8 = true;
          _hasShownGuidePop8 = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Query successful! Table unlocked."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Query error: Please check your syntax!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 800,
                height: 360,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    Image.asset(
                      AppAssets.tutorialCase9Screen,
                      fit: BoxFit.fill,
                    ),

                    // Top UI Bar
                    Positioned(
                      top: 15,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          BouncingButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(AppAssets.backBtn, width: 55),
                          ),
                          const SizedBox(width: 10),
                          BouncingButton(
                            onPressed: () => TutorialMusicController.goHome(context),
                            child: Image.asset(AppAssets.homeBtn, width: 55),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Center CRUD Diary Icon
                    Positioned(
                      top: 20,
                      right: 260,
                      child: Center(
                        child: BouncingButton(
                          onPressed: () {
                            SFXController().playPopup();
                            setState(() {
                              _showNotebook = true;
                              _notebookOpenedOnce = true;
                              _showGuidePop9 = false;
                              if (!_hasShownGuidePop3) {
                                _showGuidePop3 = true;
                                _hasShownGuidePop3 = true;
                              }
                            });
                          },
                          child: Image.asset(AppAssets.notebookIcon, width: 40),
                        ),
                      ),
                    ),

                    // Next Button (Appears after guidepop1 is closed)
                    if (_showNextButton)
                      Positioned(
                        bottom: 20,
                        right: 30,
                        child: ShakeWidget(
                          delay: const Duration(milliseconds: 500),
                          child: BouncingButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const TutorialCase10Screen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) => child,
                                ),
                              ).then((_) {
                                // State is preserved when coming back from Case 10
                              });
                            },
                            child: Image.asset(AppAssets.nextBtn, width: 80),
                          ),
                        ),
                      ),

                    // Notebook Overlay
                    if (_showNotebook)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showNotebook = false),
                                child: Container(color: Colors.transparent),
                              ),
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 280,
                                      child: Image.asset(
                                        AppAssets.notebookLayout,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    // Text Area
                                    Positioned(
                                      top: 65,
                                      left: 55,
                                      right: 25,
                                      bottom: 60,
                                      child: TextField(
                                        controller: _queryController,
                                        maxLines: null,
                                        style: GoogleFonts.inconsolata(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          height: 1.5,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    // Close Button
                                    Positioned(
                                      top: 20,
                                      right: 30,
                                      child: BouncingButton(
                                        onPressed: () => setState(
                                          () => _showNotebook = false,
                                        ),
                                        child: Image.asset(
                                          AppAssets.closeBtn,
                                          width: 25,
                                        ),
                                      ),
                                    ),
                                    // Bottom Buttons
                                    Positioned(
                                      bottom: 25,
                                      left: 15,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          BouncingButton(
                                            onPressed: () {
                                              if (_isTableUnlocked) {
                                                setState(
                                                  () =>
                                                      _isDiaryTableShown = true,
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "No tables to show yet. Run your query successfully first!",
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Image.asset(
                                              AppAssets.tablesBtn,
                                              width: 60,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          BouncingButton(
                                            onPressed: () =>
                                                _queryController.clear(),
                                            child: Image.asset(
                                              AppAssets.clearBtn,
                                              width: 50,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          BouncingButton(
                                            onPressed: _validateAndRunQuery,
                                            child: Image.asset(
                                              AppAssets.runBtn,
                                              width: 65,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Third Guide Pop (Right of notebook)
                              if (_showGuidePop3)
                                Center(
                                  child: Transform.translate(
                                    offset: const Offset(200, 0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: Image.asset(
                                            AppAssets.tutorialCase8GuidePop3,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 15,
                                          child: BouncingButton(
                                            onPressed: () {
                                              setState(() {
                                                _showGuidePop3 = false;
                                              });
                                            },
                                            child: Image.asset(
                                              AppAssets.okayBtn,
                                              width: 70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // CRUD Diary Popup (Beanie's Tables)
          if (_isDiaryTableShown)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Container(
                    width: 500,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB347),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD38312),
                        width: 4,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1C1),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFD38312),
                              ),
                            ),
                            child: Text(
                              "CRUD DIARY",
                              style: GoogleFonts.londrinaSolid(
                                fontSize: 16,
                                color: const Color(0xFF542E2E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: BouncingButton(
                            onPressed: () =>
                                setState(() => _isDiaryTableShown = false),
                            child: Image.asset(AppAssets.closeBtn, width: 25),
                          ),
                        ),
                        Positioned(
                          top: 45,
                          left: 15,
                          right: 15,
                          bottom: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E0),
                              border: Border.all(
                                color: const Color(0xFFD38312),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: const Color(0xFFFFE194),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "BEANIE'S TABLES",
                                      style: GoogleFonts.londrinaSolid(
                                        fontSize: 18,
                                        color: const Color(0xFF542E2E),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  color: const Color(0xFFFFF1C1),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          "#",
                                          style: GoogleFonts.londrinaSolid(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "TABLE NAME",
                                            style: GoogleFonts.londrinaSolid(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      _buildDiaryRow(
                                        "1",
                                        "My_Notes",
                                        isDark: true,
                                        onTap: () => setState(() {
                                          _showMyNotesDetails = true;
                                          _isDiaryTableShown = false;
                                          _showNotebook = false;
                                          if (!_hasShownGuidePop1) {
                                            _showGuidePop1 = true;
                                            _hasShownGuidePop1 = true;
                                          }
                                        }),
                                      ),
                                      _buildDiaryRow("", "", isDark: false),
                                      _buildDiaryRow("", "", isDark: true),
                                      _buildDiaryRow("", "", isDark: false),
                                      _buildDiaryRow("", "", isDark: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Eighth Guide Pop (Right of CRUD Diary Table)
          if (_showGuidePop8)
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(240, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Image.asset(
                          AppAssets.tutorialCase8GuidePop8,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 25,
                        child: BouncingButton(
                          onPressed: () =>
                              setState(() => _showGuidePop8 = false),
                          child: Image.asset(AppAssets.okayBtn, width: 70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Keyboard accessory bar
          KeyboardAccessoryBar(controller: _queryController),

          // Guide Pop Image (Initial)
          if (_showGuidePop9 && !_notebookOpenedOnce)
            Positioned(
              right: 30,
              top: 80,
              child: SizedBox(
                width: 280,
                child: Image.asset(
                  AppAssets.tutorialCase8GuidePop,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // My_Notes Detail Popup
          if (_showMyNotesDetails)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AppAssets.case9Mynotes,
                        width: 500,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        top: 10,
                        right: 16,
                        child: BouncingButton(
                          onPressed: () =>
                              setState(() => _showMyNotesDetails = false),
                          child: Image.asset(AppAssets.closeBtn, width: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Guide Pop 1 (Right of My_Notes Detail)
          if (_showGuidePop1)
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(240, 70),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Image.asset(
                          AppAssets.case9GuidePop1,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 25,
                        child: BouncingButton(
                          onPressed: () => setState(() {
                            _showGuidePop1 = false;
                            _showMyNotesDetails = false;
                            _showNextButton = true;
                          }),
                          child: Image.asset(AppAssets.okayBtn, width: 70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


        ],
      ),
    );
  }

  Widget _buildDiaryRow(
    String index,
    String tableName, {
    required bool isDark,
    VoidCallback? onTap,
  }) {
    Widget rowContent = GestureDetector(
      onTap: onTap != null
          ? () {
              SFXController().playButton();
              onTap();
            }
          : null,
      child: Container(
        color: isDark ? const Color(0xFFFFE0B2) : const Color(0xFFFFF3E0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                index,
                style: GoogleFonts.inconsolata(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  tableName,
                  style: GoogleFonts.inconsolata(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return ShakeWidget(child: rowContent);
    }
    return rowContent;
  }
}


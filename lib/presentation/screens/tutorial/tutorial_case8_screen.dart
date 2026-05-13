import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/query_terminal.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case7_screen.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'dart:async';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

class TutorialCase8Screen extends StatefulWidget {
  const TutorialCase8Screen({super.key});

  @override
  State<TutorialCase8Screen> createState() => _TutorialCase8ScreenState();
}

class _TutorialCase8ScreenState extends State<TutorialCase8Screen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showContent = false;

  // Typewriter logic
  bool _showDialogue = false;
  bool _isTypingFinished = false;
  bool _showGuidePop = false;
  bool _showNotebook = false;
  bool _notebookOpenedOnce = false;
  bool _showGuidePop2 = false;
  bool _dismissedGuidePop2 = false;
  bool _isQueryClicked = false;
  String _typedText = "";
  final String _fullText =
      "My head is spinning! I should create a personal notebook so I don't forget the clues!";
  final String _notebookTarget =
      "CREATE TABLE My_Notes (\nid INT PRIMARY_KEY,\nclue VARCHAR(50),\ndetails VARCHAR(100)\n);";
  final String _notebookTarget2 =
      "INSERT INTO My_Notes (id, clue, details)\nVALUES (1, 'Transaction', 'SCAN-98 was successful.');";
  bool _showGuidePop3 = false;
  bool _isNotebookTaskComplete = false;
  bool _isDiaryTableShown = false;
  bool _showGuidePop4 = false;
  bool _showGuidePop5 = false;
  bool _showGuidePop6 = false;
  bool _showGuidePop7 = false;
  bool _showDeviceRegistry = false;
  bool _showGuidePop8 = false;
  bool _showGuidePop9 = false;
  bool _hasShownGuidePop4 = false;
  bool _hasShownGuidePop8 = false;
  bool _hasShownGuidePop9 = false;
  bool _dismissedGuidePop6 = false;
  bool _isTableCreated = false;
  bool _isTablePopulated = false;
  int _currentTaskIndex = 0;
  Timer? _typingTimer;
  late SQLSyntaxController _queryController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache assets for this screen and the next
    precacheImage(const AssetImage(AppAssets.tutorialCase8Screen), context);
    precacheImage(const AssetImage(AppAssets.tutorialCase7Screen), context);
    precacheImage(const AssetImage(AppAssets.nextBtn), context);
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _queryController = SQLSyntaxController(
      hintText: _notebookTarget,
      //text: "CREATE TABLE My_Notes (\nid INT PRIMARY_KEY,\nclue VARCHAR(50),\ndetails VARCHAR(100)\n);", // Debug pre-fill
    );

    _queryController.addListener(() {
      if (_isNotebookTaskComplete) return;

      final String currentTarget = _currentTaskIndex == 0
          ? _notebookTarget
          : _notebookTarget2;
      final String userInput = _queryController.text.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      final String targetNormalized = currentTarget.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );

      if (userInput == targetNormalized ||
          userInput == targetNormalized.replaceAll(';', '')) {
        setState(() {
          if (_currentTaskIndex == 0) {
            _showGuidePop3 = true;
          }
          _isNotebookTaskComplete = true;
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showContent = true);
        _fadeController.forward();
        _startTyping();
      }
    });
  }

  void _validateAndRunQuery() {
    final String currentTarget = _currentTaskIndex == 0
        ? _notebookTarget
        : _notebookTarget2;
    final String userInput = _queryController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final String targetNormalized = currentTarget.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    if (userInput == targetNormalized ||
        userInput == targetNormalized.replaceAll(';', '')) {
      setState(() {
        if (_currentTaskIndex == 0) {
          _isDiaryTableShown = true;
          _showGuidePop3 = false;
          _isTableCreated = true;

          if (!_hasShownGuidePop4) {
            _showGuidePop4 = true;
            _hasShownGuidePop4 = true;
          }
        } else {
          setState(() {
            _isDiaryTableShown = true;
            _isTablePopulated = true;
            if (!_hasShownGuidePop8) {
              _showGuidePop8 = true;
              _hasShownGuidePop8 = true;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Success! Clue saved to your notebook!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Query error: Please check your syntax in the notebook!",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    _typedText = "";
    _isTypingFinished = false;
    int charIndex = 0;

    setState(() {
      _showDialogue = true;
    });

    final vol = SFXController().volume;
    debugPrint("Playing Beanie dialogue in Tutorial Case 8 with volume: $vol");
    _audioPlayer.setVolume(vol);
    _audioPlayer.play(AssetSource(AppAssets.case8BeanieAudio), volume: vol);

    _typingTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (charIndex < _fullText.length) {
        if (mounted) {
          setState(() {
            _typedText += _fullText[charIndex];
          });
        }
        charIndex++;
      } else {
        _typingTimer?.cancel();
        if (mounted) {
          setState(() {
            _isTypingFinished = true;
          });
        }
      }
    });
  }

  void _dismissOverlay() {
    if (_isTypingFinished) {
      _fadeController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showContent = false;
            _showGuidePop = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typingTimer?.cancel();
    _queryController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: 800,
            height: 360,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppAssets.tutorialCase8Screen, fit: BoxFit.fill),

                // Next Button
                if (_hasShownGuidePop9)
                  Positioned(
                    bottom: 20,
                    right: 40,
                    child: ShakeWidget(
                      child: BouncingButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const TutorialCase7Screen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) => FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                            ),
                          ).then((_) {});
                        },
                        child: Image.asset(AppAssets.nextBtn, width: 100),
                      ),
                    ),
                  ),

                if (_showGuidePop && !_notebookOpenedOnce)
                  Positioned(
                    right: 30,
                    top: 80,
                    child: Image.asset(
                      AppAssets.tutorialCase8GuidePop,
                      width: 300,
                      fit: BoxFit.fill,
                    ),
                  ),

                // Navigation Buttons
                Positioned(
                  left: 20,
                  top: 20,
                  child: Row(
                    children: [
                      BouncingButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(AppAssets.backBtn, width: 50),
                      ),
                      const SizedBox(width: 15),
                      BouncingButton(
                        onPressed: () =>
                            TutorialMusicController.goHome(context),
                        child: Image.asset(AppAssets.homeBtn, width: 50),
                      ),
                    ],
                  ),
                ),
                Positioned(top: 25, right: 260, child: _buildNotebookButton()),

                if (_showContent)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: _dismissOverlay,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        children: [
                          Container(color: Colors.black.withValues(alpha: 0.7)),
                          Positioned(
                            right: 180,
                            bottom: 10,
                            child: AppAnimations.spinningBeanie(width: 250),
                          ),

                          // Chat Icon
                          Center(
                            child: Transform.translate(
                              offset: const Offset(-90, -80),
                              child: BouncingButton(
                                onPressed: () {
                                  if (_isTypingFinished) _dismissOverlay();
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      AppAssets.chatIcon,
                                      width: 250,
                                      fit: BoxFit.fill,
                                    ),
                                    if (_showDialogue)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 35,
                                        ),
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(
                                            _typedText,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.londrinaSolid(
                                              fontSize: 17,
                                              color: const Color(0xFF4A2C2A),
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // SQL Terminal
                if (_isQueryClicked)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isQueryClicked = false),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                        QueryTerminal(
                          controller: _queryController,
                          onRun: () {},
                          onClear: () => _queryController.clear(),
                          onShowTables: () {},
                          onClose: () =>
                              setState(() => _isQueryClicked = false),
                        ),
                      ],
                    ),
                  ),

                // Notebook Layout
                if (_showNotebook && !_isDiaryTableShown)
                  Positioned.fill(
                    child: Builder(
                      builder: (context) {
                        final double keyboardHeight = MediaQuery.of(
                          context,
                        ).viewInsets.bottom;
                        final bool isKeyboardOpen = keyboardHeight > 0;

                        return Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showNotebook = false),
                                child: Container(color: Colors.transparent),
                              ),
                              Center(
                                child: Transform.translate(
                                  offset: Offset(
                                    -80,
                                    isKeyboardOpen ? -85.0 : 0.0,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 280,
                                        child: Image.asset(
                                          AppAssets.notebookLayout,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
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
                                      // Bottom buttons
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
                                                setState(
                                                  () => _isDiaryTableShown =
                                                      true,
                                                );
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
                              ),
                              if (_showGuidePop2)
                                Center(
                                  child: Transform.translate(
                                    offset: const Offset(200, 0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: Image.asset(
                                            AppAssets.tutorialCase8GuidePop2,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 15,
                                          child: BouncingButton(
                                            onPressed: () {
                                              setState(() {
                                                _showGuidePop2 = false;
                                                _dismissedGuidePop2 = true;
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
                                            fit: BoxFit.fill,
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
                              if (_showGuidePop6)
                                Center(
                                  child: Transform.translate(
                                    offset: const Offset(200, 0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: Image.asset(
                                            AppAssets.tutorialCase8GuidePop6,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 25,
                                          child: BouncingButton(
                                            onPressed: () {
                                              setState(() {
                                                _showGuidePop6 = false;
                                                _showGuidePop7 = true;
                                                _dismissedGuidePop6 = true;
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
                              if (_showGuidePop7)
                                Center(
                                  child: Transform.translate(
                                    offset: const Offset(200, 0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: Image.asset(
                                            AppAssets.tutorialCase8GuidePop7,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          child: BouncingButton(
                                            onPressed: () {
                                              setState(() {
                                                _showGuidePop7 = false;
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
                        );
                      },
                    ),
                  ),
                KeyboardAccessoryBar(
                  controller: _queryController,
                  hintText: _currentTaskIndex == 0
                      ? _notebookTarget
                      : _notebookTarget2,
                ),

                // CRUD Diary
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
                              // Close Button
                              Positioned(
                                top: 5,
                                right: 10,
                                child: BouncingButton(
                                  onPressed: () => setState(
                                    () => _isDiaryTableShown = false,
                                  ),
                                  child: Image.asset(
                                    AppAssets.closeBtn,
                                    width: 35,
                                  ),
                                ),
                              ),
                              // Main Content Area
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
                                                style:
                                                    GoogleFonts.londrinaSolid(
                                                      fontSize: 16,
                                                    ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "TABLE NAME",
                                                  style:
                                                      GoogleFonts.londrinaSolid(
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
                                              _isTableCreated ? "1" : "",
                                              _isTableCreated ? "My_Notes" : "",
                                              isDark: true,
                                              onTap: _isTablePopulated
                                                  ? () => setState(() {
                                                      _showDeviceRegistry =
                                                          true;
                                                      _isDiaryTableShown =
                                                          false;
                                                      _showNotebook = false;
                                                      if (!_hasShownGuidePop9) {
                                                        _showGuidePop9 = true;
                                                        _hasShownGuidePop9 =
                                                            true;
                                                      }
                                                    })
                                                  : null,
                                            ),
                                            _buildDiaryRow(
                                              "",
                                              "",
                                              isDark: false,
                                            ),
                                            _buildDiaryRow(
                                              "",
                                              "",
                                              isDark: true,
                                            ),
                                            _buildDiaryRow(
                                              "",
                                              "",
                                              isDark: false,
                                            ),
                                            _buildDiaryRow(
                                              "",
                                              "",
                                              isDark: true,
                                            ),
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
                if (_showGuidePop4)
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
                                AppAssets.tutorialCase8GuidePop4,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              child: BouncingButton(
                                onPressed: () {
                                  setState(() {
                                    _showGuidePop4 = false;
                                    _showGuidePop5 = true;
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
                  ),
                if (_showGuidePop5)
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
                                AppAssets.tutorialCase8GuidePop5,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              child: BouncingButton(
                                onPressed: () {
                                  setState(() {
                                    _showGuidePop5 = false;
                                    _showNotebook = false;
                                    _queryController.clear();
                                    /*_queryController.text =
                                        _notebookTarget2; // Debug pre-fill */
                                    _queryController.hintText =
                                        _notebookTarget2;
                                    _isNotebookTaskComplete = false;
                                    _currentTaskIndex = 1;
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
                  ),
                if (_showDeviceRegistry)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 500,
                              child: Image.asset(
                                AppAssets.tutorialCase8DeviceRegistry,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: BouncingButton(
                                onPressed: () =>
                                    setState(() => _showDeviceRegistry = false),
                                child: Image.asset(
                                  AppAssets.closeBtn,
                                  width: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              left: 150,
                              bottom: 15,
                              child: BouncingButton(
                                onPressed: () =>
                                    setState(() => _showGuidePop8 = false),
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
                  ),
                if (_showGuidePop9)
                  Positioned.fill(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(250, 80),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              child: Image.asset(
                                AppAssets.tutorialCase9GuidePop9,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              child: BouncingButton(
                                onPressed: () {
                                  setState(() => _showGuidePop9 = false);
                                },
                                child: Image.asset(
                                  AppAssets.okayBtn,
                                  width: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookButton() {
    final button = BouncingButton(
      onPressed: () {
        SFXController().playPopup();
        setState(() {
          _showNotebook = true;
          _notebookOpenedOnce = true;
          if (!_dismissedGuidePop2 && _currentTaskIndex == 0) {
            _showGuidePop2 = true;
          }
          if (!_dismissedGuidePop6 && _currentTaskIndex == 1) {
            _showGuidePop6 = true;
          }
        });
      },
      child: Image.asset(AppAssets.notebookIcon, width: 40),
    );
    if (_showGuidePop && !_notebookOpenedOnce) {
      return ShakeWidget(child: button);
    }
    return button;
  }

  Widget _buildDiaryRow(
    String index,
    String name, {
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
        width: double.infinity,
        color: isDark
            ? const Color(0xFFFFE194).withValues(alpha: 0.6)
            : const Color(0xFFFFF1C1),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                index,
                style: GoogleFonts.inconsolata(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  name,
                  style: GoogleFonts.inconsolata(
                    fontSize: 16,
                    color: Colors.black,
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

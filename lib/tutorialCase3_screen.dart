import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

class TutorialCase3Screen extends StatefulWidget {
  const TutorialCase3Screen({super.key});

  @override
  State<TutorialCase3Screen> createState() => _TutorialCase3ScreenState();
}

class _TutorialCase3ScreenState extends State<TutorialCase3Screen>
    with TickerProviderStateMixin {
  static const String _targetQuery = 'SELECT * FROM Hallway_Logs;';
  final List<Map<String, String>> _tableData = const [
    {'id': '101', 'name': 'Beanie', 'time': '11:55'},
    {'id': '102', 'name': 'Professor Hall', 'time': '12:01'},
    {'id': '103', 'name': 'Carrotino', 'time': '12:05'},
    {'id': '104', 'name': 'Broccoliandro', 'time': '12:05'},
    {'id': '105', 'name': 'Tomathomas', 'time': '12:05'},
  ];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  late AnimationController _spriteController;

  late AnimationController _hintController;
  late Animation<double> _hintOpacity;
  late Animation<Offset> _hintOffset;
  late Animation<double> _hintScale;

  bool _isQueryClicked = false;
  bool _hintMarkedAsDone = false;
  late AnimationController _userFadeController;
  late Animation<double> _userFadeAnimation;

  late AnimationController _popupUserFadeController;
  late Animation<double> _popupUserFadeAnimation;

  late SQLSyntaxController _queryController;
  bool _isHintDismissed = false;

  late AnimationController _runHintController;
  late Animation<Offset> _runHintOffset;
  late Animation<double> _runHintOpacity;
  late Animation<double> _runHintScale;
  bool _isRunHintFinished = false;
  bool _showQueryDisplay = true;
  bool _isTableShown = false;

  @override
  void initState() {
    super.initState();
    // Fade controller for tutorialCase3-pop
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2500, //Speed ng entry ni Beanie
      ),
    );

    // Moves from off-screen left to target position
    _walkAnimation = Tween<double>(
      begin: -0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));

    // Start walk animation immediately
    _walkController.forward();

    // Controller sa pagwalk/pagpalit ng frames
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // Listener pagstop ni Beanie fade in ng tutorialCase3-pop
    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spriteController.stop();
        if (mounted) {
          _fadeController.forward();
          setState(() {});
        }
      }
    });

    // Mouse pointer
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _hintOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_hintController);

    //Position saan maggglide yung pointer
    _hintOffset = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween(const Offset(0, 40)), weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 40), end: const Offset(20, -90)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween(const Offset(20, -90)),
        weight: 40,
      ),
    ]).animate(_hintController);

    _hintScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 15),
    ]).animate(_hintController);

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isQueryClicked) {
        _hintController.repeat();
      }
    });

    // Fade controller for the userDisplay
    _userFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _userFadeAnimation = CurvedAnimation(
      parent: _userFadeController,
      curve: Curves.easeIn,
    );

    _popupUserFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _popupUserFadeAnimation = CurvedAnimation(
      parent: _popupUserFadeController,
      curve: Curves.easeIn,
    );

    // Sequence the popup user display to fade in after the main display
    _userFadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _popupUserFadeController.forward();
      }
    });

    _queryController = SQLSyntaxController();

    _runHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _runHintOffset =
        TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0, 100), end: const Offset(0, 0)),
            weight: 25, // Slide up
          ),
          TweenSequenceItem(
            tween: ConstantTween(const Offset(0, 0)),
            weight: 60, // STAY Still (Point)
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0, 0), end: const Offset(0, 0)),
            weight: 15, // Dwell before fade
          ),
        ]).animate(
          CurvedAnimation(parent: _runHintController, curve: Curves.easeInOut),
        );

    _runHintOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_runHintController);

    _runHintScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30), // Slide up
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.8),
        weight: 15,
      ), // Press down
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.0),
        weight: 15,
      ), // Release
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40), // Stay still
    ]).animate(_runHintController);

    _queryController.addListener(() {
      final text = _queryController.text.trim();
      if (text.length == _targetQuery.length) {
        // Keywords (SELECT * FROM ) - Case insensitive
        final textPart1 = text.substring(0, 14).toUpperCase();
        final targetPart1 = _targetQuery.substring(0, 14).toUpperCase();
        // Table (Hallway_Logs;) - Case sensitive
        final textPart2 = text.substring(14);
        final targetPart2 = _targetQuery.substring(14);

        if (textPart1 == targetPart1 &&
            textPart2 == targetPart2 &&
            !_runHintController.isAnimating &&
            !_isRunHintFinished) {
          _runHintController.repeat();
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _walkController.dispose();
    _spriteController.dispose();
    _hintController.dispose();
    _userFadeController.dispose();
    _popupUserFadeController.dispose();
    _queryController.dispose();
    _runHintController.dispose();
    super.dispose();
  }

  bool _isQueryCorrect() {
    final text = _queryController.text.trim();
    if (text.length != _targetQuery.length) return false;

    // Keywords (SELECT * FROM ) - Case insensitive
    final textPart1 = text.substring(0, 14).toUpperCase();
    final targetPart1 = _targetQuery.substring(0, 14).toUpperCase();
    // Table (Hallway_Logs;) - Case sensitive
    final textPart2 = text.substring(14);
    final targetPart2 = _targetQuery.substring(14);

    return textPart1 == targetPart1 && textPart2 == targetPart2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/tutorialCase3_screen.png', fit: BoxFit.fill),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset('assets/tutorialCase3-title.png', width: 420),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(
                            20.0,
                            -10.0,
                          ), // Nudge right and up
                          child: BouncingButton(
                            onPressed: () {
                              debugPrint(
                                'Query button pressed in TutorialCase3!',
                              );
                              if (!_isQueryClicked) {
                                setState(() {
                                  _isQueryClicked = true;
                                  _hintMarkedAsDone = true;
                                  _isHintDismissed = false;
                                });
                                _hintController.stop();
                                _userFadeController.forward();
                              }
                            },
                            child: Image.asset(
                              'assets/query-btn.png',
                              width: 100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: _isQueryClicked ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 600),
                          child: Image.asset(
                            'assets/tutorialCase3-pop.png',
                            width: 250,
                          ),
                        ),
                      ],
                    ),
                    // Mouse pointer hint
                    AnimatedBuilder(
                      animation: _hintController,
                      builder: (context, child) {
                        return AnimatedOpacity(
                          opacity: _hintMarkedAsDone ? 0.0 : _hintOpacity.value,
                          duration: const Duration(milliseconds: 500),
                          child: Transform.translate(
                            offset: _hintOffset.value,
                            child: Transform.scale(
                              scale: _hintScale.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Image.asset('assets/mousePointer.png', width: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // sadBeanie
          AnimatedBuilder(
            animation: _walkAnimation,
            builder: (context, child) {
              final double screenWidth = MediaQuery.of(context).size.width;
              // We calculate the arrival position based on screen width
              final double walkTranslation = _walkAnimation.value * screenWidth;

              return Transform.translate(
                offset: Offset(walkTranslation, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.135,
                      top: 90.0,
                    ),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: AnimatedBuilder(
                        animation: _spriteController,
                        builder: (context, child) {
                          String currentImage;
                          double imageWidth;
                          if (_walkController.isCompleted) {
                            currentImage = 'assets/sadBeanie.png';
                            imageWidth = 150;
                          } else {
                            currentImage = _spriteController.value < 0.5
                                ? 'assets/BeanieWalking1.png'
                                : 'assets/BeanieWalking2.png';
                            imageWidth = 70;
                          }
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Transform.translate(
                              offset: Offset(
                                -25.0, // Consistent offset to align with shadow center
                                _walkController.isCompleted
                                    ? 0
                                    : -15 +
                                          (Curves.easeInOut.transform(
                                                (_spriteController.value * 2) %
                                                    1.0,
                                              ) *
                                              10),
                              ),
                              child: Image.asset(
                                currentImage,
                                width: imageWidth,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Dark overlay for focus
          IgnorePointer(
            ignoring: !_isQueryClicked,
            child: FadeTransition(
              opacity: _userFadeAnimation,
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),

          // tutorialQuery-display.png that appears after click
          IgnorePointer(
            ignoring: !_isQueryClicked,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0),
                child: IgnorePointer(
                  ignoring: !_showQueryDisplay,
                  child: AnimatedOpacity(
                    opacity: _showQueryDisplay ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: FadeTransition(
                      opacity: _userFadeAnimation,
                      child: Stack(
                        alignment: Alignment.topRight,
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'assets/tutorialQuery-display.png',
                            width: 450,
                          ),
                          // Query Input Field - completely hidden until hint is dismissed
                          Visibility(
                            visible: _isHintDismissed,
                            child: Positioned(
                              top: 55,
                              left: 25,
                              right: 25,
                              bottom: 45,
                              child: Stack(
                                children: [
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: _queryController,
                                    builder: (context, value, _) {
                                      final String userInput = value.text;
                                      String ghostText = '';

                                      if (userInput.length <
                                          _targetQuery.length) {
                                        // Create a string of spaces for matched length,
                                        // followed by the remaining hint portion.
                                        final spaces = ' ' * userInput.length;
                                        ghostText =
                                            spaces +
                                            _targetQuery.substring(
                                              userInput.length,
                                            );
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          ghostText,
                                          style: GoogleFonts.inconsolata(
                                            fontSize: 18,
                                            color: const Color(
                                              0xFF542E2E,
                                            ).withOpacity(0.3),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  TextField(
                                    controller: _queryController,
                                    maxLines: null,
                                    style: GoogleFonts.inconsolata(
                                      fontSize: 18,
                                      color: const Color(0xFF542E2E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 9,
                            right: 25,
                            child: BouncingButton(
                              onPressed: () {
                                _popupUserFadeController.reverse();
                                _userFadeController.reverse().then((_) {
                                  if (mounted) {
                                    setState(() {
                                      _isQueryClicked = false;
                                      _isHintDismissed = false;
                                      _runHintController.reset();
                                      _isRunHintFinished = false;
                                    });
                                  }
                                });
                              },
                              child: Image.asset(
                                'assets/close-btn.png',
                                width: 20,
                              ),
                            ),
                          ),
                          // Tables button
                          Positioned(
                            bottom: 5,
                            left: 15,
                            child: BouncingButton(
                              onPressed: () {
                                debugPrint('Tables button pressed');
                                if (_isQueryCorrect()) {
                                  setState(() {
                                    _showQueryDisplay = false;
                                    _isTableShown = true;
                                  });
                                } else {
                                  debugPrint(
                                    'Query incorrect: Tables button blocked',
                                  );
                                }
                              },
                              child: Image.asset(
                                'assets/tables-btn.png',
                                width: 80,
                              ),
                            ),
                          ),
                          // Clear and Run Query buttons
                          Positioned(
                            bottom: 5,
                            right: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BouncingButton(
                                  onPressed: () {
                                    debugPrint('Clear button pressed');
                                    _queryController.clear();
                                  },
                                  child: Image.asset(
                                    'assets/clear-btn.png',
                                    width: 75,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                BouncingButton(
                                  onPressed: () {
                                    debugPrint('Run button pressed');
                                    if (_isQueryCorrect()) {
                                      setState(() {
                                        _isRunHintFinished = true;
                                        _showQueryDisplay = false;
                                        _isTableShown = true;
                                      });
                                    } else {
                                      debugPrint(
                                        'Query incorrect: Run button blocked',
                                      );
                                      _runHintController.stop();
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/run-btn.png',
                                    width: 100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Sequenced userDisplay - bottom middle-right area
                          Positioned(
                            top: 60,
                            right: -30,
                            child: FadeTransition(
                              opacity: _popupUserFadeAnimation,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/tutorialSelectHint-box.png',
                                    width: 300,
                                  ),
                                  // Okay Button
                                  Positioned(
                                    bottom: 20,
                                    right: 35,
                                    child: BouncingButton(
                                      onPressed: () {
                                        _popupUserFadeController.reverse().then(
                                          (_) {
                                            if (mounted) {
                                              setState(() {
                                                _isHintDismissed = true;
                                              });
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        color: Colors.transparent,
                                        child: Image.asset(
                                          'assets/okay-btn.png',
                                          width: 75,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Second mouse pointer hint (Run Query)
                          Positioned(
                            bottom: -2,
                            right: 80,
                            child: AnimatedBuilder(
                              animation: _runHintController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _isRunHintFinished
                                      ? 0.0
                                      : _runHintOpacity.value,
                                  child: Transform.translate(
                                    offset: _runHintOffset.value,
                                    child: Transform.scale(
                                      scale: _runHintScale.value,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Image.asset(
                                'assets/mousePointer.png',
                                width: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // tutorialTable.png centered on screen
          IgnorePointer(
            ignoring: !_isTableShown,
            child: AnimatedOpacity(
              opacity: _isTableShown ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset('assets/tutorialTable.png', width: 500),
                    // Table Data Overlay
                    Positioned(
                      top: 105,
                      left: 23,
                      right: 21,
                      child: Column(
                        children: _tableData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final bool isLast = index == _tableData.length - 1;

                          return Container(
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFECECBE),
                                        width: 1.5,
                                      ),
                                    ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    data['id']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inconsolata(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF542E2E),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 60.0),
                                    child: Text(
                                      data['name']!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inconsolata(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF542E2E),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    child: Text(
                                      data['time']!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inconsolata(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF542E2E),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: BouncingButton(
                        onPressed: () {
                          debugPrint('Close button clicked');
                          setState(() {
                            _isTableShown = false;
                            _isQueryClicked = false;
                            _showQueryDisplay =
                                true; // reset for next time if needed
                          });
                          _userFadeController.reverse();
                        },
                        child: Image.asset('assets/close-btn.png', width: 25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () => Navigator.pop(context),
                  child: Image.asset('assets/back-btn.png', width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    debugPrint('Home button pressed in TutorialCase3!');
                    Navigator.of(
                      context,
                    ).popUntil(ModalRoute.withName('/home'));
                  },
                  child: Image.asset('assets/home-btn.png', width: 50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SQLSyntaxController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> spans = [];

    // Regex to match SELECT, *, FROM (case-insensitive for keywords)
    final regex = RegExp(r'(\bSELECT\b)|(\*)|(\bFROM\b)', caseSensitive: false);

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        String matchText = match[0]!;
        Color color = style?.color ?? Colors.black;

        final upperMatch = matchText.toUpperCase();
        if (upperMatch == 'SELECT') {
          color = const Color(0xFF3700FF);
        } else if (matchText == '*') {
          color = const Color(0xFFFF0000);
        } else if (upperMatch == 'FROM') {
          color = const Color(0xFF7700FF);
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

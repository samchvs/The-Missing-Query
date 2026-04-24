import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case6_screen.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case8_screen.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case9_screen.dart';
import 'dart:async';

class TutorialCase7Screen extends StatefulWidget {
  const TutorialCase7Screen({super.key});

  @override
  State<TutorialCase7Screen> createState() => _TutorialCase7ScreenState();
}

class _TutorialCase7ScreenState extends State<TutorialCase7Screen>
    with TickerProviderStateMixin {
  final List<String> _targets = [
    "SELECT student_name FROM Device_Registry WHERE mac_address = '00:1A:2B:3C';",
  ];
  int _currentStepIndex = 0;
  String get _targetQuery => _targets[_currentStepIndex];

  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  bool _isWalking = true;

  bool _isOverlayShown = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Query Panel States
  bool _isQueryClicked = false;
  bool _isHintDismissed = false;
  bool _isTableShown = false;

  bool _isQuerySuccessful = false;
  bool _isRegistryShown = false;
  bool _isRegistryGuideShown = false;
  bool _isUpdateSuccessShown = false;
  String? _errorMessage;
  Timer? _errorTimer;

  late SQLSyntaxController _queryController;

  // Typewriter logic
  String _typedText = "";
  final String _fullText =
      "Beanie goes to the Campus Security Office to file a report. He matched the MAC address from the tablet to a student.";
  Timer? _typingTimer;

  bool _isQueryBtnShown = false;
  bool _isTypingFinished = false;
  bool _isWaitingForGuide = false; // New flag for UI lock
  late AnimationController _queryFadeController;
  late Animation<double> _queryFadeAnimation;

  @override
  void initState() {
    super.initState();

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _walkAnimation = Tween<double>(
      begin: -0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _queryController = SQLSyntaxController(
      hintText: _targetQuery,
      text: "SELECT student_name FROM Device_Registry WHERE mac_address = '00:1A:2B:3C';", // Debug pre-fill
    );

    _queryFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _queryFadeAnimation = CurvedAnimation(
      parent: _queryFadeController,
      curve: Curves.easeIn,
    );

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startTyping();
      }
    });

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isWalking = false;
          });

          // Show overlay after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isOverlayShown = true;
              });
              _fadeController.forward();
            }
          });
        }
      }
    });

    _walkController.forward();
  }

  void _hideQuery() {
    FocusScope.of(context).unfocus();
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isQueryClicked = false;
          _isTableShown = false;
        });
      }
    });
  }

  void _validateQuery() {
    final String userInput = _queryController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
    final String target = _targetQuery.trim().toLowerCase().replaceAll(
      RegExp(r'[\s\n]+'),
      ' ',
    );

    final bool isMatch =
        userInput == target || userInput == target.replaceAll(';', '');

    if (isMatch) {
      setState(() {
        _isQuerySuccessful = true;
        _isRegistryShown = true;
        _isRegistryGuideShown = false; // Keep hidden initially
        _isWaitingForGuide = true; // Lock UI during transition
        _isQueryClicked = false;
      });

      // Delay the guide pop-up by 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isRegistryGuideShown = true;
            _isWaitingForGuide = false; // Unlock UI
          });
        }
      });
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect query. Try checking the hint!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startTyping() {
    int charIndex = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
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

  @override
  void dispose() {
    _walkController.dispose();
    _fadeController.dispose();
    _queryFadeController.dispose();
    _queryController.dispose();
    _typingTimer?.cancel();
    _errorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.tutorialCase7Screen, fit: BoxFit.fill),

          // Beanie Animation
          AnimatedBuilder(
            animation: _walkAnimation,
            builder: (context, child) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double walkTranslation = _walkAnimation.value * screenWidth;
              return Positioned(
                left: (screenWidth * 0.135) + walkTranslation,
                bottom: _isWalking ? 12 : -30,
                child: Container(
                  width: 220, // Exactly like Case 6
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Opacity(
                        opacity: _isWalking ? 1.0 : 0.0,
                        child: AppAnimations.walkingBeanie(width: 80),
                      ),
                      Opacity(
                        opacity: _isWalking ? 0.0 : 1.0,
                        child: AppAnimations.worriedBeanie(width: 220),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TutorialCase8Screen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                child,
                      ),
                    );
                  },
                  child: Image.asset(AppAssets.backBtn, width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Image.asset(AppAssets.homeBtn, width: 50),
                ),
              ],
            ),
          ),

          if (_isOverlayShown)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_isTypingFinished) return;
                      _fadeController.reverse().then((_) {
                        if (mounted) {
                          setState(() {
                            _isOverlayShown = false;
                            _isQueryBtnShown = true;
                          });
                          _queryFadeController.forward();
                        }
                      });
                    },
                    child: Container(color: Colors.black.withOpacity(0.7)),
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(AppAssets.tutorialDisplay, width: 500),
                        Positioned(
                          left: 60,
                          right: 60,
                          top: 40,
                          bottom: 40,
                          child: Center(
                            child: Text(
                              _typedText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.londrinaSolid(
                                fontSize: 18,
                                color: Color(0xFF542E2E),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 120,
            child: FadeTransition(
              opacity: _queryFadeAnimation,
              child: BouncingButton(
                onPressed: () {
                  setState(() => _isQueryClicked = true);
                  _fadeController.forward();
                },
                child: Image.asset(AppAssets.queryBtn, width: 100),
              ),
            ),
          ),

          if (_isQueryClicked || _isTableShown)
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: () {
                  if (_isTableShown) {
                    setState(() => _isTableShown = false);
                  } else {
                    _hideQuery();
                  }
                },
                child: Container(color: Colors.black.withOpacity(0.7)),
              ),
            ),

          if (_isQueryClicked && !_isTableShown)
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(AppAssets.tutorialQueryDisplay, width: 550),

                  if (_isHintDismissed)
                    Positioned(
                      top: 75,
                      left: 45,
                      right: 45,
                      bottom: 80,
                      child: TextField(
                        controller: _queryController,
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
                    ),

                  Positioned(
                    top: 10,
                    right: 15,
                    child: BouncingButton(
                      onPressed: _hideQuery,
                      child: Image.asset(AppAssets.closeBtn, width: 25),
                    ),
                  ),

                  if (_isHintDismissed)
                    Positioned(
                      bottom: 5,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          BouncingButton(
                            onPressed: () {
                              if (_isQuerySuccessful) {
                                setState(() {
                                  _isTableShown = true;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Table is locked. Run your query successfully first!",
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Image.asset(AppAssets.tablesBtn, width: 110),
                          ),
                          const Spacer(),
                          BouncingButton(
                            onPressed: () => _queryController.clear(),
                            child: Image.asset(AppAssets.clearBtn, width: 90),
                          ),
                          const SizedBox(width: 12),
                          BouncingButton(
                            onPressed: _validateQuery,
                            child: Image.asset(AppAssets.runBtn, width: 120),
                          ),
                        ],
                      ),
                    ),

                  if (!_isHintDismissed && _currentStepIndex == 0)
                    Positioned(
                      top: 80,
                      right: -40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            AppAssets.tutorial7SelectHintBox,
                            width: 320,
                          ),
                          Positioned(
                            bottom: 20,
                            right: 55,
                            child: BouncingButton(
                              onPressed: () {
                                setState(() => _isHintDismissed = true);
                              },
                              child: Image.asset(AppAssets.okayBtn, width: 85),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          if (_isTableShown)
            Center(
              child: SizedBox(
                width: 670,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      AppAssets.deviceRegistry,
                      width: 550,
                    ),

                    Positioned(
                      top: 10,
                      right: 70,
                      child: BouncingButton(
                        onPressed: () {
                          setState(() => _isTableShown = false);
                        },
                        child: Image.asset(AppAssets.closeBtn, width: 35),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_isQueryClicked && _isHintDismissed && !_isTableShown)
            KeyboardAccessoryBar(controller: _queryController),

          // Device Registry Popup
          if (_isRegistryShown)
            AbsorbPointer(
              absorbing: _isWaitingForGuide,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isRegistryShown = false),
                    child: Container(color: Colors.black.withOpacity(0.7)),
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(AppAssets.deviceRegistry, width: 550),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: BouncingButton(
                            onPressed: () =>
                                setState(() => _isRegistryShown = false),
                            child: Image.asset(AppAssets.closeBtn, width: 35),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Guide Pop in front of Device Registry
                if (_isRegistryGuideShown)
                  Stack(
                    children: [
                      Container(color: Colors.black.withOpacity(0.5)),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              AppAssets.tutorial7GuidePop,
                              width: 350,
                            ),
                            Positioned(
                              bottom: 30,
                              right: 50,
                              child: BouncingButton(
                                onPressed: () {
                                  setState(() {
                                    _isRegistryGuideShown = false;
                                    _isRegistryShown = false;
                                  });
                                  // Navigate to Case 9 after finishing Case 7
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          const TutorialCase9Screen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                          child,
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  AppAssets.okayBtn,
                                  width: 65,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case6_screen.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case4_screen.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';

class TutorialCase5Screen extends StatefulWidget {
  const TutorialCase5Screen({super.key});

  @override
  State<TutorialCase5Screen> createState() => _TutorialCase5ScreenState();
}

class _TutorialCase5ScreenState extends State<TutorialCase5Screen>
    with TickerProviderStateMixin {
  static const String _targetQuery =
      "SELECT balance FROM Student_Accounts WHERE name = 'Carrotino';";

  bool _isQueryClicked = false;
  bool _isHintDismissed = false;
  bool _isTableShown = false;

  bool _isQuerySuccessful = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  late AnimationController _spriteController;
  bool _isWalking = true;

  late SQLSyntaxController _queryController;

  @override
  void initState() {
    super.initState();

    // Fade Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Hint Shake Animation (Intermittent)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1500,
      ), // Longer duration to include pause
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 5),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 70), // Long pause
    ]).animate(_shakeController);

    _shakeController.repeat();

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _walkAnimation = Tween<double>(
      begin: -0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));

    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isWalking = false;
          });
          _spriteController.stop();
        }
      }
    });

    _walkController.forward();

    _queryController = SQLSyntaxController(
      hintText: _targetQuery,
      text: "SELECT balance FROM Student_Accounts WHERE name = 'Carrotino';", // Debug pre-fill
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    _walkController.dispose();
    _spriteController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _hideQuery() {
    FocusScope.of(context).unfocus();
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isQueryClicked = false;
          _isHintDismissed = false;
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
      RegExp(r'\s+'),
      ' ',
    );

    final bool isMatch =
        userInput == target || userInput == target.replaceAll(';', '');

    if (isMatch) {
      setState(() {
        _isQuerySuccessful = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Query Correct! You may now proceed."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background
          Image.asset(AppAssets.tutorialCase3Screen, fit: BoxFit.fill),

          // 1.2 Title Image
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(AppAssets.tutorialCase5Title, width: 450),
            ),
          ),

          // 1.5 Beanie Animation (Walking into Worried spot)
          AnimatedBuilder(
            animation: _walkAnimation,
            builder: (context, child) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double walkTranslation = _walkAnimation.value * screenWidth;
              return Positioned(
                left: (screenWidth * 0.135) + walkTranslation,
                top: 137.0,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _spriteController,
                    builder: (context, child) {
                      if (!_isWalking) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: const Offset(-52.0, 5),
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AppAnimations.worriedBeanie(width: 300),
                              ),
                            ),
                          ),
                        );
                      } else {
                        final String currentImage =
                            _spriteController.value < 0.5
                            ? AppAssets.beanieWalking1
                            : AppAssets.beanieWalking2;
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(
                              -35.0,
                              -45.5 +
                                  (Curves.easeInOut.transform(
                                        (_spriteController.value * 2) % 1.0,
                                      ) *
                                      10),
                            ),
                            child: Image.asset(currentImage, width: 70),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),

          // 2. Query Button and Where Display
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 120,
            child: Column(
              children: [
                BouncingButton(
                  onPressed: () {
                    setState(() => _isQueryClicked = true);
                    _fadeController.forward();
                  },
                  child: Image.asset(AppAssets.queryBtn, width: 100),
                ),
                const SizedBox(height: 10),
                Image.asset(AppAssets.case5WhereDisplay, width: 250),
              ],
            ),
          ),

          // 3. Success Next Button (Moved BELOW the overlay in the stack)
          if (_isQuerySuccessful)
            Positioned(
              bottom: 40,
              right: 40,
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: BouncingButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TutorialCase6Screen(),
                      ),
                    );
                  },
                  child: Image.asset(AppAssets.nextBtn, width: 100),
                ),
              ),
            ),

          // 4. Dark Overlay (Dimming the nextPage-btn if it's there)
          if (_isQueryClicked || _isTableShown)
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: () {
                  if (_isTableShown) {
                    setState(() {
                      _isTableShown = false;

                    });
                  } else {
                    _hideQuery();
                  }
                },
                child: Container(color: Colors.black.withValues(alpha: 0.7)),
              ),
            ),

          // 5. Query Display Panel
          if (_isQueryClicked && !_isTableShown)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
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
                                  setState(() => _isTableShown = true);
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
                              child: Image.asset(
                                AppAssets.tablesBtn,
                                width: 110,
                              ),
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

                    if (!_isHintDismissed)
                      Positioned(
                        top: 80,
                        right: -40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              AppAssets.tutorial5SelectHintBox,
                              width: 320,
                            ),
                            Positioned(
                              bottom: 25,
                              right: 45,
                              child: BouncingButton(
                                onPressed: () {
                                  setState(() => _isHintDismissed = true);
                                },
                                child: Image.asset(
                                  AppAssets.okayBtn,
                                  width: 85,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // 6. Hallway / Student Accounts Logs Display
          if (_isTableShown)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SizedBox(
                  width: 670,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        AppAssets.studentAccountsLogs,
                        width: 550,
                      ),

                      Positioned(
                        top: 10,
                        right: 70,
                        child: BouncingButton(
                          onPressed: () {
                            setState(() {
                              _isTableShown = false;
                            });
                          },
                          child: Image.asset(AppAssets.closeBtn, width: 35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 7. Navigation (Global)
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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TutorialCase4Screen(),
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

          if (_isQueryClicked && _isHintDismissed && !_isTableShown)
            KeyboardAccessoryBar(controller: _queryController),
        ],
      ),
    );
  }
}

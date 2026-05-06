import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case6_screen.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

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

  bool _isExiting = false;
  late AnimationController _exitController;
  late Animation<double> _exitAnimation;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.tutorialCase3Screen), context); 
    precacheImage(const AssetImage(AppAssets.tutorialCase6Screen), context);
    precacheImage(const AssetImage(AppAssets.nextBtn), context);
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: -3.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 5),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 70),
    ]).animate(_shakeController);

    _shakeController.repeat();

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _walkAnimation = Tween<double>(
      begin: -0.6,
      end: 0.00,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _exitAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));

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
     // text: "SELECT balance FROM Student_Accounts WHERE name = 'Carrotino';",
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    _walkController.dispose();
    _exitController.dispose();
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
          _isTableShown = false;
        });
      }
    });
  }

  void _validateQuery() {
    final String userInput = _queryController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final String target = _targetQuery.trim().replaceAll(RegExp(r'\s+'), ' ');

    final bool isMatch =
        userInput == target || userInput == target.replaceAll(';', '');

    if (isMatch) {
      setState(() {
        _isQuerySuccessful = true;
        _isTableShown = true;
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
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: 800,
            height: 360,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppAssets.tutorialCase3Screen, fit: BoxFit.fill),

                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      AppAssets.tutorialCase5Title,
                      width: 450,
                    ),
                  ),
                ),

                AnimatedBuilder(
                  animation: Listenable.merge([
                    _walkController,
                    _exitController,
                  ]),
                  builder: (context, child) {
                    const double canvasWidth = 800.0;
                    final double walkTranslation = _isExiting
                        ? _exitAnimation.value * canvasWidth
                        : _walkAnimation.value * canvasWidth;
                    return Positioned(
                      left: (canvasWidth * 0.135) + walkTranslation,
                      top: 120.0,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: !_isWalking
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: Transform.translate(
                                  offset: const Offset(-52.0, 5),
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: AppAnimations.worriedBeanie(
                                        width: 300,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.bottomCenter,
                                child: Transform.translate(
                                  offset: const Offset(-52.0, -35.0),
                                  child: AppAnimations.walkingBeanie(width: 70),
                                ),
                              ),
                      ),
                    );
                  },
                ),

                Positioned(
                  right: 20,
                  top: MediaQuery.of(context).size.height / 2 - 120,
                  child: Column(
                    children: [
                      BouncingButton(
                        onPressed: () {
                          setState(() => _isQueryClicked = true);
                          SFXController().playPopup();
                          _fadeController.forward();
                        },
                        child: Image.asset(AppAssets.queryBtn, width: 100),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _isExiting ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Image.asset(
                          AppAssets.case5WhereDisplay,
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isQuerySuccessful && !_isExiting)
                  Positioned(
                    bottom: 20,
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
                          setState(() {
                            _isExiting = true;
                            _isWalking = true;
                          });
                          _exitController.forward().then((_) {
                            if (mounted) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const TutorialCase6Screen(),
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
                              ).then((_) {
                                if (mounted) {
                                  setState(() {
                                    _isExiting = false;
                                    _isWalking = false;
                                  });
                                  _exitController.reset();
                                }
                              });
                            }
                          });
                        },
                        child: Image.asset(AppAssets.nextBtn, width: 100),
                      ),
                    ),
                  ),

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
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
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
                          Image.asset(
                            AppAssets.tutorialQueryDisplay,
                            width: 500,
                          ),

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
                              bottom: 4,
                              left: 20,
                              right: 20,
                              child: Row(
                                children: [
                                  BouncingButton(
                                    onPressed: () {
                                      if (_isQuerySuccessful) {
                                        setState(() => _isTableShown = true);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                      width: 100,
                                    ),
                                  ),
                                  const Spacer(),
                                  BouncingButton(
                                    onPressed: () => _queryController.clear(),
                                    child: Image.asset(
                                      AppAssets.clearBtn,
                                      width: 80,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  BouncingButton(
                                    onPressed: _validateQuery,
                                    child: Image.asset(
                                      AppAssets.runBtn,
                                      width: 110,
                                    ),
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

                // 6. Hallway
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
                                onPressed: _hideQuery,
                                child: Image.asset(
                                  AppAssets.closeBtn,
                                  width: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 7. Navigation
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

                if (_isQueryClicked && _isHintDismissed && !_isTableShown)
                  KeyboardAccessoryBar(
                    controller: _queryController,
                    hintText: _targetQuery,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

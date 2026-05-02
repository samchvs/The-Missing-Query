import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/core/constants/app_strings.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case4_screen.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

class TutorialCase3Screen extends StatefulWidget {
  const TutorialCase3Screen({super.key});

  @override
  State<TutorialCase3Screen> createState() => _TutorialCase3ScreenState();
}

class _TutorialCase3ScreenState extends State<TutorialCase3Screen>
    with TickerProviderStateMixin {
  static const String _targetQuery = AppStrings.targetQuery;
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
  late AnimationController _darkenController;
  late Animation<double> _darkenAnimation;
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
  bool _isTableUnlocked = false;
  bool _isExiting = false;
  late AnimationController _exitController;
  late Animation<double> _exitAnimation;
  final bool _isTransitioning = false;

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

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _walkAnimation = Tween<double>(
      begin: -0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));
    _walkController.forward();

    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spriteController.stop();
        if (mounted) {
          _fadeController.forward();
          setState(() {});
        }
      }
    });

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _hintOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_hintController);
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
            weight: 25,
          ),
          TweenSequenceItem(
            tween: ConstantTween(const Offset(0, 0)),
            weight: 60,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0, 0), end: const Offset(0, 0)),
            weight: 15,
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
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    ]).animate(_runHintController);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _exitAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));

    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TutorialCase4Screen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child,
            ),
          ).then((_) {
            if (mounted) {
              setState(() {
                _isExiting = false;
              });
              _exitController.reset();
            }
          });
        }
      }
    });

    _queryController.addListener(() {
      final text = _queryController.text.trim();
      if (text.length == _targetQuery.length) {
        final textPart1 = text.substring(0, 14).toUpperCase();
        final targetPart1 = _targetQuery.substring(0, 14).toUpperCase();
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

    _darkenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _darkenAnimation = CurvedAnimation(
      parent: _darkenController,
      curve: Curves.easeInOut,
    );
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
    _exitController.dispose();
    _darkenController.dispose();
    super.dispose();
  }

  bool _isQueryCorrect() {
    final text = _queryController.text.trim();
    if (text.length != _targetQuery.length) return false;
    final textPart1 = text.substring(0, 14).toUpperCase();
    final targetPart1 = _targetQuery.substring(0, 14).toUpperCase();
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
          Image.asset(AppAssets.tutorialCase3Screen, fit: BoxFit.fill),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset(AppAssets.tutorialCase3Title, width: 420),
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
                          offset: const Offset(20.0, -10.0),
                          child: BouncingButton(
                            onPressed: () {
                              if (!_isQueryClicked) {
                                setState(() {
                                  _isQueryClicked = true;
                                  _hintMarkedAsDone = true;
                                  _isHintDismissed = false;
                                });
                                _hintController.stop();
                                SFXController().playPopup();
                                _userFadeController.forward();
                              }
                            },
                            child: Image.asset(AppAssets.queryBtn, width: 100),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: (_isQueryClicked || _isTableUnlocked)
                              ? 0.0
                              : 1.0,
                          duration: const Duration(milliseconds: 600),
                          child: Image.asset(
                            AppAssets.tutorialCase3Pop,
                            width: 250,
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _hintController,
                      builder: (context, child) {
                        return AnimatedOpacity(
                          opacity: (_hintMarkedAsDone || _isTableUnlocked)
                              ? 0.0
                              : _hintOpacity.value,
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
                      child: Image.asset(AppAssets.mousePointer, width: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Beanie Walking Animation
          AnimatedBuilder(
            animation: Listenable.merge([_walkAnimation, _exitAnimation]),
            builder: (context, child) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double totalTranslation =
                  (_walkAnimation.value + _exitAnimation.value) * screenWidth;
              return Transform.translate(
                offset: Offset(totalTranslation, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.135,
                      top: 90.0,
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _spriteController,
                        builder: (context, child) {
                          if (_walkController.isCompleted && !_isExiting) {
                            return Align(
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
                                  -45.0,
                                  -45 +
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
                  ),
                ),
              );
            },
          ),
          // Next button (placed behind interactive overlays)
          if (_isTableUnlocked && !_isTableShown)
            Positioned(
              bottom: 30,
              right: 30,
              child: BouncingButton(
                onPressed: () {
                  if (!_isExiting) {
                    setState(() {
                      _isExiting = true;
                      _isTableShown = false; // Hide table if open
                    });
                    _spriteController.repeat();
                    _exitController.forward();
                  }
                },
                child: AnimatedOpacity(
                  opacity: _isExiting ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: ShakeWidget(
                    child: Image.asset(AppAssets.nextBtn, width: 100),
                  ),
                ),
              ),
            ),
          // Dark overlay
          IgnorePointer(
            ignoring: !_isQueryClicked,
            child: FadeTransition(
              opacity: _userFadeAnimation,
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),
          // Query display
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
                            AppAssets.tutorialQueryDisplay,
                            width: 450,
                          ),
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
                                            color: AppColors.primary.withValues(
                                              alpha: 0.3,
                                            ),
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
                                      color: AppColors.primary,
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
                              child: Image.asset(AppAssets.closeBtn, width: 20),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            left: 15,
                            child: BouncingButton(
                              onPressed: () {
                                if (_isTableUnlocked) {
                                  setState(() {
                                    _showQueryDisplay = false;
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
                              child: Image.asset(
                                AppAssets.tablesBtn,
                                width: 80,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BouncingButton(
                                  onPressed: () => _queryController.clear(),
                                  child: Image.asset(
                                    AppAssets.clearBtn,
                                    width: 75,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                BouncingButton(
                                  onPressed: () {
                                    if (_isQueryCorrect()) {
                                      setState(() {
                                        _isRunHintFinished = true;
                                        _showQueryDisplay = false;
                                        _isTableShown = true;
                                        _isTableUnlocked = true;
                                      });
                                    } else {
                                      _runHintController.stop();
                                    }
                                  },
                                  child: Image.asset(
                                    AppAssets.runBtn,
                                    width: 100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 60,
                            right: -30,
                            child: FadeTransition(
                              opacity: _popupUserFadeAnimation,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    AppAssets.tutorialSelectHintBox,
                                    width: 300,
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    right: 35,
                                    child: BouncingButton(
                                      onPressed: () {
                                        _popupUserFadeController.reverse().then(
                                          (_) {
                                            if (mounted) {
                                              setState(
                                                () => _isHintDismissed = true,
                                              );
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        color: Colors.transparent,
                                        child: Image.asset(
                                          AppAssets.okayBtn,
                                          width: 75,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                AppAssets.mousePointer,
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
          // Result Table
          IgnorePointer(
            ignoring: !_isTableShown,
            child: AnimatedOpacity(
              opacity: _isTableShown ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(AppAssets.tutorialTable, width: 500),
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
                                        color: AppColors.tableRowBorder,
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
                                      color: AppColors.primary,
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
                                        color: AppColors.primary,
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
                                        color: AppColors.primary,
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
                          setState(() {
                            _isTableShown = false;
                            _isQueryClicked = false;
                            _showQueryDisplay = true;
                          });
                          _userFadeController.reverse();
                        },
                        child: Image.asset(AppAssets.closeBtn, width: 25),
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
                  child: Image.asset(AppAssets.backBtn, width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () => TutorialMusicController.goHome(context),
                  child: Image.asset(AppAssets.homeBtn, width: 50),
                ),
              ],
            ),
          ),
          KeyboardAccessoryBar(controller: _queryController),
          // Darken transition
          IgnorePointer(
            ignoring: !_isTransitioning,
            child: FadeTransition(
              opacity: _darkenAnimation,
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

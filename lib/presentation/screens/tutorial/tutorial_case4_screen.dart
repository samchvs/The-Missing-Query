import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_strings.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case3_screen.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case5_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:audioplayers/audioplayers.dart';

class TutorialCase4Screen extends StatefulWidget {
  const TutorialCase4Screen({super.key});

  @override
  State<TutorialCase4Screen> createState() => _TutorialCase4ScreenState();
}

class _TutorialCase4ScreenState extends State<TutorialCase4Screen>
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  late AnimationController _spriteController;
  bool _showBubble = false;
  bool _showBubble2 = false;
  bool _showBubble3 = false;
  bool _isCarrotinoSad = false;
  bool _isQueryClicked = false;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;
  bool _isExiting = false;
  late AnimationController _exitController;
  late Animation<double> _exitAnimation;
  late AudioPlayer _audioPlayer;

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
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeIn,
    );

    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted && _showBubble && !_showBubble2) {
        setState(() {
          _showBubble2 = true;
        });
        _audioPlayer.play(AssetSource(AppAssets.carrotinoAnswerAudio));
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showBubble3 = true;
            });
          }
        });
      }
    });

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spriteController.stop();
        if (mounted) {
          setState(() {
            _showBubble = true;
            _isCarrotinoSad = true;
          });
          _audioPlayer.play(AssetSource(AppAssets.beanieQuestionAudio));
        }
      }
    });

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _exitAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));

    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TutorialCase5Screen(),
            ),
          );
        }
      }
    });

    _walkController.forward();
  }

  @override
  void dispose() {
    _walkController.dispose();
    _spriteController.dispose();
    _overlayController.dispose();
    _exitController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppAssets.tutorialCase4Screen, fit: BoxFit.fill),
              // Carrotino — completely independent, never affected by Beanie
              Positioned(
                left: screenWidth * 0.45 + 10.0,
                top: 150.0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showBubble2
                      ? Transform.translate(
                          offset: const Offset(0, -5.0),
                          key: const ValueKey<int>(2),
                          child: AppAnimations.talkingCarrotino(width: 180),
                        )
                      : _isCarrotinoSad
                          ? Transform.translate(
                              offset: const Offset(0, 8.0),
                              key: const ValueKey<int>(1),
                              child: SizedBox(
                                width: 180,
                                child: Center(
                                  child: Image.asset(
                                    AppAssets.sadCarrotino,
                                    width: 80,
                                  ),
                                ),
                              ),
                            )
                          : Transform.translate(
                              offset: const Offset(0, -3.0),
                              key: const ValueKey<int>(0),
                              child: AppAnimations.wavingCarrotino(width: 180),
                            ),
                ),
              ),
              if (_showBubble2)
                Positioned(
                  left: screenWidth * 0.45 + 110.0, // 50.0 + 60.0
                  top: 110.0, // 190.0 - 80.0
                  child: Image.asset(
                    AppAssets.carrotinoResponseBubble,
                    width: 150,
                  ),
                ),
              // Beanie — walks in independently
              AnimatedBuilder(
                animation: Listenable.merge([_walkAnimation, _exitAnimation]),
                builder: (context, child) {
                  final double totalTranslation =
                      (_walkAnimation.value + _exitAnimation.value) *
                      screenWidth;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.45,
                        top: 120.0,
                      ),
                      child: Transform.translate(
                        offset: Offset(totalTranslation, 0),
                        child: AnimatedBuilder(
                          animation: _spriteController,
                          builder: (context, child) {
                            if (_walkController.isCompleted && !_isExiting) {
                              return Transform.translate(
                                offset: const Offset(-110.0, -10.0),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AppAnimations.talkingBeanie(width: 200),
                                    if (_showBubble)
                                      Positioned(
                                        top: -30,
                                        left: -70,
                                        child: Image.asset(
                                          AppAssets.beanieQuestionBubble,
                                          width: 150,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            } else {
                              final String currentImage =
                                  _spriteController.value < 0.5
                                  ? AppAssets.beanieWalking1
                                  : AppAssets.beanieWalking2;
                              return Transform.translate(
                                offset: Offset(
                                  -30.0,
                                  -7.5 +
                                      (Curves.easeInOut.transform(
                                            (_spriteController.value * 2) % 1.0,
                                          ) *
                                          10),
                                ),
                                child: Image.asset(currentImage, width: 70),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_showBubble3 && !_isExiting)
                Positioned(
                  bottom: 30,
                  left: 45,
                  child: Image.asset(
                    AppAssets.tutorialHintBubble,
                    width: 240,
                  ),
                ),
              if (_showBubble3)
                Positioned(
                  bottom: 30,
                  right: 30,
                  child: BouncingButton(
                    onPressed: () {
                      if (!_isExiting) {
                        setState(() {
                          _isExiting = true;
                          _showBubble = false;
                          _showBubble2 = false;
                          _showBubble3 = false;
                        });
                        _audioPlayer.stop();
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
              // Overlays and Panels
              if (_isQueryClicked)
                FadeTransition(
                  opacity: _overlayAnimation,
                  child: GestureDetector(
                    onTap: () {
                      _overlayController.reverse().then((_) {
                        if (mounted) setState(() => _isQueryClicked = false);
                      });
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              if (_isQueryClicked)
                FadeTransition(
                  opacity: _overlayAnimation,
                  child: Center(
                    child: Stack(
                      children: [
                        Image.asset(AppAssets.tutorialQueryDisplay, width: 500),
                        Positioned(
                          top: 15,
                          right: 35,
                          child: BouncingButton(
                            onPressed: () {
                              _overlayController.reverse().then((_) {
                                if (mounted) setState(() => _isQueryClicked = false);
                              });
                            },
                            child: Image.asset(AppAssets.closeBtn, width: 25),
                          ),
                        ),
                        // The "unlocked" query view
                        Positioned(
                          top: 100,
                          left: 45,
                          right: 45,
                          child: Text(
                            AppStrings.targetQuery,
                            style: const TextStyle(
                              color: Color(0xFF00FF00), // Terminal green
                              fontFamily: 'Courier',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration.zero,
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const TutorialCase3Screen(),
                          ),
                        );
                      },
                      child: Image.asset(AppAssets.backBtn, width: 50),
                    ),
                    const SizedBox(width: 15),
                    BouncingButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: Image.asset(AppAssets.homeBtn, width: 50),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

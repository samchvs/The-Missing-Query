import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case9_screen.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

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
  final int _currentStepIndex = 0;
  String get _targetQuery => _targets[_currentStepIndex];

  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  bool _isWalking = true;

  bool _isOverlayShown = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isQueryClicked = false;
  bool _isHintDismissed = false;
  bool _isTableShown = false;
  bool _isQuerySuccessful = false;
  bool _isRegistryShown = false;
  bool _isRegistryGuideShown = false;
  Timer? _errorTimer;

  late SQLSyntaxController _queryController;

  String _typedText = "";
  final String _fullText =
      "Beanie goes to the Campus Security Office to file a report. He matched the MAC address from the tablet to a student.";
  Timer? _typingTimer;

  bool _isTypingFinished = false;
  bool _isWaitingForGuide = false;
  late AnimationController _queryFadeController;
  late Animation<double> _queryFadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.tutorialCase7Screen), context);
    precacheImage(const AssetImage(AppAssets.tutorialCase9Screen), context);
    precacheImage(const AssetImage(AppAssets.nextBtn), context);
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();

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
      //text: "SELECT student_name FROM Device_Registry WHERE mac_address = '00:1A:2B:3C';", // Debug pre-fill
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
      if (status == AnimationStatus.completed && _isOverlayShown) {
        _startTyping();
      }
    });

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isWalking = false;
          });

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
    final String userInput = _queryController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final String target = _targetQuery.trim().replaceAll(
      RegExp(r'[\s\n]+'),
      ' ',
    );

    final bool isMatch =
        userInput == target || userInput == target.replaceAll(';', '');

    if (isMatch) {
      setState(() {
        _isQuerySuccessful = true;
        _isRegistryShown = true;
        _isRegistryGuideShown = false;
        _isWaitingForGuide = true;
        _isQueryClicked = false;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          SFXController().playCorrectAnswer();
          setState(() {
            _isRegistryGuideShown = true;
            _isWaitingForGuide = false;
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
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(SFXController().volume);
    _audioPlayer.play(AssetSource(AppAssets.typewriterAudio));
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
        _audioPlayer.stop();
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
                Image.asset(AppAssets.tutorialCase7Screen, fit: BoxFit.fill),

                // Beanie Animation
                AnimatedBuilder(
                  animation: _walkAnimation,
                  builder: (context, child) {
                    final double screenWidth = MediaQuery.of(
                      context,
                    ).size.width;
                    final double walkTranslation =
                        _walkAnimation.value * screenWidth;
                    return Positioned(
                      left: (screenWidth * 0.135) + walkTranslation,
                      bottom: _isWalking ? 12 : -30,
                      child: Container(
                        width: 220,
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
                          _audioPlayer.stop();
                          Navigator.pop(context);
                        },
                        child: Image.asset(AppAssets.backBtn, width: 50),
                      ),
                      const SizedBox(width: 15),
                      BouncingButton(
                        onPressed: () {
                          _audioPlayer.stop();
                          TutorialMusicController.goHome(context);
                        },
                        child: Image.asset(AppAssets.homeBtn, width: 50),
                      ),
                    ],
                  ),
                ),

                if (_isQuerySuccessful &&
                    !_isTableShown &&
                    !_isRegistryShown &&
                    !_isQueryClicked &&
                    !_isOverlayShown)
                  Positioned(
                    bottom: 40,
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
                                        const TutorialCase9Screen(),
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
                          );
                        },
                        child: Image.asset(AppAssets.nextBtn, width: 100),
                      ),
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
                            _audioPlayer.stop();
                            _fadeController.reverse().then((_) {
                              if (mounted) {
                                setState(() {
                                  _isOverlayShown = false;
                                });
                                _queryFadeController.forward();
                              }
                            });
                          },
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Image.asset(
                                AppAssets.tutorialDisplay,
                                width: 500,
                              ),
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
                        SFXController().playPopup();
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
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ),

                if (_isQueryClicked && !_isTableShown)
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(AppAssets.tutorialQueryDisplay, width: 500),

                        if (_isHintDismissed)
                          Positioned(
                            top: 68,
                            left: 40,
                            right: 40,
                            bottom: 72,
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
                            child: Image.asset(AppAssets.closeBtn, width: 20),
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
                                      setState(() {
                                        _isTableShown = true;
                                      });
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

                if (_isTableShown)
                  Center(
                    child: SizedBox(
                      width: 670,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(AppAssets.deviceRegistry, width: 550),

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
                  KeyboardAccessoryBar(
                    controller: _queryController,
                    hintText: _targetQuery,
                  ),

                // Device Registry Popup
                if (_isRegistryShown)
                  AbsorbPointer(
                    absorbing: _isWaitingForGuide,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isRegistryShown = false),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.7),
                          ),
                        ),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                _isQuerySuccessful
                                    ? AppAssets.specificDeviceRegistry
                                    : AppAssets.deviceRegistry,
                                width: 550,
                              ),
                            ],
                          ),
                        ),

                        if (_isRegistryGuideShown)
                          Stack(
                            children: [
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
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

                                          Navigator.push(
                                            context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) =>
                                                        const TutorialCase9Screen(),
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
          ),
        ),
      ),
    );
  }
}

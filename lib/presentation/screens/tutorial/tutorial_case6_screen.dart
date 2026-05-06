import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/widgets/common/sql_syntax_controller.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case8_screen.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

class TutorialCase6Screen extends StatefulWidget {
  const TutorialCase6Screen({super.key});

  @override
  State<TutorialCase6Screen> createState() => _TutorialCase6ScreenState();
}

class _TutorialCase6ScreenState extends State<TutorialCase6Screen>
    with TickerProviderStateMixin {
  static const String _targetQuery =
      "SELECT trans_id FROM Tablet WHERE status = 'Completed';";

  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  bool _isWalking = true;
  bool _isDisplayShown = false;
  bool _isTypingDone = false;
  bool _wasDisplayClosed = false;
  bool _isExiting = false;
  late AnimationController _exitController;
  late Animation<double> _exitAnimation;

  bool _isQueryClicked = false;
  bool _isHintDismissed = false;
  bool _isTableShown = false;
  bool _isQuerySuccessful = false;
  bool _isSuccessLogShown = false;
  bool _isGuideShown = false;
  bool _isTutorialGuidePopShown = false;
  bool _isGuideAnswered = false;
  bool _hasClickedHint = false;
  bool _hasSeenTutorialGuidePop = false;
  String? _errorMessage;
  Timer? _errorTimer;

  String _typedText = "";
  final String _fullText =
      "Beanie walks over to the cafeteria counter. A guide question appears over the server's tablet.";
  Timer? _typingTimer;

  late SQLSyntaxController _queryController;
  late TextEditingController _guideAnswerController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache assets for this screen and the next
    precacheImage(const AssetImage(AppAssets.tutorialCase6Screen), context);
    precacheImage(const AssetImage(AppAssets.tutorialCase8Screen), context);
    precacheImage(const AssetImage(AppAssets.nextBtn), context);
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();

    _queryController = SQLSyntaxController(
      hintText: _targetQuery,
      //text: "SELECT trans_id FROM Tablet WHERE status = 'Completed';", // Debug pre-fill
    );

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _moveAnimation =
        Tween<double>(begin: -300, end: 200).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.linear),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _isWalking = false;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isDisplayShown = true;
                });
                _fadeController.forward();
              }
            });
          }
        });

    _fadeController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && _isDisplayShown) {
            _startTyping();
          }
        });

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
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

    _guideAnswerController = TextEditingController();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _floatingAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floatingController.repeat(reverse: true);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _exitAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.linear));

    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TutorialCase8Screen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
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

    _moveController.forward();
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
            _isTypingDone = true;
          });
        }
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
        _isQueryClicked = false;
        _isTableShown = false;
        _isSuccessLogShown = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Query Correct! Beanie found the ID."),
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
  void dispose() {
    _moveController.dispose();
    _fadeController.dispose();
    _shakeController.dispose();
    _floatingController.dispose();
    _exitController.dispose();
    _queryController.dispose();
    _guideAnswerController.dispose();
    _typingTimer?.cancel();
    _errorTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _hideDisplay() {
    _audioPlayer.stop();
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDisplayShown = false;
          _wasDisplayClosed = true;
        });
      }
    });
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

  TextSpan _buildRichText(String currentText) {
    return TextSpan(
      text: currentText,
      style: GoogleFonts.londrinaSolid(
        fontSize: 17,
        color: Colors.black,
        height: 1.3,
      ),
    );
  }

  void _validateGuideAnswer() {
    final entry = _guideAnswerController.text.trim();

    if (entry != "SCAN-98") {
      _errorTimer?.cancel();
      setState(() {
        _errorMessage = "INCORRECT ENTRY. TRY CHECKING THE HINT!";
      });
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    } else {
      _errorTimer?.cancel();
      setState(() {
        _errorMessage = "Valid entry";
      });
      _errorTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isGuideShown = false;
            _errorMessage = null;
            _isGuideAnswered = true;
          });
        }
      });
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
                Image.asset(AppAssets.tutorialCase6Screen, fit: BoxFit.fill),

                AnimatedBuilder(
                  animation: Listenable.merge([_moveAnimation, _exitAnimation]),
                  builder: (context, _) {
                    const double canvasWidth = 800.0;
                    final double moveVal = _moveAnimation.value;
                    final double exitVal = _exitAnimation.value * canvasWidth;
                    return Positioned(
                      left: moveVal + exitVal,
                      bottom: (_isWalking || _isExiting) ? 12 : -30,
                      child: Container(
                        width: 220,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Opacity(
                              opacity: (_isWalking || _isExiting) ? 1.0 : 0.0,
                              child: AppAnimations.walkingBeanie(width: 80),
                            ),
                            Opacity(
                              opacity: (_isWalking || _isExiting) ? 0.0 : 1.0,
                              child: AppAnimations.worriedBeanie(width: 220),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                if (_isGuideAnswered &&
                    !_isTableShown &&
                    !_isDisplayShown &&
                    !_isSuccessLogShown)
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
                          if (!_isExiting) {
                            setState(() {
                              _isExiting = true;
                            });
                            _exitController.forward();
                          }
                        },
                        child: AnimatedOpacity(
                          opacity: _isExiting ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Image.asset(AppAssets.nextBtn, width: 100),
                        ),
                      ),
                    ),
                  ),
                if (_wasDisplayClosed)
                  Positioned(
                    right: 20,
                    top: 60,
                    child: AbsorbPointer(
                      absorbing: !_hasClickedHint,
                      child: Opacity(
                        opacity: _hasClickedHint ? 1.0 : 0.5,
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
                  ),

                if (_wasDisplayClosed && !_isQueryClicked && !_isTableShown)
                  Positioned(
                    left: 350,
                    top: 165,
                    child: BouncingButton(
                      onPressed: () {
                        setState(() {
                          _isGuideShown = true;
                          if (!_hasSeenTutorialGuidePop) {
                            _isTutorialGuidePopShown = true;
                            _hasSeenTutorialGuidePop = true;
                          }
                          _hasClickedHint = true;
                        });
                        SFXController().playPopup();
                        _fadeController.forward(from: 0.0);
                      },
                      child: AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: child,
                          );
                        },
                        child: Image.asset(AppAssets.floatingHint, width: 40),
                      ),
                    ),
                  ),

                if (_isDisplayShown ||
                    _isQueryClicked ||
                    _isTableShown ||
                    _isSuccessLogShown ||
                    _isGuideShown)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: () {
                        if (_isTableShown) {
                          setState(() => _isTableShown = false);
                        } else if (_isQueryClicked) {
                          _hideQuery();
                        } else if (_isSuccessLogShown) {
                          _fadeController.reverse().then((_) {
                            if (mounted) {
                              setState(() => _isSuccessLogShown = false);
                            }
                          });
                        } else if (_isGuideShown) {
                          setState(() => _isGuideShown = false);
                        }
                      },
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ),

                if (_isGuideShown)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            AppAssets.tutorialGuideQuestion,
                            width: 500,
                          ),
                          Positioned(
                            top: 210,
                            left: 40,
                            right: 90,
                            child: TextField(
                              controller: _guideAnswerController,
                              style: GoogleFonts.inconsolata(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: "Type your answer here...",
                                hintStyle: GoogleFonts.inconsolata(
                                  color: Colors.grey.withValues(alpha: 0.7),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: BouncingButton(
                                onPressed: _validateGuideAnswer,
                                child: Image.asset(
                                  AppAssets.submitBtn,
                                  width: 70,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 15,
                            child: BouncingButton(
                              onPressed: () {
                                setState(() => _isGuideShown = false);
                              },
                              child: Image.asset(AppAssets.closeBtn, width: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isTutorialGuidePopShown)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isTutorialGuidePopShown = false);
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppAssets.tutorialGuidepop,
                          width: 380,
                        ),
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
                            child: Image.asset(AppAssets.closeBtn, width: 30),
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
                                  AppAssets.tutorialCase6SelectHintBox,
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

                if (_isTableShown)
                  Center(
                    child: SizedBox(
                      width: 670,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(AppAssets.tabletLogs, width: 550),

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

                if (_isSuccessLogShown)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(AppAssets.tabletLogs, width: 550),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: BouncingButton(
                              onPressed: () {
                                _fadeController.reverse().then((_) {
                                  if (mounted) {
                                    setState(() => _isSuccessLogShown = false);
                                  }
                                });
                              },
                              child: Image.asset(AppAssets.closeBtn, width: 35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isDisplayShown)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(AppAssets.tutorialDisplay, width: 500),
                          Positioned(
                            left: 80,
                            right: 80,
                            top: 60,
                            bottom: 60,
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: _buildRichText(_typedText),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isTypingDone && _isDisplayShown)
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
                        onPressed: _hideDisplay,
                        child: Image.asset(AppAssets.nextBtn, width: 100),
                      ),
                    ),
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

                if (_isGuideShown)
                  KeyboardAccessoryBar(controller: _guideAnswerController),

                if (_isQueryClicked && _isHintDismissed && !_isTableShown)
                  KeyboardAccessoryBar(
                    controller: _queryController,
                    hintText: _targetQuery,
                  ),

                if (_errorMessage != null)
                  Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: _errorMessage == "Valid entry"
                          ? Colors.green.withValues(alpha: 0.9)
                          : AppColors.redAccent.withValues(alpha: 0.9),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 25,
                      ),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.luckiestGuy(
                          color: Colors.white,
                          fontSize: 13,
                          letterSpacing: 1.2,
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
}

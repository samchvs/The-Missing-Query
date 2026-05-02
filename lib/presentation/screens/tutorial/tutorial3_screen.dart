import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial4_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';
import 'package:graphics_project/presentation/widgets/common/typewriter_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';

class Tutorial3Screen extends StatefulWidget {
  const Tutorial3Screen({super.key});

  @override
  State<Tutorial3Screen> createState() => _Tutorial3ScreenState();
}

class _Tutorial3ScreenState extends State<Tutorial3Screen> {
  bool _isTalking = false;
  bool _showText = false;
  int _currentStep = 0;
  bool _isTextFinished = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, Duration> _stepDurations = {
    0: const Duration(seconds: 4),
    1: const Duration(seconds: 6),
    2: const Duration(seconds: 7),
    3: const Duration(seconds: 6),
  };

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();
    _startStep0();
  }

  void _startStep0() {
    // Beanie waves for 1 second, then starts talking and typing
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted && _currentStep == 0) {
        setState(() {
          _isTalking = true;
          _showText = true;
        });
        await _audioPlayer.play(AssetSource(AppAssets.tutorial3BeanieAudio));
      }
    });
  }

  void _onNextStep() async {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        _isTextFinished = false;
        _isTalking = true;
      });
      String audioPath;
      switch (_currentStep) {
        case 1:
          audioPath = AppAssets.tutorial3BroccoliandroAudio;
          break;
        case 2:
          audioPath = AppAssets.tutorial3TomathomasAudio;
          break;
        case 3:
          audioPath = AppAssets.tutorial3CarrotinoAudio;
          break;
        default:
          audioPath = AppAssets.tutorial3BeanieAudio;
      }
      await _audioPlayer.play(AssetSource(audioPath));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Tutorial4Screen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: 800,
            height: 360,
            child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.tutorial3Screen,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
          Align(
            alignment: const Alignment(0, 0.4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(AppAssets.tutorial3Box, width: 670),
                if (_showText)
                  Positioned(
                    left: 50,
                    top: 55,
                    right: 250,
                    child: _currentStep == 0
                        ? TypewriterText(
                            key: const ValueKey('step0'),
                            text:
                                "We’re Beanie, Carrotino, Tomathomas, and Broccoliandro, your guide for this case.",
                            style: GoogleFonts.londrinaSolid(
                              color: const Color(0xFF542E2E),
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.left,
                            duration: _stepDurations[0]!,
                            boldWords: const [
                              "Beanie",
                              "Carrotino",
                              "Tomathomas",
                              "Broccoliandro",
                            ],
                            onFinished: () {
                              setState(() {
                                _isTalking = false;
                                _isTextFinished = true;
                              });
                            },
                          )
                        : _currentStep == 1
                        ? TypewriterText(
                            key: const ValueKey('step1'),
                            text:
                                "We’re here to guide you as you learn how to run SQL queries, analyze data, and uncover important clues.",
                            style: GoogleFonts.londrinaSolid(
                              color: const Color(0xFF542E2E),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                            duration: _stepDurations[1]!,
                            onFinished: () {
                              setState(() {
                                _isTextFinished = true;
                                _isTalking = false;
                              });
                            },
                          )
                        : _currentStep == 2
                        ? TypewriterText(
                            key: const ValueKey('step2'),
                            text:
                                "Each step will help you understand how to search records, filter information, and connect the evidence.",
                            style: GoogleFonts.londrinaSolid(
                              color: const Color(0xFF542E2E),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                            duration: _stepDurations[2]!,
                            onFinished: () {
                              setState(() {
                                _isTextFinished = true;
                                _isTalking = false;
                              });
                            },
                          )
                        : TypewriterText(
                            key: const ValueKey('step3'),
                            text:
                                "Pay close attention because every detail matters, and the answer is hidden within the data.",
                            style: GoogleFonts.londrinaSolid(
                              color: const Color(0xFF542E2E),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                            duration: _stepDurations[3]!,
                            onFinished: () {
                              setState(() {
                                _isTextFinished = true;
                                _isTalking = false;
                              });
                            },
                          ),
                  ),
                if (_currentStep == 0)
                  Positioned(
                    right: 35,
                    bottom: 25,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: _isTalking
                          ? AppAnimations.talkingBeanie(
                              key: const ValueKey('talking_beanie'),
                              width: 250,
                            )
                          : AppAnimations.helloBeanie(
                              key: const ValueKey('hello_beanie'),
                              width: 250,
                              frameDuration: const Duration(milliseconds: 125),
                            ),
                    ),
                  ),
                if (_currentStep == 1)
                  Positioned(
                    right: 35,
                    bottom: 25,
                    child: SpriteAnimator(
                      frames: AppAssets.dancingBroccoli,
                      width: 250,
                      frameDuration: const Duration(milliseconds: 150),
                      fit: BoxFit.fill,
                      loop: true,
                    ),
                  ),
                if (_currentStep == 2)
                  Positioned(
                    right: 35,
                    bottom: 25,
                    child: SpriteAnimator(
                      frames: AppAssets.dancingTomathomas,
                      width: 250,
                      frameDuration: const Duration(milliseconds: 150),
                      fit: BoxFit.fill,
                      loop: true,
                    ),
                  ),
                if (_currentStep == 3)
                  Positioned(
                    right: 50,
                    bottom: 40,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: _isTalking
                          ? AppAnimations.talkingCarrotino(
                              key: const ValueKey('talking_carrotino'),
                              width: 230,
                            )
                          : SpriteAnimator(
                              key: const ValueKey('dancing_carrotino'),
                              frames: AppAssets.dancingCarrotino,
                              width: 230,
                              frameDuration: const Duration(milliseconds: 150),
                              fit: BoxFit.fill,
                              loop: true,
                            ),
                    ),
                  ),
                if (_isTextFinished)
                  Positioned(
                    right: 45,
                    bottom: 35,
                    child: BouncingButton(
                      onPressed: _onNextStep,
                      child: Image.asset(AppAssets.arrowRightBtn, width: 25),
                    ),
                  ),
              ],
            ),
          ),
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
        ],
      ),
          ),
        ),
      ),
    );
  }
}

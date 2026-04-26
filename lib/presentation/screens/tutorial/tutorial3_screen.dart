import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial4_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';
import 'package:graphics_project/presentation/widgets/common/typewriter_text.dart';

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

  @override
  void initState() {
    super.initState();
    _startStep0();
  }

  void _startStep0() {
    // Beanie waves for 1 second, then starts talking and typing
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _currentStep == 0) {
        setState(() {
          _isTalking = true;
          _showText = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
                Image.asset(
                  AppAssets.tutorial3Box,
                  width: 670,
                ),
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
                            duration: const Duration(seconds: 8),
                            boldWords: const [
                              "Beanie",
                              "Carrotino",
                              "Tomathomas",
                              "Broccoliandro"
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
                                duration: const Duration(seconds: 8),
                                onFinished: () {
                                  setState(() {
                                    _isTextFinished = true;
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
                                    duration: const Duration(seconds: 8),
                                    onFinished: () {
                                  setState(() {
                                    _isTextFinished = true;
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
                                    duration: const Duration(seconds: 8),
                                    onFinished: () {
                                  setState(() {
                                    _isTextFinished = true;
                                  });
                                },
                                  ),
                  ),
                if (_currentStep == 0)
                  Positioned(
                    right: 35,
                    bottom: 25,
                    child: _isTalking
                        ? AppAnimations.talkingBeanie(width: 250)
                        : AppAnimations.helloBeanie(
                            width: 250,
                            frameDuration: const Duration(milliseconds: 125),
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
                      fit: BoxFit.contain,
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
                      fit: BoxFit.contain,
                      loop: true,
                    ),
                  ),
                if (_currentStep == 3)
                  Positioned(
                    right: 50,
                    bottom: 40,
                    child: SpriteAnimator(
                      frames: AppAssets.dancingCarrotino,
                      width: 230,
                      frameDuration: const Duration(milliseconds: 150),
                      fit: BoxFit.contain,
                      loop: true,
                    ),
                  ),
                if (_isTextFinished)
                  Positioned(
                    right: 45,
                    bottom: 35,
                    child: BouncingButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          setState(() {
                            _currentStep = 1;
                            _isTextFinished = false;
                          });
                        } else if (_currentStep == 1) {
                          setState(() {
                            _currentStep = 2;
                            _isTextFinished = false;
                          });
                        } else if (_currentStep == 2) {
                          setState(() {
                            _currentStep = 3;
                            _isTextFinished = false;
                          });
                        } else {
                          Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Tutorial4Screen(),
                            transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) =>
                                child,
                          ),
                        );
                      }
                    },
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
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Image.asset(AppAssets.homeBtn, width: 50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/presentation/widgets/common/typewriter_text.dart';
import 'package:provider/provider.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/screens/home/home_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/controllers/home_music_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

class TutorialCase10Screen extends StatefulWidget {
  const TutorialCase10Screen({super.key});

  @override
  State<TutorialCase10Screen> createState() => _TutorialCase10ScreenState();
}

class _TutorialCase10ScreenState extends State<TutorialCase10Screen>
    with TickerProviderStateMixin {
  int _dialogueIndex = 0;
  bool _isTextFinished = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _audioSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache assets for this screen and the finale
    precacheImage(const AssetImage(AppAssets.case10Finale), context);
    precacheImage(const AssetImage(AppAssets.challengeBtn), context);
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().setVolume(0.4);
    TutorialMusicController().play();
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

    _audioSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _advanceDialogue();
    });

    _playDialogueAudio();
  }

  Future<void> _playDialogueAudio() async {
    if (_dialogueIndex < _dialogueAudios.length) {
      String? audioPath = _dialogueAudios[_dialogueIndex];
      if (audioPath != null) {
        await _audioPlayer.stop();
        final vol = SFXController().volume;
        debugPrint("Playing finale dialogue in Tutorial Case 10 with volume: $vol");
        await _audioPlayer.setVolume(vol);
        await _audioPlayer.play(AssetSource(audioPath), volume: vol);
      }
    }
  }

  @override
  void dispose() {
    TutorialMusicController().setVolume(1.0); 
    _shakeController.dispose();
    _audioSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  final List<List<String>> _allDialogues = [
    AppAssets.case10Dialogue1,
    AppAssets.case10Dialogue2,
    AppAssets.case10Dialogue3,
    AppAssets.case10Dialogue4,
    AppAssets.case10Dialogue5,
    AppAssets.case10Dialogue6,
    AppAssets.case10Dialogue7,
    AppAssets.case10Dialogue8,
  ];

  final List<String?> _dialogueAudios = [
    AppAssets.case10Dialogue1Audio,
    AppAssets.case10Dialogue2Audio,
    AppAssets.case10Dialogue3Audio,
    AppAssets.case10Dialogue4Audio,
    AppAssets.case10Dialogue5Audio,
    AppAssets.case10Dialogue6Audio,
    AppAssets.case10Dialogue7Audio,
    null,
  ];

  void _advanceDialogue() {
    if (_dialogueIndex < _allDialogues.length - 1) {
      setState(() {
        _dialogueIndex++;
      });
      _playDialogueAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 800,
                height: 360,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Animated Background
                    Transform.scale(
                      scale: 1.08,
                      child: SpriteAnimator(
                        frames: _allDialogues[_dialogueIndex],
                        frameDuration: const Duration(milliseconds: 150),
                        fit: BoxFit.cover,
                        loop:
                            _dialogueAudios[_dialogueIndex] != null ||
                            _dialogueIndex == _allDialogues.length - 1,
                        onComplete: _dialogueAudios[_dialogueIndex] != null
                            ? null
                            : _advanceDialogue,
                      ),
                    ),

                    if (_dialogueIndex == 7)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(AppAssets.case10Finale, width: 240),
                            Positioned(
                              top: 20,
                              bottom: 20,
                              left: 30,
                              right: 30,
                              child: TypewriterText(
                                key: const ValueKey('finale_text'),
                                text:
                                    "Congratulations! As you traverse the meticulous web of cases, we hope you use what you’ve learned to unlock the SQL Mystery!",
                                style: GoogleFonts.londrinaSolid(
                                  fontSize: 13,
                                  color: const Color(0xFF4A2C2A),
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.justify,
                                duration: const Duration(seconds: 4),
                                playAudio: true,
                                onFinished: () {
                                  if (mounted) {
                                    setState(() {
                                      _isTextFinished = true;
                                    });
                                  }
                                },
                                boldWords: const [
                                  'Congratulations!',
                                  'SQL Mystery!',
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Top UI Bar
                    Positioned(
                      top: 15,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          BouncingButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(AppAssets.backBtn, width: 55),
                          ),
                          const SizedBox(width: 10),
                          BouncingButton(
                            onPressed: () =>
                                TutorialMusicController.goHome(context),
                            child: Image.asset(AppAssets.homeBtn, width: 55),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Challenge button to proceed to homescreen
                    if (_isTextFinished)
                      Positioned(
                        bottom: 20,
                        right: 20,
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
                              TutorialMusicController().stop();
                              HomeMusicController().play();
                              final authController =
                                  Provider.of<AuthController>(
                                    context,
                                    listen: false,
                                  );
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) =>
                                          HomeScreen(
                                            username:
                                                authController.displayUsername,
                                            authController: authController,
                                          ),
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
                                (route) => false,
                              );
                            },
                            child: Image.asset(
                              AppAssets.challengeBtn,
                              width: 180,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case2_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

class TutorialCaseScreen extends StatefulWidget {
  const TutorialCaseScreen({super.key});

  @override
  State<TutorialCaseScreen> createState() => _TutorialCaseScreenState();
}

class _TutorialCaseScreenState extends State<TutorialCaseScreen>
    with TickerProviderStateMixin {
  static const String _caseText =
      'Beanie\u2019s VIP meal card was stolen just before lunch.\n'
      'Several students were seen in the hallway at the same time, each with their own story.\n'
      'Beanie needs to figure out who had the opportunity and motive to use the card.';

  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<int> _charCount;
  late Animation<double> _characterFade;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache assets for this screen and the next
    precacheImage(const AssetImage(AppAssets.tutorialCaseScreen), context);
    precacheImage(AssetImage(AppAssets.case2Screen[0]), context); // Background for Case 2
    precacheImage(const AssetImage(AppAssets.nextBtn), context);
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _charCount = StepTween(
      begin: 0,
      end: _caseText.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _characterFade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _audioPlayer.setReleaseMode(ReleaseMode.release);
        _audioPlayer.stop();
        _fadeController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        _audioPlayer.setVolume(SFXController().volume);
        _audioPlayer.play(AssetSource(AppAssets.typewriterAudio));
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
                Image.asset(AppAssets.tutorialCaseScreen, fit: BoxFit.fill),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Image.asset(AppAssets.tutorialCaseTitle, width: 350),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(AppAssets.caseDisplayBox, width: 580),
                        Positioned(
                          right: -60,
                          top: 120,
                          child: FadeTransition(
                            opacity: _characterFade,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -95,
                                  child: SpriteAnimator(
                                    frames: AppAssets.dancingTomathomas,
                                    width: 150,
                                    frameDuration: const Duration(
                                      milliseconds: 150,
                                    ),
                                    fit: BoxFit.fill,
                                    loop: true,
                                  ),
                                ),
                                Image.asset(AppAssets.userDisplay, width: 100),
                                Positioned.fill(
                                  child: Center(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(text: 'click '),
                                          TextSpan(
                                            text: 'NEXT',
                                            style: GoogleFonts.londrinaSolid(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: GoogleFonts.londrinaSolid(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 60,
                          right: 100,
                          child: FadeTransition(
                            opacity: _characterFade,
                            child: BouncingButton(
                              onPressed: () {
                                _audioPlayer.stop();
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
                                        ) => const TutorialCase2Screen(),
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
                              child: ShakeWidget(
                                child: Image.asset(
                                  AppAssets.nextBtn,
                                  width: 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 140.0,
                                vertical: 75.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Case Description',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.luckiestGuy(
                                      fontSize: 25,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Stack(
                                    children: [
                                      Text(
                                        _caseText,
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.londrinaSolid(
                                          fontSize: 13,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      AnimatedBuilder(
                                        animation: _charCount,
                                        builder: (context, _) {
                                          final visible = _caseText.substring(
                                            0,
                                            _charCount.value,
                                          );
                                          return Text(
                                            visible,
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.londrinaSolid(
                                              fontSize: 13,
                                              color: AppColors.primaryLight,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 90,
                  right: 180,
                  child: Image.asset(AppAssets.tutorialCaseTicket, width: 120),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

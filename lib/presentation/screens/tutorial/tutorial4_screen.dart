import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/typewriter_text.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';

class Tutorial4Screen extends StatefulWidget {
  const Tutorial4Screen({super.key});

  @override
  State<Tutorial4Screen> createState() => _Tutorial4ScreenState();
}

class _Tutorial4ScreenState extends State<Tutorial4Screen> {
  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();
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
          // Title
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Image.asset(AppAssets.tutorial4Title, width: 420),
            ),
          ),
          // Folder + display
          Positioned(
            left: MediaQuery.of(context).size.width * 0.15,
            top: MediaQuery.of(context).size.height * 0.20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BouncingButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TutorialCaseScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ShakeWidget(
                        delay: const Duration(seconds: 3),
                        child: Image.asset(
                          AppAssets.tutorial4Folder,
                          width: 250,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-6, -25),
                        child: Image.asset(
                          AppAssets.tutorial4FolderTitle,
                          width: 180,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -130,
                      child: AppAnimations.worriedWave(width: 220),
                    ),
                    Image.asset(AppAssets.tutorialDisplay, width: 350),
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: TypewriterText(
                          text:
                              'Select the CASE OF BEANIE: THE STOLEN PASS.\n\n'
                              'Oh noooo, that\'s my case! Let\'s investigate and find the culprit. '
                              'Please help me find out who did it.',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.londrinaSolid(
                            color: const Color(0xFF542E2E),
                            fontSize: 14,
                          ),
                          duration: const Duration(seconds: 7),
                          playAudio: true,
                          boldWords: const ["CASE OF BEANIE: THE STOLEN PASS"],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        ],
      ),
    );
  }
}

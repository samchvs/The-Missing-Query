import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial3_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';

class Tutorial2Screen extends StatefulWidget {
  const Tutorial2Screen({super.key});

  @override
  State<Tutorial2Screen> createState() => _Tutorial2ScreenState();
}

class _Tutorial2ScreenState extends State<Tutorial2Screen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.tutorial2Screen), context);
    precacheImage(const AssetImage(AppAssets.tutorial3Screen), context);
    for (var frame in AppAssets.dancingBroccoli) {
      precacheImage(AssetImage(frame), context);
    }
    for (var frame in AppAssets.dancingTomathomas) {
      precacheImage(AssetImage(frame), context);
    }
    for (var frame in AppAssets.dancingCarrotino) {
      precacheImage(AssetImage(frame), context);
    }
  }

  @override
  void initState() {
    super.initState();
    TutorialMusicController().play();
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const Tutorial3Screen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: Image.asset(
              AppAssets.tutorial2Screen,
              fit: BoxFit.fill,
              gaplessPlayback: true,
            ),
          ),

          // Dancingbroccoli Animation
          const Positioned(
            left: 110,
            bottom: 20,
            child: SpriteAnimator(
              frames: AppAssets.dancingBroccoli,
              width: 200,
              frameDuration: Duration(milliseconds: 150),
              fit: BoxFit.fill,
              loop: true,
            ),
          ),

          // Dancingtomathomas Animation
          const Positioned(
            right: 365,
            bottom: 90,
            child: SpriteAnimator(
              frames: AppAssets.dancingTomathomas,
              width: 200,
              frameDuration: Duration(milliseconds: 150),
              fit: BoxFit.fill,
              loop: true,
            ),
          ),

          // Hellobeanie Animation
          Positioned(
            right: 245,
            bottom: 15,
            child: AppAnimations.helloBeanie(
              width: 230,
              frameDuration: const Duration(milliseconds: 250),
            ),
          ),

          // Dancingcarrotino Animation
          const Positioned(
            right: 135,
            bottom: 85,
            child: SpriteAnimator(
              frames: AppAssets.dancingCarrotino,
              width: 200,
              frameDuration: Duration(milliseconds: 150),
              fit: BoxFit.fill,
              loop: true,
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

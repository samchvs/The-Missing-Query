import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case3_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';

class TutorialCase2Screen extends StatefulWidget {
  const TutorialCase2Screen({super.key});

  @override
  State<TutorialCase2Screen> createState() => _TutorialCase2ScreenState();
}

class _TutorialCase2ScreenState extends State<TutorialCase2Screen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Background
          const SpriteAnimator(
            frames: AppAssets.case2Screen,
            frameDuration: Duration(milliseconds: 150),
            fit: BoxFit.fill,
            loop: true,
          ),

          // Next Button
          Positioned(
            bottom: 22,
            right: 120,
            child: BouncingButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const TutorialCase3Screen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            child,
                  ),
                );
              },
              child: ShakeWidget(
                child: Image.asset(AppAssets.nextBtn, width: 80),
              ),
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

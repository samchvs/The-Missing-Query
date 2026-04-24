import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial3_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/app_animations.dart';

class Tutorial2Screen extends StatefulWidget {
  const Tutorial2Screen({super.key});

  @override
  State<Tutorial2Screen> createState() => _Tutorial2ScreenState();
}

class _Tutorial2ScreenState extends State<Tutorial2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const Tutorial3Screen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) => child,
                ),
              );
            },
            child: Image.asset(
              AppAssets.tutorial2Screen,
              fit: BoxFit.fill,
              gaplessPlayback: true,
            ),
          ),
          
          // Hellobeanie Animation
          Positioned(
            right: 260,
            bottom: 20,
            child: AppAnimations.helloBeanie(
              width: 230,
              frameDuration: const Duration(milliseconds: 250),
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

import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'tutorialCase3_screen.dart';

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
          Image.asset('assets/tutorialCase_screen.png', fit: BoxFit.fill),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset('assets/tutorialCase-title.png', width: 420),
            ),
          ),

          Positioned(
            top: 100,
            left: 40,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset('assets/tutorialCase2-desc.png', width: 620),
                  Positioned(
                    bottom: -2,
                    right: 30,
                    child: BouncingButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const TutorialCase3Screen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return child;
                            },
                          ),
                        );
                      },
                      child: Image.asset('assets/next-btn.png', width: 80),
                    ),
                  ),
                ],
              ),
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
                  child: Image.asset('assets/back-btn.png', width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    debugPrint('Home button pressed in TutorialCase2!');
                    Navigator.of(
                      context,
                    ).popUntil(ModalRoute.withName('/home'));
                  },
                  child: Image.asset('assets/home-btn.png', width: 50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

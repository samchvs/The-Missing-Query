import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'tutorial4_screen.dart';


class Tutorial3Screen extends StatefulWidget {
  const Tutorial3Screen({super.key});

  @override
  State<Tutorial3Screen> createState() => _Tutorial3ScreenState();
}

class _Tutorial3ScreenState extends State<Tutorial3Screen> {
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
                      const Tutorial4Screen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return child;
                  },
                ),
              );
            },
            child: Image.asset(
              'assets/tutorial3_screen.png',
              fit: BoxFit.fill,
              gaplessPlayback: true,
            ),
          ),
          
          // Navigation Buttons
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/back-btn.png',
                    width: 50,
                  ),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    debugPrint('Home button pressed in Tutorial3!');
                    Navigator.of(context).popUntil(ModalRoute.withName('/home'));
                  },
                  child: Image.asset(
                    'assets/home-btn.png',
                    width: 50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'splash_screen.dart';

class TutorialCase4Screen extends StatefulWidget {
  const TutorialCase4Screen({super.key});

  @override
  State<TutorialCase4Screen> createState() => _TutorialCase4ScreenState();
}

class _TutorialCase4ScreenState extends State<TutorialCase4Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/tutorialCase3_screen.png', fit: BoxFit.fill),

          // Back button
          Positioned(
            left: 20,
            top: 20,
            child: BouncingButton(
              onPressed: () => Navigator.pop(context),
              child: Image.asset('assets/back-btn.png', width: 50),
            ),
          ),
        ],
      ),
    );
  }
}

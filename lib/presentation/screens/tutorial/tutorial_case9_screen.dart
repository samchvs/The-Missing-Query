import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

class TutorialCase9Screen extends StatefulWidget {
  const TutorialCase9Screen({super.key});

  @override
  State<TutorialCase9Screen> createState() => _TutorialCase9ScreenState();
}

class _TutorialCase9ScreenState extends State<TutorialCase9Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), // Placeholder background
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Case 9!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              BouncingButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

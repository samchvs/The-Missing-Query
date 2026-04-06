import 'package:flutter/material.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/settings_screen.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: BouncingButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/back-btn.png',
                width: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

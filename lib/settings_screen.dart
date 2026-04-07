import 'package:flutter/material.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Track the currently active tab. Default is 'profile'
  String _activeTab = 'profile';

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
          Align(
            alignment: const Alignment(0.0, 0.4), // Adjust to move everything up or down
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/displaySettings.png',
                  width: 650,
                  fit: BoxFit.contain,
                ),
                
                // Draw ALL inactive tabs first (in the background, tinted)
                if (_activeTab != 'profile')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0),
                      child: Image.asset(
                        'assets/profile-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                        color: const Color(0xFFE2E2BE),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                if (_activeTab != 'audio')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/audio-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                        color: const Color(0xFFE2E2BE),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                if (_activeTab != 'leaderboard')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/leaderboard-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                        color: const Color(0xFFE2E2BE),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                if (_activeTab != 'about')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/about-tab.png', // Fallback to leaderboard if about doesn't exist, but assuming it does
                        width: 600, 
                        fit: BoxFit.contain,
                        color: const Color(0xFFE2E2BE),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),

                // Now draw the ACTIVE tab on TOP (drawn last = top layer)
                if (_activeTab == 'profile')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/profile-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (_activeTab == 'audio')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/audio-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (_activeTab == 'leaderboard')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/leaderboard-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (_activeTab == 'about')
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0.0, 0.0), 
                      child: Image.asset(
                        'assets/about-tab.png',
                        width: 600, 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // --------- TEXT BUTTONS ---------
                
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(-0.8, -0.8), 
                    child: BouncingButton(
                      onPressed: () {
                        setState(() { _activeTab = 'profile'; });
                        print("Profile text tab clicked");
                      },
                      child: const Text(
                        "PROFILE",
                        style: TextStyle(
                          color: Color(0xFF542E2E), 
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(-0.4, -0.8), 
                    child: BouncingButton(
                      onPressed: () {
                        setState(() { _activeTab = 'audio'; });
                        print("Audio text tab clicked");
                      },
                      child: const Text(
                        "AUDIO",
                        style: TextStyle(
                          color: Color(0xFF542E2E), 
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    // Y-axis stays -0.8 so it's perfectly aligned vertically
                    // Decrease X-axis to move it left (from 0.1 down to 0.0, or -0.1)
                    alignment: const Alignment(0.0, -0.8), 
                    child: BouncingButton(
                      onPressed: () {
                        setState(() { _activeTab = 'leaderboard'; });
                        print("Leaderboard text tab clicked");
                      },
                      child: const Text(
                        "LEADERBOARD",
                        style: TextStyle(
                          color: Color(0xFF542E2E), 
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    // Y-axis stays -0.8 so it's perfectly aligned vertically
                    // Using 0.45 gets you exactly in between 0.4 and 0.5!
                    alignment: const Alignment(0.42, -0.8), 
                    child: BouncingButton(
                      onPressed: () {
                        setState(() { _activeTab = 'about'; });
                        print("About text tab clicked");
                      },
                      child: const Text(
                        "ABOUT",
                        style: TextStyle(
                          color: Color(0xFF542E2E), 
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

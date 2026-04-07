import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'profile_tab.dart'; 

class SettingsScreen extends StatefulWidget {
  final String username;
  final String characterPath;
  final Function(String) onUsernameChanged;
  final Function(String) onCharacterChanged;

  const SettingsScreen({
    super.key, 
    required this.username, 
    required this.characterPath,
    required this.onUsernameChanged,
    required this.onCharacterChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeTab = 'profile';
  late String _localUsername;
  late String _localCharacterPath;

  @override
  void initState() {
    super.initState();
    _localUsername = widget.username;
    _localCharacterPath = widget.characterPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
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
            alignment: const Alignment(0.0, 0.4), 
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/displaySettings.png',
                  width: 650,
                  fit: BoxFit.contain,
                ),
                
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
                        'assets/about-tab.png', 
                        width: 600, 
                        fit: BoxFit.contain,
                        color: const Color(0xFFE2E2BE),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),

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
                // --------- ACTIVE TAB CONTENT AREA ---------
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0.0, 0.3), 
                    child: SizedBox(
                      width: 550, 
                      height: 250, 
                      child: Builder(
                        builder: (context) {
                          if (_activeTab == 'profile') {
                            return ProfileTab(
                              username: _localUsername, 
                              characterPath: _localCharacterPath,
                              onUsernameChanged: (newName) {
                                setState(() {
                                  _localUsername = newName;
                                });
                                widget.onUsernameChanged(newName);
                              },
                              onCharacterChanged: (newChar) {
                                setState(() {
                                  _localCharacterPath = newChar;
                                });
                                widget.onCharacterChanged(newChar);
                              }
                            );
                          }
                          return const Center(
                            child: Text(
                              "More tabs coming soon!",
                              style: TextStyle(
                                color: Colors.grey, 
                                fontSize: 18,
                              ),
                            )
                          );
                        }
                      ),
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

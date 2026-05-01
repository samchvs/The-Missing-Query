import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/screens/settings/profile_tab.dart';
import 'package:graphics_project/presentation/screens/settings/about_tab.dart';
import 'package:graphics_project/presentation/screens/settings/audio_tab.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  final String characterPath;
  final AuthController authController;
  final Function(String) onUsernameChanged;
  final Function(String) onCharacterChanged;

  const SettingsScreen({
    super.key,
    required this.username,
    required this.characterPath,
    required this.authController,
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
                image: AssetImage(AppAssets.settingsScreen),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(AppAssets.displaySettings, width: 650, fit: BoxFit.contain),
                if (_activeTab != 'profile')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppAssets.profileTab,
                        width: 600,
                        fit: BoxFit.contain,
                        color: AppColors.dimmedTab,
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                if (_activeTab != 'audio')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppAssets.audioTab,
                        width: 600,
                        fit: BoxFit.contain,
                        color: AppColors.dimmedTab,
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                if (_activeTab != 'leaderboard')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppAssets.leaderboardTab,
                        width: 600,
                        fit: BoxFit.contain,
                        color: AppColors.dimmedTab,
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                if (_activeTab != 'about')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppAssets.aboutTab,
                        width: 600,
                        fit: BoxFit.contain,
                        color: AppColors.dimmedTab,
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                // Active tabs
                if (_activeTab == 'profile')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(AppAssets.profileTab, width: 600, fit: BoxFit.contain),
                    ),
                  ),
                if (_activeTab == 'audio')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(AppAssets.audioTab, width: 600, fit: BoxFit.contain),
                    ),
                  ),
                if (_activeTab == 'leaderboard')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(AppAssets.leaderboardTab, width: 600, fit: BoxFit.contain),
                    ),
                  ),
                if (_activeTab == 'about')
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(AppAssets.aboutTab, width: 600, fit: BoxFit.contain),
                    ),
                  ),
                // Content area
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
                              authController: widget.authController,
                              onUsernameChanged: (newName) {
                                setState(() => _localUsername = newName);
                                widget.onUsernameChanged(newName);
                              },
                              onCharacterChanged: (newChar) {
                                setState(() => _localCharacterPath = newChar);
                                widget.onCharacterChanged(newChar);
                              },
                            );
                          }
                          if (_activeTab == 'about') {
                            return const AboutTab();
                          }
                          if (_activeTab == 'audio') {
                            return const AudioTab();
                          }
                          return const Center(
                            child: Text(
                              'More tabs coming soon!',
                              style: TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Tab buttons
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(-0.8, -0.8),
                    child: BouncingButton(
                      onPressed: () => setState(() => _activeTab = 'profile'),
                      child: const Text(
                        'PROFILE',
                        style: TextStyle(
                          color: AppColors.primary,
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
                      onPressed: () => setState(() => _activeTab = 'audio'),
                      child: const Text(
                        'AUDIO',
                        style: TextStyle(
                          color: AppColors.primary,
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
                      onPressed: () => setState(() => _activeTab = 'leaderboard'),
                      child: const Text(
                        'LEADERBOARD',
                        style: TextStyle(
                          color: AppColors.primary,
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
                      onPressed: () => setState(() => _activeTab = 'about'),
                      child: const Text(
                        'ABOUT',
                        style: TextStyle(
                          color: AppColors.primary,
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
          // Back Button
          Positioned(
            left: 20,
            top: 20,
            child: BouncingButton(
              onPressed: () => Navigator.pop(context),
              child: Image.asset(AppAssets.backBtn, width: 50),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/data/models/character_model.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/screens/settings/settings_screen.dart';
import 'package:graphics_project/presentation/screens/splash/splash_screen.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/controllers/home_music_controller.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';
import 'package:graphics_project/core/constants/app_routes.dart';
import 'package:graphics_project/presentation/screens/mystery/case_selection_screen.dart';
import 'package:graphics_project/presentation/controllers/gameplay_music_controller.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final AuthController authController;

  const HomeScreen({
    super.key,
    required this.username,
    required this.authController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  bool _isUserDisplayVisible = false;
  bool _isSignoutConfirmationVisible = false;
  bool _isQuitConfirmationVisible = false;
  late String _currentUsername;
  late String _currentCharacter;

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.username;
    _currentCharacter = widget.authController.currentCharacterPath;
    HomeMusicController().play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppRoutes.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    precacheImage(const AssetImage(AppAssets.homeScreen), context);
    precacheImage(const AssetImage(AppAssets.playBtn), context);
    precacheImage(const AssetImage(AppAssets.settingsBtn), context);
    precacheImage(const AssetImage(AppAssets.userIconBtn), context);
    precacheImage(const AssetImage(AppAssets.userDisplay), context);
    precacheImage(const AssetImage(AppAssets.innerUserDisplay), context);
    precacheImage(const AssetImage(AppAssets.signoutBtn), context);
    precacheImage(const AssetImage(AppAssets.noBtn), context);
    precacheImage(const AssetImage(AppAssets.yesBtn), context);
    precacheImage(const AssetImage(AppAssets.signoutDisplay), context);
    precacheImage(const AssetImage(AppAssets.quitDisplay), context);
    precacheImage(const AssetImage(AppAssets.settingsScreen), context);
  }

  @override
  void dispose() {
    AppRoutes.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    debugPrint("Returning to HomeScreen: Resuming home music.");
    GameplayMusicController().stop();
    HomeMusicController().play();
  }

  Future<void> _handleSignOut() async {
    await widget.authController.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) =>
            SplashScreen(authController: widget.authController),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.homeScreen, fit: BoxFit.fill, gaplessPlayback: true),
          // Settings Button
          Positioned(
            top: 20,
            left: 20,
            child: BouncingButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (_, _, _) => SettingsScreen(
                      username: _currentUsername,
                      characterPath: _currentCharacter,
                      authController: widget.authController,
                      onUsernameChanged: (newName) {
                        setState(() => _currentUsername = newName);
                      },
                      onCharacterChanged: (newChar) {
                        setState(() => _currentCharacter = newChar);
                      },
                    ),
                    transitionsBuilder: (_, animation, _, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Image.asset(AppAssets.settingsBtn, width: 50),
            ),
          ),
          // Welcome + User Icon
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'WELCOME, ',
                        style: TextStyle(color: AppColors.white),
                      ),
                      TextSpan(
                        text: '$_currentUsername!',
                        style: const TextStyle(color: AppColors.yellow),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                BouncingButton(
                  onPressed: () {
                    SFXController().playPopup();
                    setState(() => _isUserDisplayVisible = true);
                  },
                  child: Image.asset(AppAssets.userIconBtn, width: 50),
                ),
              ],
            ),
          ),
          // Play Button
          Align(
            alignment: const Alignment(0.0, 0.4),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: BouncingButton(
                onPressed: () {
                  HomeMusicController().stop();
                  GameplayMusicController().play();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      reverseTransitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, _, _) => const CaseSelectionScreen(),
                      transitionsBuilder: (_, animation, _, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: Image.asset(AppAssets.playBtn, width: 110),
              ),
            ),
          ),
          // Tutorial Button
          Align(
            alignment: const Alignment(0.0, 0.6),
            child: BouncingButton(
              onPressed: () {
                HomeMusicController().stop();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, _, _) => TutorialScreen(),
                    transitionsBuilder: (_, animation, _, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Image.asset(AppAssets.tutorialBtn, width: 140),
            ),
          ),
          // Quit Button
          Align(
            alignment: const Alignment(0.0, 0.8),
            child: BouncingButton(
              onPressed: () {
                SFXController().playPopup();
                setState(() => _isQuitConfirmationVisible = true);
              },
              child: Image.asset(AppAssets.quitBtn, width: 100),
            ),
          ),
          // User Display Overlay
          if (_isUserDisplayVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isUserDisplayVisible = false),
                child: Container(color: Colors.black54),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Stack(
                children: [
                  Image.asset(AppAssets.userDisplay, width: 250),
                  Positioned(
                    top: 30,
                    left: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(AppAssets.innerUserDisplay, width: 60),
                            Builder(
                              builder: (context) {
                                final config =
                                    CharacterDisplayConfig.homeConfigs
                                        .firstWhere(
                                          (c) => c.path == _currentCharacter,
                                          orElse: () => CharacterDisplayConfig
                                              .homeConfigs.first,
                                        );
                                return Image.asset(
                                  _currentCharacter,
                                  width: config.width,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Text(
                          _currentUsername,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: BouncingButton(
                        onPressed: () {
                          SFXController().playPopup();
                          setState(() {
                            _isUserDisplayVisible = false;
                            _isSignoutConfirmationVisible = true;
                          });
                        },
                        child: Image.asset(AppAssets.signoutBtn, width: 120),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Signout Confirmation
          if (_isSignoutConfirmationVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _isSignoutConfirmationVisible = false),
                child: Container(color: Colors.black87),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(AppAssets.signoutDisplay, width: 300),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BouncingButton(
                              onPressed: () => setState(
                                () => _isSignoutConfirmationVisible = false,
                              ),
                              child: Image.asset(AppAssets.noBtn, width: 120),
                            ),
                            const SizedBox(width: 5),
                            BouncingButton(
                              onPressed: _handleSignOut,
                              child: Image.asset(AppAssets.yesBtn, width: 120),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // Quit Confirmation
          if (_isQuitConfirmationVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _isQuitConfirmationVisible = false),
                child: Container(color: Colors.black87),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(AppAssets.quitDisplay, width: 300),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BouncingButton(
                              onPressed: () => setState(
                                () => _isQuitConfirmationVisible = false,
                              ),
                              child: Image.asset(AppAssets.noBtn, width: 120),
                            ),
                            const SizedBox(width: 5),
                            BouncingButton(
                              onPressed: () => SystemNavigator.pop(),
                              child: Image.asset(AppAssets.yesBtn, width: 120),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/screens/auth/login_screen.dart';
import 'package:graphics_project/presentation/screens/auth/signup_screen.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/controllers/home_music_controller.dart';

/// Splash screen — shown when navigating "back" from Home (sign-out / quit flow).
/// Offers return to username entry (which handles guest/login/signup routing).
class SplashScreen extends StatefulWidget {
  final AuthController authController;

  const SplashScreen({super.key, required this.authController});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    HomeMusicController().play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.loginScreen), context);
    precacheImage(const AssetImage(AppAssets.signupScreen), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.splashScreen),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Login Button
          Align(
            alignment: const Alignment(0.0, 0.4),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: BouncingButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, _, __) =>
                          LoginScreen(authController: widget.authController),
                      transitionsBuilder: (context, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: Image.asset(AppAssets.loginBtn, width: 170),
              ),
            ),
          ),
          // Signup Button
          Align(
            alignment: const Alignment(0.0, 0.7),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: BouncingButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, _, __) =>
                          SignupScreen(authController: widget.authController),
                      transitionsBuilder: (context, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: Image.asset(AppAssets.signupBtn, width: 170),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

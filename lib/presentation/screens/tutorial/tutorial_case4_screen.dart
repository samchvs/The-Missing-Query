import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/screens/tutorial/tutorial_case3_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';

class TutorialCase4Screen extends StatefulWidget {
  const TutorialCase4Screen({super.key});

  @override
  State<TutorialCase4Screen> createState() => _TutorialCase4ScreenState();
}

class _TutorialCase4ScreenState extends State<TutorialCase4Screen>
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  late Animation<double> _walkAnimation;
  late AnimationController _spriteController;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _walkAnimation = Tween<double>(begin: -0.6, end: 0.0).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeOut),
    );
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spriteController.stop();
        if (mounted) setState(() {});
      }
    });

    _walkController.forward();
  }

  @override
  void dispose() {
    _walkController.dispose();
    _spriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.tutorialCase4Screen, fit: BoxFit.fill),
          // Beanie Walking Animation
          AnimatedBuilder(
            animation: _walkAnimation,
            builder: (context, child) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double walkTranslation = _walkAnimation.value * screenWidth;
              return Transform.translate(
                offset: Offset(walkTranslation, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.45,
                      top: 120.0,
                    ),
                    child: AnimatedBuilder(
                      animation: _spriteController,
                      builder: (context, child) {
                        String currentImage;
                        double imageWidth;
                        if (_walkController.isCompleted) {
                          currentImage = AppAssets.sadBeanie;
                          imageWidth = 140;
                        } else {
                          currentImage = _spriteController.value < 0.5
                              ? AppAssets.beanieWalking1
                              : AppAssets.beanieWalking2;
                          imageWidth = 70;
                        }
                        return Transform.translate(
                          offset: Offset(
                            _walkController.isCompleted ? -50.0 : -30.0,
                            _walkController.isCompleted
                                ? -10.0
                                : -15 +
                                      (Curves.easeInOut.transform(
                                            (_spriteController.value * 2) % 1.0,
                                          ) *
                                          10),
                          ),
                          child: Image.asset(currentImage, width: imageWidth),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          // Navigation
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TutorialCase3Screen(),
                      ),
                    );
                  },
                  child: Image.asset(AppAssets.backBtn, width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    Navigator.of(context).popUntil(ModalRoute.withName('/home'));
                  },
                  child: Image.asset(AppAssets.homeBtn, width: 50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

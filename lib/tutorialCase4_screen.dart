import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'tutorialCase3_screen.dart';

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

    // Moves from off-screen left to target position
    _walkAnimation = Tween<double>(
      begin: -0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));

    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spriteController.stop();
        if (mounted) {
          setState(() {});
        }
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
          // Background image
          Image.asset('assets/tutorialCase4_screen.png', fit: BoxFit.fill),

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
                      left: screenWidth * 0.45, // Moved a bit left
                      top: 120.0, // Placeholder, user will adjust
                    ),
                    child: AnimatedBuilder(
                      animation: _spriteController,
                      builder: (context, child) {
                        String currentImage;
                        double imageWidth;
                        if (_walkController.isCompleted) {
                          currentImage = 'assets/sadBeanie.png';
                          imageWidth = 140;
                        } else {
                          currentImage = _spriteController.value < 0.5
                              ? 'assets/BeanieWalking1.png'
                              : 'assets/BeanieWalking2.png';
                          imageWidth = 70;
                        }
                        return Transform.translate(
                          offset: Offset(
                            _walkController.isCompleted ? -50.0 : -30.0, // -45 for stopped, -30 for walking
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

          // Back and Home buttons
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () {
                    // Navigate specifically to TutorialCase3
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TutorialCase3Screen(),
                      ),
                    );
                  },
                  child: Image.asset('assets/back-btn.png', width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    debugPrint('Home button pressed in TutorialCase4!');
                    Navigator.of(
                      context,
                    ).popUntil(ModalRoute.withName('/home'));
                  },
                  child: Image.asset('assets/home-btn.png', width: 50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

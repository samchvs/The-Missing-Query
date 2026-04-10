import 'package:flutter/material.dart';
import 'splash_screen.dart';

class TutorialCase3Screen extends StatefulWidget {
  const TutorialCase3Screen({super.key});

  @override
  State<TutorialCase3Screen> createState() => _TutorialCase3ScreenState();
}

class _TutorialCase3ScreenState extends State<TutorialCase3Screen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _walkController;
  late Animation<Offset> _walkAnimation;
  late AnimationController _spriteController;

  late AnimationController _hintController;
  late Animation<double> _hintOpacity;
  late Animation<Offset> _hintOffset;
  late Animation<double> _hintScale;

  bool _isQueryClicked = false;
  late AnimationController _userFadeController;
  late Animation<double> _userFadeAnimation;

  @override
  void initState() {
    super.initState();
    // Fade controller for tutorialCase3-pop
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2500, //Speed ng entry ni Beanie
      ),
    );

    // Moves from off-screen left to target position
    child:
    _walkAnimation = Tween<Offset>(
      begin: const Offset(
        -1.2,
        0.0,
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _walkController, curve: Curves.easeOut));

    // Start walk animation immediately
    _walkController.forward();

    // Controller sa pagwalk/pagpalit ng frames
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), 
    )..repeat();

    // Listener pagstop ni Beanie fade in ng tutorialCase3-pop
    _walkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _spriteController.stop();
        if (mounted) {
          _fadeController.forward(); 
          setState(() {}); 
        }
      }
    });

    // Mouse pointer
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _hintOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_hintController);

    //Position saan maggglide yung pointer 
    _hintOffset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: ConstantTween(const Offset(0, 40)),
        weight: 20,
      ), 
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 40), end: const Offset(20, -90)),
        weight: 40,
      ), 
      TweenSequenceItem(
        tween: ConstantTween(const Offset(20, -90)),
        weight: 40,
      ),
    ]).animate(_hintController);

    _hintScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 15),
    ]).animate(_hintController);

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isQueryClicked) {
        _hintController.repeat();
      }
    });

    // Fade controller for the userDisplay
    _userFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _userFadeAnimation = CurvedAnimation(
      parent: _userFadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _walkController.dispose();
    _spriteController.dispose();
    _hintController.dispose();
    _userFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/tutorialCase3_screen.png', fit: BoxFit.fill),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset('assets/tutorialCase3-title.png', width: 420),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(
                            20.0,
                            -10.0,
                          ), // Nudge right and up
                          child: BouncingButton(
                            onPressed: () {
                              debugPrint(
                                'Query button pressed in TutorialCase3!',
                              );
                              if (!_isQueryClicked) {
                                setState(() {
                                  _isQueryClicked = true;
                                });
                                _hintController.stop();
                                _userFadeController.forward();
                              }
                            },
                            child: Image.asset(
                              'assets/query-btn.png',
                              width: 100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: _isQueryClicked ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 600),
                          child: Image.asset(
                            'assets/tutorialCase3-pop.png',
                            width: 250,
                          ),
                        ),
                      ],
                    ),
                    // Mouse pointer hint
                    AnimatedBuilder(
                      animation: _hintController,
                      builder: (context, child) {
                        return AnimatedOpacity(
                          opacity: _isQueryClicked ? 0.0 : _hintOpacity.value,
                          duration: const Duration(milliseconds: 500),
                          child: Transform.translate(
                            offset: _hintOffset.value,
                            child: Transform.scale(
                              scale: _hintScale.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Image.asset('assets/mousePointer.png', width: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // sadBeanie
          SlideTransition(
            position: _walkAnimation,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 100.0, top: 90.0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: AnimatedBuilder(
                    animation: _spriteController,
                    builder: (context, child) {
                      String currentImage;
                      double imageWidth;
                      if (_walkController.isCompleted) {
                        currentImage = 'assets/sadBeanie.png';
                        imageWidth = 150;
                      } else {
                        currentImage = _spriteController.value < 0.5
                            ? 'assets/BeanieWalking1.png'
                            : 'assets/BeanieWalking2.png';
                        imageWidth = 70;
                      }
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            _walkController.isCompleted
                                ? 0
                                : -15 +
                                    (Curves.easeInOut
                                            .transform(
                                              (_spriteController.value * 2) % 1.0,
                                            )
                                            .abs() *
                                        -8),
                          ),
                          child: Image.asset(currentImage, width: imageWidth),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Dark overlay for focus/emphasis (placed here to dim everything beneath)
          IgnorePointer(
            ignoring: !_isQueryClicked,
            child: FadeTransition(
              opacity: _userFadeAnimation,
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),

          // tutorialQuery-display.png that appears after click (centered below title)
          IgnorePointer(
            ignoring: !_isQueryClicked,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0), // Nudge below title
                child: FadeTransition(
                  opacity: _userFadeAnimation,
                  child: Image.asset(
                    'assets/tutorialQuery-display.png',
                    width: 450,
                  ),
                ),
              ),
            ),
          ),

          // Navigation 
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () => Navigator.pop(context),
                  child: Image.asset('assets/back-btn.png', width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    debugPrint('Home button pressed in TutorialCase3!');
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

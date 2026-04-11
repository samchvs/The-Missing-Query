import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'splash_screen.dart';
import 'tutorial2_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  bool _showMeetButton = false;
  late AnimationController _hintController;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _hintController.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _hintController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/tutorial_screen.png',
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
          Positioned(
            left: 20,
            top: 20,
            child: Row(
              children: [
                BouncingButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back-btn.png', width: 50),
                ),
                const SizedBox(width: 15),
                BouncingButton(
                  onPressed: () {
                    debugPrint('Home button pressed in Tutorial!');
                    // Jump directly back to the Home screen
                    Navigator.of(
                      context,
                    ).popUntil(ModalRoute.withName('/home'));
                  },
                  child: Image.asset('assets/home-btn.png', width: 50),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/tutorialDisplay.png', width: 600),
                Positioned(
                  top: 35,
                  left: 0,
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, opacity, child) {
                      return Opacity(opacity: opacity, child: child);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "HEY THERE, DETECTIVE!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF542E2E),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: TypewriterText(
                            text:
                                "Welcome to your first investigation.\n"
                                "A case has just come in, and we need your help to solve it.\n"
                                "Don’t worry! you won’t be doing this alone.......",
                            style: GoogleFonts.londrinaSolid(
                              color: const Color(0xFF542E2E),
                              fontSize: 22,
                            ),
                            duration: const Duration(seconds: 1),
                            onFinished: () {
                              setState(() {
                                _showMeetButton = true;
                              });
                              _startHintTimer();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- Meet button ---
          if (_showMeetButton)
            Align(
              alignment: const Alignment(0.0, 0.85),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, opacity, child) {
                  return Opacity(opacity: opacity, child: child);
                },
                child: AnimatedBuilder(
                  animation: _hintController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -10 * _hintController.value,
                      ), // Slight jump up
                      child: child,
                    );
                  },
                  child: BouncingButton(
                    onPressed: () {
                      _hintController.stop();
                      _hintTimer?.cancel();
                      // Navigate to the second tutorial screen
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Tutorial2Screen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return child;
                              },
                        ),
                      );
                      debugPrint('Meet button pressed!');
                    },
                    child: Image.asset(
                      'assets/meet-btn.png',
                      width: 170, // Feel free to adjust the size if needed
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final VoidCallback? onFinished;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 3),
    this.onFinished,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onFinished != null) {
          widget.onFinished!();
        }
      }
    });

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Wait a brief moment when the screen loads before it starts "typing"
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (BuildContext context, Widget? child) {
        String visibleString = widget.text.substring(0, _characterCount.value);
        return Text(
          visibleString,
          style: widget.style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

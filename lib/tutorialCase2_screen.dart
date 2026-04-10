import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'tutorialCase3_screen.dart';

class TutorialCase2Screen extends StatefulWidget {
  const TutorialCase2Screen({super.key});

  @override
  State<TutorialCase2Screen> createState() => _TutorialCase2ScreenState();
}

class _TutorialCase2ScreenState extends State<TutorialCase2Screen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/tutorialCase_screen.png', fit: BoxFit.fill),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset('assets/tutorialCase-title.png', width: 420),
            ),
          ),

          Positioned(
            top: 100,
            left: 40,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset('assets/tutorialCase2-desc.png', width: 620),
                  Positioned(
                    bottom: -2,
                    right: 30,
                    child: BouncingButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const TutorialCase3Screen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return child;
                            },
                          ),
                        );
                      },
                      child: ShakeWidget(
                        child: Image.asset('assets/next-btn.png', width: 80),
                      ),
                    ),
                  ),
                ],
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
                    debugPrint('Home button pressed in TutorialCase2!');
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

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const ShakeWidget({
    super.key,
    required this.child,
    this.delay = const Duration(seconds: 3),
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _controller.forward(from: 0.0);
          }
        });
      }
    });

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

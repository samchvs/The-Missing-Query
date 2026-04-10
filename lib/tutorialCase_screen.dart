import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'tutorialCase2_screen.dart';

class TutorialCaseScreen extends StatefulWidget {
  const TutorialCaseScreen({super.key});

  @override
  State<TutorialCaseScreen> createState() => _TutorialCaseScreenState();
}

class _TutorialCaseScreenState extends State<TutorialCaseScreen>
    with TickerProviderStateMixin {
  static const String _caseText =
      'Beanie\u2019s VIP meal card was stolen just before lunch.\n'
      'Several students were seen in the hallway at the same time, each with their own story.\n'
      'Beanie needs to figure out who had the opportunity and motive to use the card.';

  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<int> _charCount;
  late Animation<double> _characterFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _charCount = StepTween(
      begin: 0,
      end: _caseText.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _characterFade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Trigger fade-in when typing finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeController.forward();
      }
    });

    // Short delay before typing starts
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset('assets/caseDisplay-box.png', width: 650),
                  Positioned(
                    right: -80,
                    top: 120,
                    child: FadeTransition(
                      opacity: _characterFade,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Background character
                          Positioned(
                            top: -60,
                            child: Image.asset(
                              'assets/Tomathomas.png',
                              width: 80,
                            ),
                          ),
                          // Foreground display
                          Image.asset('assets/userDisplay.png', width: 100),
                          // 'click NEXT' text overlay
                          Positioned.fill(
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(text: 'click '),
                                    TextSpan(
                                      text: 'NEXT',
                                      style: GoogleFonts.londrinaSolid(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                style: GoogleFonts.londrinaSolid(
                                  color: const Color(0xFF542E2E),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 70,
                    right: 120,
                    child: FadeTransition(
                      opacity: _characterFade,
                      child: BouncingButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const TutorialCase2Screen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
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
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 160.0,
                          vertical: 90.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Case Description',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 25,
                                color: const Color(0xFF452525),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Typewriter body text
                            Stack(
                              children: [
                                Text(
                                  _caseText,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.londrinaSolid(
                                    fontSize: 16,
                                    color: Colors.transparent,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _charCount,
                                  builder: (context, _) {
                                    final visible = _caseText.substring(
                                      0,
                                      _charCount.value,
                                    );
                                    return Text(
                                      visible,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.londrinaSolid(
                                        fontSize: 16,
                                        color: const Color(0xFFE34747),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 98,
            right: 180,
            child: Image.asset('assets/tutorialCase-ticket.png', width: 150),
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
                    debugPrint('Home button pressed in TutorialCase!');
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

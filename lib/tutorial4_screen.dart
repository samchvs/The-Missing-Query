import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tutorialCase_screen.dart';

class Tutorial4Screen extends StatefulWidget {
  const Tutorial4Screen({super.key});

  @override
  State<Tutorial4Screen> createState() => _Tutorial4ScreenState();
}

class _Tutorial4ScreenState extends State<Tutorial4Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/tutorial3_screen.png',
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),

          // Title Image
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Image.asset(
                'assets/tutorial4-title.png',
                width: 420, 
              ),
            ),
          ),

          // Folder and Folder Title
          Positioned(
            left: MediaQuery.of(context).size.width * 0.15,
            top: MediaQuery.of(context).size.height * 0.20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BouncingButton(
                  onPressed: () {
                    debugPrint('Folder clicked! Navigating to TutorialCaseScreen.');
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const TutorialCaseScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ShakeWidget(
                        delay: const Duration(seconds: 3),
                        child: Image.asset(
                          'assets/tutorial4-folder.png',
                          width: 250, 
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(
                          -6,
                          -25,
                        ), 
                        child: Image.asset(
                          'assets/tutorial4-folderTitle.png',
                          width: 180, 
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                // Tutorial Display
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Sad Beanie
                    Positioned(
                      top: -100,
                      child: Image.asset('assets/sadBeanie.png', width: 150),
                    ),
                    Image.asset('assets/tutorialDisplay.png', width: 350),
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: TypewriterText(
                          text:
                              "Select the CASE OF BEANIE: THE STOLEN PASS.\n\n"
                              "Oh noooo, that’s my case! Let’s investigate and find the culprit. Please help me find out who did it.",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.londrinaSolid(
                            color: const Color(0xFF542E2E),
                            fontSize: 14,
                          ),
                          duration: const Duration(seconds: 7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Buttons
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
                    debugPrint('Home button pressed in Tutorial4!');
                    // Jump directly back to the Home screen
                    Navigator.of(context).popUntil(ModalRoute.withName('/home'));
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

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final TextAlign? textAlign;
  final VoidCallback? onFinished;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
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

    // Start typing after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
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
        int count = _characterCount.value;

        // Bolding logic: The case name is from index 11 to 44
        const int boldStart = 11;
        const int boldEnd = 44;

        String s1 = widget.text.substring(
          0,
          count >= boldStart ? boldStart : count,
        );
        String s2 = count > boldStart
            ? widget.text.substring(
                boldStart,
                count >= boldEnd ? boldEnd : count,
              )
            : "";
        String s3 = count > boldEnd
            ? widget.text.substring(boldEnd, count)
            : "";

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: s1, style: widget.style),
              TextSpan(
                text: s2,
                style: widget.style?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: s3, style: widget.style),
            ],
          ),
          textAlign: widget.textAlign ?? TextAlign.center,
        );
      },
    );
  }
}

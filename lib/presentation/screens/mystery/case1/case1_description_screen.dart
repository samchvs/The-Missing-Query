import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_map_screen.dart';
import 'package:graphics_project/core/utils/page_transitions.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

// --- TYPEWRITER TEXT ---
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration speed;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.speed = const Duration(milliseconds: 30),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  Timer? _timer;
  final AudioPlayer _typePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();

    setState(() {
      _displayedText = "";
    });

    int index = 0;

    _typePlayer.stop();
    _typePlayer.setReleaseMode(ReleaseMode.loop);
    _typePlayer.play(
      AssetSource('mystery/audio/typing.mp3'),
      volume: SFXController().volume * 0.25,
    );

    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        _typePlayer.stop();
        return;
      }

      if (index >= widget.text.length) {
        timer.cancel();
        _typePlayer.stop();
        _typePlayer.setReleaseMode(ReleaseMode.release);
        return;
      }

      setState(() {
        _displayedText += widget.text[index];
      });

      index++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _typePlayer.stop();
    _typePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      textAlign: widget.textAlign,
      style: widget.style,
    );
  }
}

// --- FRAME BY FRAME ANIMATION ---
class FrameAnimation extends StatefulWidget {
  final List<String> frames;
  final double width;
  final double height;
  final Duration speed;

  const FrameAnimation({
    super.key,
    required this.frames,
    this.width = double.infinity,
    this.height = double.infinity,
    this.speed = const Duration(milliseconds: 120),
  });

  @override
  State<FrameAnimation> createState() => _FrameAnimationState();
}

class _FrameAnimationState extends State<FrameAnimation> {
  int _currentFrame = 0;
  int _direction = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final frame in widget.frames) {
        if (!mounted) return;
        await precacheImage(AssetImage(frame), context);
      }

      if (!mounted || widget.frames.isEmpty) return;

      _timer = Timer.periodic(widget.speed, (timer) {
        if (!mounted) return;

        setState(() {
          _currentFrame += _direction;

          if (_currentFrame >= widget.frames.length - 1) {
            _currentFrame = widget.frames.length - 1;
            _direction = -1;
          } else if (_currentFrame <= 0) {
            _currentFrame = 0;
            _direction = 1;
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Image.asset(
      widget.frames[_currentFrame],
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
    );
  }
}

// --- PROFILE PAGE FLIP ---
class ProfileFlipCard extends StatelessWidget {
  final int pageNumber;

  const ProfileFlipCard({super.key, required this.pageNumber});

  List<String> _getFramesForPage(int pageNumber) {
    const int frameCount = 16;

    return List.generate(
      frameCount,
      (index) =>
          'assets/mystery/character_profile/character_profile$pageNumber/${index + 1}.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(pageNumber),
      tween: Tween<double>(begin: math.pi, end: 0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final isUnder = value > math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(value),
          child: isUnder
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: child,
                )
              : child,
        );
      },
      child: FrameAnimation(
        key: ValueKey('frame_animation_$pageNumber'),
        frames: _getFramesForPage(pageNumber),
        speed: const Duration(milliseconds: 80),
      ),
    );
  }
}

// --- MAIN SCREEN ---
class CaseDescription1 extends StatefulWidget {
  const CaseDescription1({super.key});

  @override
  State<CaseDescription1> createState() => _CaseDescription1State();
}

class _CaseDescription1State extends State<CaseDescription1>
    with CaseScreenHelper {
  int _currentPage = 0;
  bool _isBoardVisible = false;
  bool _isProfileVisible = false;
  int _profilePageNumber = 1;

  final List<String> _descriptions = [
    "The moonlight reflects off the marble floors of the Giovanni Grand Gallery. Tomorrow, the \"Orient Seas\" collection is supposed to save a 100-year-old dynasty from the brink of bankruptcy. At the center of the room sits the Pearl of the Orient Sea, a gem rumored to be worth more than the building itself. But at 3:00 AM, the vault was opened. The Pearl is gone. ",
    "As the lead digital investigator, you've been hired to solve the crime. Your job is to trace the digital footprints, cross-reference the suspects, and recover the Pearl.",
  ];

  @override
  void initState() {
    super.initState();
    initCaseHelper();
  }

  void _handleNext() {
    if (!_isBoardVisible && !_isProfileVisible) {
      if (_currentPage < _descriptions.length - 1) {
        setState(() => _currentPage++);
        return;
      } else {
        setState(() => _isBoardVisible = true);
        return;
      }
    }

    if (_isBoardVisible && !_isProfileVisible) {
      setState(() {
        _isProfileVisible = true;
        _profilePageNumber = 1;
      });
      return;
    }

    if (_profilePageNumber < 3) {
      setState(() => _profilePageNumber++);
      return;
    }

    Navigator.push(context, fadeSlideRoute(const CaseMap1()));
  }

  void _handleBack() {
    setState(() {
      if (_isProfileVisible) {
        if (_profilePageNumber > 1) {
          _profilePageNumber--;
        } else {
          _isProfileVisible = false;
          _isBoardVisible = true;
        }
      } else if (_isBoardVisible) {
        _isBoardVisible = false;
        _currentPage = _descriptions.length - 1;
      } else if (_currentPage > 0) {
        _currentPage--;
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _handleHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    disposeCaseHelper();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF330066), Color(0xFF6A008A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _isProfileVisible
                      ? _buildProfileView(
                          width,
                          height,
                          key: ValueKey('profile$_profilePageNumber'),
                        )
                      : _buildDescriptionView(
                          width,
                          height,
                          key: ValueKey(
                            _isBoardVisible ? 'board' : 'desc$_currentPage',
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 15,
                left: 20,
                right: 20,
                child: SizedBox(
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => onButtonTap(_handleBack),
                              child: Image.asset(
                                'assets/mystery/back_button.png',
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () =>
                                  onButtonTap(() => _handleHome(context)),
                              child: Image.asset(
                                'assets/mystery/home_button.png',
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/mystery/pearl.png', height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(double width, double height, {Key? key}) {
    return Align(
      key: key,
      alignment: Alignment.topCenter,
      child: Container(
        width: width * 0.90,
        height: height * 0.75,
        margin: const EdgeInsets.only(top: 50),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ProfileFlipCard(pageNumber: _profilePageNumber),
            Positioned(
              right: 75,
              bottom: 2,
              child: InkWell(
                onTap: () => onButtonTap(_handleNext),
                child: Image.asset(
                  'assets/mystery/next_button.png',
                  height: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionView(double width, double height, {Key? key}) {
    return Center(
      key: key,
      child: Container(
        width: width * 0.90,
        height: height * 0.90,
        margin: const EdgeInsets.only(top: 0, bottom: 20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _isBoardVisible
                    ? 'assets/mystery/case_bg1.png'
                    : 'assets/mystery/case_bg.png',
                fit: BoxFit.fill,
              ),
            ),
            if (!_isBoardVisible)
              Positioned(
                left: width * 0.18,
                right: width * 0.18,
                top: height * 0.35,
                bottom: height * 0.12,
                child: Column(
                  children: [
                    const Text(
                      "CASE DESCRIPTION:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4A2C15),
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Expanded(
                      child: SingleChildScrollView(
                        child: TypewriterText(
                          key: ValueKey(_currentPage),
                          text: _descriptions[_currentPage],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Londrina Solid',
                            color: Color(0xFFB71C1C),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              right: 120,
              bottom: 40,
              child: InkWell(
                onTap: () => onButtonTap(_handleNext),
                child: Image.asset(
                  'assets/mystery/next_button.png',
                  height: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

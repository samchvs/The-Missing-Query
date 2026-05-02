import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/screens/mystery/case2/case2_map_screen.dart';
import 'package:graphics_project/core/utils/page_transitions.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';
import 'package:audioplayers/audioplayers.dart';

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
    _typePlayer.play(AssetSource('mystery/audio/typing.mp3'), volume: 0.25);

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

// --- SMOOTH FRAME BY FRAME ANIMATION ---
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
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _prepareFrames();
  }

  @override
  void didUpdateWidget(covariant FrameAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames != widget.frames) {
      _timer?.cancel();
      _currentFrame = 0;
      _direction = 1;
      _isReady = false;
      _prepareFrames();
    }
  }

  Future<void> _prepareFrames() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final frame in widget.frames) {
        await precacheImage(AssetImage(frame), context);
      }

      if (!mounted || widget.frames.isEmpty) return;

      setState(() {
        _isReady = true;
      });

      _timer = Timer.periodic(widget.speed, (timer) {
        if (!mounted) return;

        setState(() {
          if (widget.frames.length == 1) return;

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

    if (!_isReady) {
      return Image.asset(
        widget.frames.first,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
      );
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
          'assets/mystery/Case2/character_profile$pageNumber/${index + 1}.png',
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
        speed: const Duration(milliseconds: 120),
      ),
    );
  }
}

// --- MAIN SCREEN ---
class CaseDescription2 extends StatefulWidget {
  const CaseDescription2({super.key});

  @override
  State<CaseDescription2> createState() => _CaseDescription2State();
}

class _CaseDescription2State extends State<CaseDescription2>
    with CaseScreenHelper {
  int _currentPage = 0;
  bool _isBoardVisible = false;
  bool _isProfileVisible = false;
  int _profilePageNumber = 1;

  final List<String> _descriptions = [
    "At 03:00 AM on March 31st, the Global Innovators Scholarship committee received a silent alert for Jamie, the schoolâ€™s top programmer and frontrunner for the \$50,000 award.",
    "Jamieâ€™s submission, Project Chimeraâ€”a revolutionary security protocolâ€”was found to be identical to an old GitHub repository from 2023. Jamie claims he has been framed, but the universityâ€™s internal server shows Jamie's account performed the upload.",
    "As the lead digital auditor, youâ€™ve been brought in to solve the crime. Your job is to query the server logs, cross-reference the physical access data, and find the ghost in the machine before a brilliant career is deleted forever.",
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

    Navigator.push(context, fadeSlideRoute(const CaseMap2()));
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
                  height: 70,
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
                      Image.asset(
                        'assets/mystery/Case2/chimera.png',
                        height: 80,
                      ),
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
                    ? 'assets/mystery/Case2/case_board2.png'
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

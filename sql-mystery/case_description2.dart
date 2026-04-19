import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'case_map2.dart';
import 'page_transition.dart';

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
    _displayedText = "";
    int index = 0;

    _timer = Timer.periodic(widget.speed, (timer) {
      if (index < widget.text.length) {
        setState(() {
          _displayedText += widget.text[index];
          index++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

// --- PROFILE PAGE FLIP ---
class ProfileFlipCard extends StatelessWidget {
  final int pageNumber;

  const ProfileFlipCard({super.key, required this.pageNumber});

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
      child: Image.asset(
        'assets/Case2/character_profile$pageNumber.png',
        fit: BoxFit.contain,
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

class _CaseDescription2State extends State<CaseDescription2> {
  int _currentPage = 0;
  bool _isBoardVisible = false;
  bool _isProfileVisible = false;
  int _profilePageNumber = 1;

  // DESCRIPTION
  final List<String> _descriptions = [
    "At 03:00 AM on March 31st, the Global Innovators Scholarship committee received a silent alert for Jamie, the school’s top programmer and frontrunner for the \$50,000 award.",
    "Jamie’s submission, Project Chimera—a revolutionary security protocol—was found to be identical to an old GitHub repository from 2023. Jamie claims he has been framed, but the university’s internal server shows Jamie's account performed the upload.",
    "As the lead digital auditor, you’ve been brought in to solve the crime. Your job is to query the server logs, cross-reference the physical access data, and find the ghost in the machine before a brilliant career is deleted forever.",
  ];

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
              // CONTENT FIRST
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

              // HEADER LAST
              Positioned(
                top: 0,
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
                              onTap: _handleBack,
                              child: Image.asset(
                                'assets/back_button.png',
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () => _handleHome(context),
                              child: Image.asset(
                                'assets/home_button.png',
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/Case2/chimera.png', height: 50),
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
                onTap: _handleNext,
                child: Image.asset('assets/next_button.png', height: 28),
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
                    ? 'assets/case_bg1.png' // board
                    : 'assets/case_bg.png', // description
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
                onTap: _handleNext,
                child: Image.asset('assets/next_button.png', height: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

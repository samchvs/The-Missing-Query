import 'dart:async';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final Widget nextScreen;

  const LoadingScreen({super.key, required this.nextScreen});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentFrameIndex = 0;
  int _loopsLeft = 1; // Total 2 loops
  final List<int> _frameSequence = [1, 2, 3, 4, 5, 4, 3, 2, 1];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all frames for smooth animation
    for (int frame in [1, 2, 3, 4, 5]) {
      precacheImage(AssetImage('assets/loading-screen/$frame.png'), context);
    }
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
      if (!mounted) return;
      if (_currentFrameIndex < _frameSequence.length - 1) {
        setState(() {
          _currentFrameIndex++;
        });
      } else {
        if (_loopsLeft > 0) {
          setState(() {
            _currentFrameIndex = 0;
            _loopsLeft--;
          });
        } else {
          _timer?.cancel();
          // Navigate to the next screen
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (context, _, _) => widget.nextScreen,
              transitionsBuilder: (context, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        }
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/loading-screen/${_frameSequence[_currentFrameIndex]}.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

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
        if (!mounted) return;
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

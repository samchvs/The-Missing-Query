import 'package:flutter/material.dart';

/// A reusable widget that animates a sequence of images (frames).
class SpriteAnimator extends StatefulWidget {
  final List<String> frames;
  final Duration frameDuration;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool loop;
  final VoidCallback? onComplete;

  const SpriteAnimator({
    super.key,
    required this.frames,
    this.frameDuration = const Duration(milliseconds: 100),
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.loop = true,
    this.onComplete,
  });

  @override
  State<SpriteAnimator> createState() => _SpriteAnimatorState();
}

class _SpriteAnimatorState extends State<SpriteAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration * widget.frames.length,
    );

    _animation = IntTween(begin: 0, end: widget.frames.length - 1)
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SpriteAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames != widget.frames || 
        oldWidget.frameDuration != widget.frameDuration ||
        oldWidget.loop != widget.loop) {
      _controller.duration = widget.frameDuration * widget.frames.length;
      _animation = IntTween(begin: 0, end: widget.frames.length - 1)
          .animate(_controller);
          
      if (widget.loop) {
        _controller.repeat();
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Image.asset(
          widget.frames[_animation.value],
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          // Pre-cache next frame to prevent flickering
          gaplessPlayback: true, 
        );
      },
    );
  }
}

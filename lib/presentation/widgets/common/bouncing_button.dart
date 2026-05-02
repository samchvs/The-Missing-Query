import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';

/// A reusable button that scales down slightly on press (bounce effect).
/// Used across all screens in the app.
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const BouncingButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _controller.forward();
        SFXController().playButton();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(scale: 1 - _controller.value, child: widget.child),
    );
  }
}

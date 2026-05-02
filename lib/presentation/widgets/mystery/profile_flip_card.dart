import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/widgets/mystery/frame_animation.dart';

class ProfileFlipCard extends StatelessWidget {
  final int pageNumber;
  final String assetPrefix;

  const ProfileFlipCard({
    super.key,
    required this.pageNumber,
    this.assetPrefix = 'assets/mystery/character_profile',
  });

  List<String> _getFramesForPage(int pageNumber) {
    const int frameCount = 16;

    return List.generate(
      frameCount,
      (index) =>
          '$assetPrefix/character_profile$pageNumber/${index + 1}.png',
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

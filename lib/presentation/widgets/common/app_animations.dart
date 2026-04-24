import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';

/// This file contains all the pre-defined animations for the app.
/// You can add more animations here as future needs arise.
class AppAnimations {
  
  /// The 8-frame animation for Beanie.
  /// Call this with: AppAnimations.helloBeanie()
  static Widget helloBeanie({double? width, double? height, Duration? frameDuration}) {
    return SpriteAnimator(
      frames: AppAssets.helloBeanieFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 120),
    );
  }

  /// 2-frame walking animation for Beanie
  /// Call this with: AppAnimations.walkingBeanie()
  static Widget walkingBeanie({double? width, double? height, Duration? frameDuration}) {
    return SpriteAnimator(
      frames: AppAssets.walkingBeanieFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 250),
    );
  }

  /// The 8-frame worried animation for Beanie.
  /// Call this with: AppAnimations.worriedBeanie()
  static Widget worriedBeanie({
    double? width,
    double? height,
    Duration? frameDuration,
  }) {
    return SpriteAnimator(
      frames: AppAssets.worriedBeanieFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 120),
    );
  }

  // Add future animations here...
}

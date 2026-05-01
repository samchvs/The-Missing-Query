import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/widgets/common/sprite_animator.dart';

/// This file contains all the pre-defined animations for the app.
/// You can add more animations here as future needs arise.
class AppAnimations {
  
  /// The 8-frame animation for Beanie.
  /// Call this with: AppAnimations.helloBeanie()
  static Widget helloBeanie({Key? key, double? width, double? height, Duration? frameDuration}) {
    return SpriteAnimator(
      key: key,
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

  /// 17-frame spinning animation for Beanie
  static Widget spinningBeanie({
    Key? key,
    double? width,
    double? height,
    Duration? frameDuration,
    bool loop = true,
  }) {
    return SpriteAnimator(
      key: key,
      frames: AppAssets.spinningBeanieFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 200),
      loop: loop,
    );
  }

  /// 16-frame talking animation for Beanie
  static Widget talkingBeanie({
    Key? key,
    double? width,
    double? height,
    Duration? frameDuration,
    bool loop = true,
  }) {
    return SpriteAnimator(
      key: key,
      frames: AppAssets.talkingBeanieFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 120),
      loop: loop,
    );
  }

  /// 10-frame waving animation for Carrotino
  static Widget wavingCarrotino({
    Key? key,
    double? width,
    double? height,
    Duration? frameDuration,
    bool loop = true,
  }) {
    return SpriteAnimator(
      key: key,
      frames: AppAssets.wavingCarrotinoFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 120),
      loop: loop,
    );
  }

  /// 19-frame talking animation for Carrotino
  static Widget talkingCarrotino({
    Key? key,
    double? width,
    double? height,
    Duration? frameDuration,
    bool loop = true,
  }) {
    return SpriteAnimator(
      key: key,
      frames: AppAssets.talkingCarrotinoFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 120),
      loop: loop,
    );
  }

  /// 12-frame worried waving animation for Beanie
  static Widget worriedWave({
    double? width,
    double? height,
    Duration? frameDuration,
    bool loop = true,
  }) {
    return SpriteAnimator(
      frames: AppAssets.worriedWaveFrames,
      width: width,
      height: height,
      frameDuration: frameDuration ?? const Duration(milliseconds: 120),
      loop: loop,
    );
  }
}

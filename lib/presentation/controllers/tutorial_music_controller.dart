import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/controllers/home_music_controller.dart';

class TutorialMusicController with WidgetsBindingObserver {
  static final TutorialMusicController _instance = TutorialMusicController._internal();
  factory TutorialMusicController() => _instance;
  TutorialMusicController._internal() {
    WidgetsBinding.instance.addObserver(this);
    // Set global context for better device compatibility and allow mixing audio
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none, // Background music focus mode
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback, // Valid with mixWithOthers
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isExpectedToPlay = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isExpectedToPlay && _audioPlayer.state != PlayerState.playing) {
        _audioPlayer.resume();
      }
    }
  }

  static void goHome(BuildContext context) {
    TutorialMusicController().stop();
    HomeMusicController().play();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  double _volume = 1.0;

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
  }

  double get volume => _volume;

  Future<void> play() async {
    try {
      _isExpectedToPlay = true;
      if (_audioPlayer.state == PlayerState.playing) return;
      debugPrint("Attempting to play tutorial music: ${AppAssets.tutorialMusic}");
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume); 
      
      // Small delay to ensure player is ready
      await Future.delayed(const Duration(milliseconds: 200));
      
      await _audioPlayer.play(AssetSource(AppAssets.tutorialMusic));
      debugPrint("Tutorial music play command sent successfully.");
    } catch (e) {
      debugPrint("Error playing tutorial music: $e");
    }
  }

  Future<void> stop() async {
    try {
      _isExpectedToPlay = false;
      await _audioPlayer.stop();
    } catch (e) {
      // Silence errors
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
  }
}

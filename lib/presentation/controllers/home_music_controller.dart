import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMusicController with WidgetsBindingObserver {
  static final HomeMusicController _instance = HomeMusicController._internal();
  factory HomeMusicController() => _instance;

  HomeMusicController._internal() {
    WidgetsBinding.instance.addObserver(this);
    // Audio context is shared via AudioPlayer.global, 
    // but we can ensure it's set if this is the first controller initialized.
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none, // Allow SFX to play on top without ducking
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('music_volume') ?? 1.0;
    await _audioPlayer.setVolume(_volume);
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

  double _volume = 1.0;

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', volume);
  }

  double get volume => _volume;

  Future<void> play() async {
    try {
      _isExpectedToPlay = true;
      
      // If it's already playing, we don't want to restart it from the beginning
      if (_audioPlayer.state == PlayerState.playing) {
        debugPrint("Home music is already playing. Skipping play command.");
        return;
      }
      
      debugPrint("Attempting to play/resume home music: ${AppAssets.homeMusic}");
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume); 
      
      // We use play() which will start from the beginning if stopped, 
      // or we can use resume() if it was just paused.
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(AssetSource(AppAssets.homeMusic));
      }
      
      debugPrint("Home music play/resume command sent successfully.");
    } catch (e) {
      debugPrint("Error playing home music: $e");
    }
  }

  Future<void> stop() async {
    try {
      _isExpectedToPlay = false;
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping home music: $e");
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/lives_controller.dart';

mixin CaseScreenHelper<T extends StatefulWidget> on State<T> {
  final AudioPlayer voicePlayer = AudioPlayer();
  final AudioPlayer feedbackPlayer = AudioPlayer();
  final AudioPlayer buttonPlayer = AudioPlayer();
  final LivesController livesManager = LivesController.instance;

  bool get hasLives => livesManager.currentLives > 0;

  void initCaseHelper() {
    livesManager.addListener(_refreshLives);
    _configureAudioPlayers();
  }

  Future<void> _configureAudioPlayers() async {
    await voicePlayer.setReleaseMode(ReleaseMode.stop);
    await feedbackPlayer.setReleaseMode(ReleaseMode.stop);
    await buttonPlayer.setReleaseMode(ReleaseMode.stop);

    await voicePlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await feedbackPlayer.setPlayerMode(PlayerMode.lowLatency);
    await buttonPlayer.setPlayerMode(PlayerMode.lowLatency);

    await voicePlayer.setVolume(1.0);
    await feedbackPlayer.setVolume(1.0);
    await buttonPlayer.setVolume(1.0);
  }

  void disposeCaseHelper() {
    livesManager.removeListener(_refreshLives);
    voicePlayer.dispose();
    feedbackPlayer.dispose();
    buttonPlayer.dispose();
  }

  void _refreshLives() {
    if (mounted) setState(() {});
  }

  Future<void> playClueSound(String audioPath) async {
    try {
      await voicePlayer.stop();
      await voicePlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint('Clue sound error: $e');
    }
  }

  Future<void> stopClueSound() async {
    await voicePlayer.stop();
  }

  Future<void> playCorrectSound() async {
    await feedbackPlayer.stop();
    await feedbackPlayer.play(AssetSource('mystery/audio/correct.mp3'));
  }

  Future<void> playWrongSound() async {
    await feedbackPlayer.stop();
    await feedbackPlayer.play(AssetSource('mystery/audio/wrong.wav'));
  }

  Future<void> playButtonSound() async {
    try {
      await buttonPlayer.stop();
      await buttonPlayer.play(AssetSource('mystery/audio/button.mp3'));
    } catch (e) {
      debugPrint('Button sound error: $e');
    }
  }

  Future<void> onButtonTap(VoidCallback action) async {
    await playButtonSound();
    if (!mounted) return;
    action();
  }

  void showNoLivesPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1B3D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'OUT OF LIVES',
                  style: TextStyle(
                    fontFamily: 'Londrina Solid',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  livesManager.isFull
                      ? 'Your lives are full.'
                      : 'Wait ${livesManager.formattedCountdown} for the next heart.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () async {
                    await playButtonSound();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'Londrina Solid',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAlreadySolvedPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1B3D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'QUERY SOLVED',
                  style: TextStyle(
                    fontFamily: 'Londrina Solid',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You have already answered this guide question.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () async {
                    await playButtonSound();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'Londrina Solid',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

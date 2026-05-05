import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/presentation/controllers/lives_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:graphics_project/presentation/controllers/gameplay_music_controller.dart';

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
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
        var dialog = Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
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
          ),
        );
        return dialog;
      },
    );
  }

  Future<void> showCutscene({
    required String videoAsset,
    required VoidCallback onFinished,
  }) async {
    // Pause gameplay music
    await GameplayMusicController().stop();

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: Duration.zero,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _CutscenePlayerDialog(
          videoAsset: videoAsset,
          onFinished: () async {
            // Resume gameplay music
            await GameplayMusicController().play();
            onFinished();
          },
        );
      },
    );
  }

  void showCaseSolvedDialog({
    required String title,
    required String message,
    required VoidCallback onOkPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
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
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Londrina Solid',
                      fontSize: 24,
                      color: Color(0xFFFFD54F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Consolas',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onOkPressed();
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
          ),
        );
      },
    );
  }
}

class _CutscenePlayerDialog extends StatefulWidget {
  final String videoAsset;
  final VoidCallback onFinished;

  const _CutscenePlayerDialog({
    required this.videoAsset,
    required this.onFinished,
  });

  @override
  State<_CutscenePlayerDialog> createState() => _CutscenePlayerDialogState();
}

class _CutscenePlayerDialogState extends State<_CutscenePlayerDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              _controller.play();
            }
          })
          .catchError((error) {
            debugPrint("Video Player Error: $error");
            if (mounted) {
              widget.onFinished(); // Skip if it fails to load
            }
          });

    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          !_controller.value.isPlaying &&
          _controller.value.position >= _controller.value.duration) {
        if (!_isFadingOut) {
          setState(() {
            _isFadingOut = true;
          });
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              widget.onFinished();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: (_isInitialized && !_isFadingOut) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          /*
          // Temporary Skip Button
          if (_isInitialized && !_isFadingOut)
            Positioned(
              bottom: 40,
              right: 40,
              child: InkWell(
                onTap: () {
                  _controller.seekTo(_controller.value.duration);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SKIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Londrina Solid',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.fast_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          */
        ],
      ),
    );
  }
}

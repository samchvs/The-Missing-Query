import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';


class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final TextAlign? textAlign;
  final VoidCallback? onFinished;
  final bool playAudio;

  final List<String>? boldWords;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.duration = const Duration(seconds: 3),
    this.onFinished,
    this.boldWords,
    this.playAudio = false,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _audioPlayer.stop();
        widget.onFinished?.call();
      }
    });

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted) {
        if (widget.playAudio) {
          _audioPlayer.setReleaseMode(ReleaseMode.loop);
          _audioPlayer.setVolume(SFXController().volume);
          _audioPlayer.play(AssetSource(AppAssets.typewriterAudio));
        }
        _controller.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stop audio if the screen is no longer the top-most route (e.g. navigated away)
    final bool isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isCurrent) {
      _audioPlayer.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (BuildContext context, Widget? child) {
        final int count = _characterCount.value;
        final String visibleText = widget.text.substring(0, count);

        if (widget.boldWords == null || widget.boldWords!.isEmpty) {
          return Text(
            visibleText,
            style: widget.style,
            textAlign: widget.textAlign ?? TextAlign.center,
          );
        }

        // Build rich text by highlighting specific words
        List<TextSpan> spans = [];
        // Simple word-based highlighting
        // Note: For a more complex approach, regex would be better
        // but this works for specific unique names.
        
        int currentPos = 0;
        while (currentPos < visibleText.length) {
          int nextBoldStart = -1;
          String? foundWord;

          for (final word in widget.boldWords!) {
            int index = widget.text.indexOf(word, currentPos);
            if (index != -1 && (nextBoldStart == -1 || index < nextBoldStart)) {
              nextBoldStart = index;
              foundWord = word;
            }
          }

          if (nextBoldStart != -1 && nextBoldStart < count) {
            // Add text before the bold word
            if (nextBoldStart > currentPos) {
              spans.add(TextSpan(
                text: widget.text.substring(currentPos, nextBoldStart),
                style: widget.style,
              ));
            }

            // Add the bold word (or partial bold word if still typing)
            int boldEnd = nextBoldStart + foundWord!.length;
            int visibleBoldEnd = count < boldEnd ? count : boldEnd;
            
            spans.add(TextSpan(
              text: widget.text.substring(nextBoldStart, visibleBoldEnd),
              style: widget.style?.copyWith(fontWeight: FontWeight.bold),
            ));

            currentPos = visibleBoldEnd;
          } else {
            // No more bold words in the remaining visible text
            spans.add(TextSpan(
              text: widget.text.substring(currentPos, count),
              style: widget.style,
            ));
            break;
          }
        }

        return Text.rich(
          TextSpan(children: spans),
          textAlign: widget.textAlign ?? TextAlign.center,
        );
      },
    );
  }
}

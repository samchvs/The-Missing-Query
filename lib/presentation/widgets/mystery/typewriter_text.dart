import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration speed;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.speed = const Duration(milliseconds: 30),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  Timer? _timer;
  final AudioPlayer _typePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();

    setState(() {
      _displayedText = "";
    });

    int index = 0;

    _typePlayer.stop();
    _typePlayer.setReleaseMode(ReleaseMode.loop);
    _typePlayer.play(AssetSource('mystery/audio/typing.mp3'), volume: 0.25);

    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        _typePlayer.stop();
        return;
      }

      if (index >= widget.text.length) {
        timer.cancel();
        _typePlayer.stop();
        _typePlayer.setReleaseMode(ReleaseMode.release);
        return;
      }

      setState(() {
        _displayedText += widget.text[index];
      });

      index++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _typePlayer.stop();
    _typePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      textAlign: widget.textAlign,
      style: widget.style,
    );
  }
}

import 'package:flutter/material.dart';

/// Typewriter effect text widget. Animates characters one by one over [duration].
/// Calls [onFinished] when the full text has been revealed.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final TextAlign? textAlign;
  final VoidCallback? onFinished;

  /// Set [boldRange] to highlight a substring in bold during reveal.
  /// Provide [boldStart] and [boldEnd] as character indices into [text].
  final int? boldStart;
  final int? boldEnd;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.duration = const Duration(seconds: 3),
    this.onFinished,
    this.boldStart,
    this.boldEnd,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
      }
    });

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (BuildContext context, Widget? child) {
        final int count = _characterCount.value;
        final int? boldStart = widget.boldStart;
        final int? boldEnd = widget.boldEnd;

        // If bold range is provided, render with inline bold segment
        if (boldStart != null && boldEnd != null) {
          final String s1 = widget.text.substring(
            0,
            count >= boldStart ? boldStart : count,
          );
          final String s2 = count > boldStart
              ? widget.text.substring(boldStart, count >= boldEnd ? boldEnd : count)
              : '';
          final String s3 = count > boldEnd
              ? widget.text.substring(boldEnd, count)
              : '';

          return Text.rich(
            TextSpan(
              children: [
                TextSpan(text: s1, style: widget.style),
                TextSpan(
                  text: s2,
                  style: widget.style?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: s3, style: widget.style),
              ],
            ),
            textAlign: widget.textAlign ?? TextAlign.center,
          );
        }

        // Default: plain typewriter
        final String visible = widget.text.substring(0, count);
        return Text(
          visible,
          style: widget.style,
          textAlign: widget.textAlign ?? TextAlign.center,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/presentation/controllers/sfx_controller.dart';
import 'package:graphics_project/presentation/controllers/home_music_controller.dart';
import 'package:graphics_project/presentation/controllers/tutorial_music_controller.dart';
import 'package:graphics_project/presentation/controllers/gameplay_music_controller.dart';

class AudioTab extends StatefulWidget {
  const AudioTab({super.key});

  @override
  State<AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<AudioTab> {
  double _musicVolume = HomeMusicController().volume;
  double _sfxVolume = SFXController().volume;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sound Row
          _buildGameSlider(
            label: 'Sound',
            icon: Icons.volume_up_rounded,
            value: _sfxVolume,
            thumbColor: const Color(0xFF2E7D32), // Dark Green
            onChanged: (val) {
              setState(() => _sfxVolume = val);
              SFXController().setVolume(val);
            },
            onChangeEnd: (val) => SFXController().playButton(),
          ),
          const SizedBox(height: 20),
          _buildGameSlider(
            label: 'Music',
            icon: Icons.music_note_rounded,
            value: _musicVolume,
            thumbColor: const Color(0xFF006064), 
            onChanged: (val) {
              setState(() => _musicVolume = val);
              HomeMusicController().setVolume(val);
              TutorialMusicController().setVolume(val);
              GameplayMusicController().setVolume(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameSlider({
    required String label,
    required IconData icon,
    required double value,
    required Color thumbColor,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC80),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4E342E), size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.londrinaSolid(
                  color: const Color(0xFF4E342E),
                  fontWeight: FontWeight.w900,
                  fontSize: 22, 
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '0',
          style: GoogleFonts.londrinaSolid(
            color: const Color(0xFF4E342E),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 22,
              activeTrackColor: const Color(0xFFE0E0E0),
              inactiveTrackColor: const Color(0xFFE0E0E0),
              thumbColor: thumbColor,
              trackShape: _CustomTrackShape(),
              thumbShape: _PillThumbShape(color: thumbColor),
              overlayColor: Colors.transparent,
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
        Text(
          '100',
          style: GoogleFonts.londrinaSolid(
            color: const Color(0xFF4E342E),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint = Paint()
      ..color = const Color(0xFFBCAAA4) 
      ..style = PaintingStyle.fill;

    final Paint inactivePaint = Paint()
      ..color = const Color(0xFFE0E0E0) 
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = const Color(0xFFFFB300) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final RRect fullRRect = RRect.fromRectAndRadius(trackRect, const Radius.circular(15));
    
    context.canvas.drawRRect(fullRRect, inactivePaint);

    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    context.canvas.save();
    context.canvas.clipRRect(fullRRect);
    context.canvas.drawRect(activeRect, activePaint);
    context.canvas.restore();

      
    context.canvas.drawRRect(fullRRect, borderPaint);
  }
}
class _PillThumbShape extends SliderComponentShape {
  final Color color;
  const _PillThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 35);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Paint thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF263238).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Rect rect = Rect.fromCenter(center: center, width: 22, height: 35);
    final RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    context.canvas.drawRRect(rRect, thumbPaint);
    context.canvas.drawRRect(rRect, borderPaint);
  }
}


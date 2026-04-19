import 'package:flutter/material.dart';
import 'page_transition.dart';
import 'comlab_screen.dart';
import 'gym_screen.dart';
import 'it_screen.dart';
import 'icto_screen.dart';
import 'dean_screen.dart';

// --- FLOATING ANIMATION ---
class FloatingBubble extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const FloatingBubble({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.offset = 8.0,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.offset * _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// --- GLOWING MAP LABEL ---
class GlowingMapLabel extends StatefulWidget {
  final String asset;
  final double width;
  final VoidCallback onTap;

  const GlowingMapLabel({
    super.key,
    required this.asset,
    required this.width,
    required this.onTap,
  });

  @override
  State<GlowingMapLabel> createState() => _GlowingMapLabelState();
}

class _GlowingMapLabelState extends State<GlowingMapLabel> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isActive => _isHovered || _isPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: _isActive ? 1.08 : 1.0,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withOpacity(0.7),
                        blurRadius: 28,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: const Color(0xFF6A008A).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Image.asset(
              widget.asset,
              width: widget.width,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

// --- MAP SCREEN ---
class CaseMap2 extends StatelessWidget {
  const CaseMap2 ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset('assets/Case2/map2.png', fit: BoxFit.cover),
              ),

              Positioned(
                top: constraints.maxHeight * 0.23,
                left: constraints.maxWidth * 0.11,
                child: _buildMapLabel(
                  context,
                  'assets/Case2/comlab.png',
                  100,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.15,
                left: constraints.maxWidth * 0.31,
                child: _buildMapLabel(context, 'assets/Case2/icto.png', 105),
              ),
              Positioned(
                top: constraints.maxHeight * 0.42,
                left: constraints.maxWidth * 0.56,
                child: _buildMapLabel(context, 'assets/Case2/it.png', 110),
              ),
              Positioned(
                top: constraints.maxHeight * 0.70,
                left: constraints.maxWidth * 0.32,
                child: _buildMapLabel(context, 'assets/Case2/gym.png', 105),
              ),
              Positioned(
                top: constraints.maxHeight * 0.42,
                left: constraints.maxWidth * 0.77,
                child: _buildMapLabel(context, 'assets/Case2/dean.png', 105),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.asset(
                                    'assets/back_button.png',
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () => Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  ),
                                  child: Image.asset(
                                    'assets/home_button.png',
                                    height: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: Row(
                              children: [
                                Image.asset('assets/notebook.png', height: 50),
                                const SizedBox(width: 10),
                                _buildHUDItem('assets/lives.png', 'FULL'),
                                const SizedBox(width: 10),
                                _buildHUDItem(
                                  'assets/points.png',
                                  '1000 POINTS',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapLabel(BuildContext context, String asset, double width) {
    return FloatingBubble(
      child: GlowingMapLabel(
        asset: asset,
        width: width,
        onTap: () {
          if (asset.contains('comlab')) {
            Navigator.push(context, fadeRoute(const ComlabScreen()));
          } else if (asset.contains('gym')) {
            Navigator.push(context, fadeRoute(const GymScreen()));
          } else if (asset.contains('it')) {
            Navigator.push(context, fadeRoute(const ITScreen()));
          } else if (asset.contains('icto')) {
            Navigator.push(context, fadeRoute(const IctoScreen()));
          } else if (asset.contains('dean')) {
            Navigator.push(context, fadeRoute(const DeanScreen()));
          } else {
            debugPrint("Location tapped: $asset");
          }
        },
      ),
    );
  }

  Widget _buildHUDItem(String asset, String label) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(asset, height: 50),
        Positioned(
          right: 25,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4A2C15),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:graphics_project/core/utils/page_transitions.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_bank_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_cell_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_lowe_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_skyline_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_cordova_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_hospital_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_huang_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_logistics_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_waste_corp_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_city_police_screen.dart';
import 'package:graphics_project/presentation/controllers/lives_controller.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';

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
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
                        blurRadius: 28,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: const Color(0xFF6A008A).withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
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

class CaseMap3 extends StatefulWidget {
  const CaseMap3({super.key});

  @override
  State<CaseMap3> createState() => _CaseMap3State();
}

class _CaseMap3State extends State<CaseMap3> with CaseScreenHelper {
  final LivesController _livesController = LivesController.instance;

  @override
  void initState() {
    super.initState();
    initCaseHelper();
    _livesController.addListener(_refresh);
  }

  @override
  void dispose() {
    disposeCaseHelper();
    _livesController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showLivesPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Lives',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void dialogRefresh() => setDialogState(() {});

            _livesController.addListener(dialogRefresh);

            return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {
                _livesController.removeListener(dialogRefresh);
              },
              child: GestureDetector(
                onTap: () {
                  _livesController.removeListener(dialogRefresh);
                  Navigator.pop(context);
                },
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/mystery/lives_counter.png',
                            width: MediaQuery.of(context).size.width * 0.40,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 10,
                            right: 20,
                            child: InkWell(
                              onTap: () async {
                                await playButtonSound();
                                _livesController.removeListener(dialogRefresh);
                                if (context.mounted) Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/mystery/close_button.png',
                                height: 20,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 80,
                                  left: 0,
                                  right: 10,
                                  child: Center(
                                    child: Text(
                                      '${_livesController.currentLives}',
                                      style: const TextStyle(
                                        fontFamily: 'Luckiest Guy',
                                        fontSize: 23,
                                        color: Color(0xFFF8F3D4),
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2, 2),
                                            blurRadius: 0,
                                            color: Color(0xFF5A2E2E),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 33,
                                  left: 90,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      _livesController.isFull
                                          ? 'FULL'
                                          : _livesController.formattedCountdown,
                                      style: const TextStyle(
                                        fontFamily: 'Luckiest Guy',
                                        fontSize: 18,
                                        color: Color(0xFFF8F3D4),
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2, 2),
                                            blurRadius: 0,
                                            color: Color(0xFF5A2E2E),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
            );
          },
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/mystery/Case3/map3.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.18,
                left: constraints.maxWidth * 0.15,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/skyline.png',
                  100,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.08,
                left: constraints.maxWidth * 0.35,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/huang.png',
                  80,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.30,
                left: constraints.maxWidth * 0.37,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/city_police.png',
                  100,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.50,
                left: constraints.maxWidth * 0.53,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/bank.png',
                  100,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.27,
                left: constraints.maxWidth * 0.75,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/logistics.png',
                  100,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.48,
                left: constraints.maxWidth * 0.25,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/cordova.png',
                  90,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.60,
                left: constraints.maxWidth * 0.38,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/hospital.png',
                  95,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.78,
                left: constraints.maxWidth * 0.50,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/lowe.png',
                  85,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.52,
                left: constraints.maxWidth * 0.82,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/cell.png',
                  80,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.65,
                left: constraints.maxWidth * 0.65,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/Case3/waste_corp.png',
                  110,
                ),
              ),
              Positioned(
                top: 15,
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
                                  onTap: () =>
                                      onButtonTap(() => Navigator.pop(context)),
                                  child: Image.asset(
                                    'assets/mystery/back_button.png',
                                    height: 40,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () => onButtonTap(() {
                                    Navigator.popUntil(
                                      context,
                                      (route) => route.isFirst,
                                    );
                                  }),
                                  child: Image.asset(
                                    'assets/mystery/home_button.png',
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
                                Image.asset(
                                  'assets/mystery/notebook.png',
                                  height: 50,
                                ),
                                const SizedBox(width: 10),
                                _buildLivesHUDItem(context),
                                const SizedBox(width: 10),
                                _buildHUDItem(
                                  'assets/mystery/points.png',
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
        onTap: () => onButtonTap(() {
          if (asset.contains('bank')) {
            Navigator.push(context, fadeRoute(const BankScreen()));
          } else if (asset.contains('cell')) {
            Navigator.push(context, fadeRoute(const CellScreen()));
          } else if (asset.contains('lowe')) {
            Navigator.push(context, fadeRoute(const LoweScreen()));
          } else if (asset.contains('skyline')) {
            Navigator.push(context, fadeRoute(const SkylineScreen()));
          } else if (asset.contains('cordova')) {
            Navigator.push(context, fadeRoute(const CordovaScreen()));
          } else if (asset.contains('hospital')) {
            Navigator.push(context, fadeRoute(const HospitalScreen()));
          } else if (asset.contains('huang')) {
            Navigator.push(context, fadeRoute(const HuangScreen()));
          } else if (asset.contains('logistics')) {
            Navigator.push(context, fadeRoute(const LogisticsScreen()));
          } else if (asset.contains('waste_corp')) {
            Navigator.push(context, fadeRoute(const WasteCorpScreen()));
          } else if (asset.contains('city_police')) {
            Navigator.push(context, fadeRoute(const CityPoliceScreen()));
          } else {
            debugPrint("Location tapped: $asset");
          }
        }),
      ),
    );
  }

  Widget _buildLivesHUDItem(BuildContext context) {
    return GestureDetector(
      onTap: () => onButtonTap(() => _showLivesPopup(context)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/mystery/lives.png', height: 50),
          Positioned(
            right: 13,
            child: Text(
              '${_livesController.currentLives} lives',
              style: const TextStyle(
                color: Color(0xFF4A2C15),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

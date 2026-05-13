// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:graphics_project/core/utils/page_transitions.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_exhibition_hall_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_viore_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_back_alley_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_pearl_district_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_the_loupe_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_police_station_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_municipal_screen.dart';
import 'package:graphics_project/presentation/controllers/lives_controller.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';
import 'package:graphics_project/presentation/controllers/points_controller.dart';
import 'package:graphics_project/presentation/widgets/common/shake_widget.dart';
import 'package:graphics_project/presentation/screens/mystery/case_selection_screen.dart';
import 'package:graphics_project/presentation/widgets/mystery/diary_popup.dart';
import 'package:graphics_project/presentation/controllers/diary_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';

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

class CaseMap1 extends StatefulWidget {
  final bool showSolvedDialog;
  const CaseMap1({super.key, this.showSolvedDialog = false});

  @override
  State<CaseMap1> createState() => _CaseMap1State();
}

class _CaseMap1State extends State<CaseMap1> with CaseScreenHelper {
  final LivesController _livesController = LivesController.instance;
  bool _isPoliceStationUnlocked = false;
  late final DiaryController _diaryController;

  @override
  void initState() {
    super.initState();
    initCaseHelper();
    PointsController.instance.setActiveCase('case1');
    _livesController.addListener(_refresh);
    _checkPoliceStationStatus();

    if (widget.showSolvedDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            showCaseSolvedDialog(
              title: 'CONGRATULATIONS!',
              message:
                  'Case 1 is officially resolved. New leads have opened up in Case 2. Report to the next scene to continue.',
              onOkPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CaseSelectionScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            );
          }
        });
      });
    }
    final userId = context.read<AuthController>().currentUser!.id;
    _diaryController = DiaryController(caseKey: 'case1', userId: userId);
  }

  Future<void> _checkPoliceStationStatus() async {
    if (!mounted) return;
    
    // We can rely on points which are synchronized from the database.
    // 5 locations * 80 points = 400 points required to unlock the Police Station.
    final case1Points = PointsController.instance.getPointsForCase('case1');

    if (mounted) {
      setState(() {
        _isPoliceStationUnlocked = case1Points >= 400;
      });
    }
  }

  @override
  void dispose() {
    disposeCaseHelper();
    _livesController.removeListener(_refresh);
    _diaryController.dispose();
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
        late VoidCallback dialogRefresh;
        bool listenerAdded = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogRefresh = () => setDialogState(() {});
            if (!listenerAdded) {
              _livesController.addListener(dialogRefresh);
              listenerAdded = true;
            }
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
                                  top: 70,
                                  left: 0,
                                  right: 10,
                                  child: Center(
                                    child: Text(
                                      '${_livesController.currentLives}',
                                      style: const TextStyle(
                                        fontFamily: 'Londrina Solid',
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
                                        fontFamily: 'Londrina Solid',
                                        fontSize: 18,
                                        color: Color(0xFF5A2E2E),
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
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/mystery/map1.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.21,
                left: constraints.maxWidth * 0.21,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/exhibition_hall.png',
                  120,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.30,
                left: constraints.maxWidth * 0.48,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/viore_hq.png',
                  115,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.20,
                left: constraints.maxWidth * 0.65,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/back_alley.png',
                  100,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.60,
                left: constraints.maxWidth * 0.18,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/municipal.png',
                  115,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.70,
                left: constraints.maxWidth * 0.39,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/the_loupe.png',
                  95,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.46,
                left: constraints.maxWidth * 0.69,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/insurance.png',
                  115,
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.75,
                left: constraints.maxWidth * 0.74,
                child: _buildMapLabel(
                  context,
                  'assets/mystery/police_station.png',
                  110,
                  isLocked: !_isPoliceStationUnlocked,
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
                                GestureDetector(
                                  onTap: () {
                                    showDiaryPopup(
                                      context,
                                      controller: _diaryController,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/mystery/notebook.png',
                                    height: 50,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildLivesHUDItem(context),
                                const SizedBox(width: 10),
                                ListenableBuilder(
                                  listenable: PointsController.instance,
                                  builder: (context, _) {
                                    return _buildHUDItem(
                                      'assets/mystery/points.png',
                                      '${PointsController.instance.currentPoints} POINTS',
                                    );
                                  },
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

  Widget _buildMapLabel(
    BuildContext context,
    String asset,
    double width, {
    bool isLocked = false,
  }) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (isLocked)
          Positioned(
            bottom: -15,
            child: ShakeWidget(
              delay: const Duration(seconds: 1),
              child: const Icon(
                Icons.lock,
                color: Colors.yellow,
                size: 100,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        FloatingBubble(
          child: GlowingMapLabel(
            asset: asset,
            width: width,
            onTap: () => onButtonTap(() {
              if (isLocked) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Location locked. Please clear the remaining areas first.',
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (asset.contains('exhibition_hall')) {
                Navigator.push(
                  context,
                  fadeRoute(const ExhibitionHallScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else if (asset.contains('viore_hq')) {
                Navigator.push(
                  context,
                  fadeRoute(const VioreHqScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else if (asset.contains('back_alley')) {
                Navigator.push(
                  context,
                  fadeRoute(const BackAlleyScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else if (asset.contains('insurance')) {
                Navigator.push(
                  context,
                  fadeRoute(const PearlDistrictScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else if (asset.contains('the_loupe')) {
                Navigator.push(
                  context,
                  fadeRoute(const LoupeScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else if (asset.contains('police_station')) {
                Navigator.push(
                  context,
                  fadeRoute(const PoliceStationScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else if (asset.contains('municipal')) {
                Navigator.push(
                  context,
                  fadeRoute(const MunicipalScreen()),
                ).then((_) => _checkPoliceStationStatus());
              } else {
                debugPrint("Location tapped: $asset");
              }
            }),
          ),
        ),
      ],
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

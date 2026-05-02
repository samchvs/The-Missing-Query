import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/domain/usecases/simple_sql_engine.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';

class LoweScreen extends StatefulWidget {
  const LoweScreen({super.key});

  @override
  State<LoweScreen> createState() => _LoweScreenState();
}

class _LoweScreenState extends State<LoweScreen> with CaseScreenHelper {
  bool isQueryVisible = false;
  bool isTableVisible = false;
  bool isQuestionVisible = false;
  bool isCorrectVisible = false;
  bool isWrongVisible = false;

  String? activeInvestigationText;
  Duration? activeTypingDuration;

  bool get _hasLives => hasLives;

  final TextEditingController _sqlController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _sqlScrollController = ScrollController();

  final List<String> _headers = const [
    'log_id',
    'user_code',
    'action',
    'entry_time',
    'exit_time',
  ];

  final List<List<String>> _smartHomeLogs = [
    ['L-5001', 'VIRGINIA_01', 'UNLOCK', '7:30', 'NULL'],
    ['L-5002', 'MARK_LOWE_01', 'UNLOCK', '8:00', '8:15'],
    ['L-5003', 'SERVICE_MAID', 'UNLOCK', '9:00', '11:30'],
    ['L-5004', 'VIRGINIA_01', 'LOCK', '11:35', 'NULL'],
    ['L-5005', 'MAIL_CARRIER', 'UNLOCK_GATE', '12:10', '12:12'],
    ['L-5006', 'VIRGINIA_01', 'UNLOCK', '12:45', 'NULL'],
    ['L-5007', 'LOYD_SHAW_GUEST', 'UNLOCK', '13:30', 'NULL'],
    ['L-5008', 'VIRGINIA_01', 'LOCK', '13:35', 'NULL'],
    ['L-5009', 'SMART_HVAC', 'SYSTEM_ADJUST', '13:50', 'NULL'],
    ['L-5010', 'SMART_SENSORS', 'MOTION_LIVING_RM', '14:05', '14:15'],
    ['L-5011', 'UNKNOWN_BIO', 'OVERRIDE_REAR_DOOR', '14:20', '14:35'],
    ['L-5012', 'SMART_SENSORS', 'MOTION_GARAGE', '14:36', '14:40'],
    ['L-5013', 'MARK_LOWE_01', 'UNLOCK_GARAGE', '14:41', 'NULL'],
    ['L-5014', 'PD_MASTER_KEY', 'EMERGENCY_ENTRY', '14:46', 'NULL'],
    ['L-5015', 'SMART_SENSORS', 'MOTION_FOYER', '14:47', '15:00'],
    ['L-5016', 'FORENSIC_TEAM', 'UNLOCK', '15:30', '18:00'],
    ['L-5017', 'MARK_LOWE_01', 'LOCK_ALL', '18:05', 'NULL'],
    ['L-5018', 'SMART_LIGHTS', 'SCHEDULE_ON', '19:00', 'NULL'],
    ['L-5019', 'SMART_SENSORS', 'MOTION_KITCHEN', '19:15', '19:20'],
    ['L-5020', 'MARK_LOWE_01', 'UNLOCK', '20:10', '20:15'],
    ['L-5021', 'SECURITY_MONITOR', 'SYSTEM_ARM', '21:00', 'NULL'],
    ['L-5022', 'SMART_SENSORS', 'MOTION_PERIMETER', '22:15', '22:18'],
    ['L-5023', 'UNKNOWN_USER', 'FAILED_ATTEMPT', '23:45', 'NULL'],
    ['L-5024', 'SMART_LIGHTS', 'SCHEDULE_OFF', '0:00', 'NULL'],
    ['L-5025', 'SYSTEM_REBOOT', 'AUTO_MAINTENANCE', '3:00', '3:05'],
  ];

  late final SimpleSqlEngine _sqlEngine;
  List<Map<String, String>> _allLedgerMaps = [];
  List<Map<String, String>> _filteredLedgerMaps = [];
  List<String> _visibleHeaders = [];

  @override
  void initState() {
    super.initState();

    initCaseHelper();

    _allLedgerMaps = _smartHomeLogs.map((row) {
      return {
        'log_id': row[0],
        'user_code': row[1],
        'action': row[2],
        'entry_time': row[3],
        'exit_time': row[4],
      };
    }).toList();

    _sqlEngine = SimpleSqlEngine(
      tableName: 'smart_home_logs',
      headers: _headers,
      rows: _allLedgerMaps,
      numericColumns: const {},
    );

    _filteredLedgerMaps = List.from(_allLedgerMaps);
    _visibleHeaders = List.from(_headers);

    _sqlController.addListener(() {
      if (mounted) setState(() {});
    });

    _answerController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    disposeCaseHelper();
    _sqlController.dispose();
    _answerController.dispose();
    _sqlScrollController.dispose();
    super.dispose();
  }

  String _normalizeAnswer(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(', AND ', ', ')
        .replaceAll(' AND ', ', ')
        .replaceAll('PHP', '')
        .replaceAll('â‚±', '')
        .replaceAll('\$', '')
        .replaceAll(',', '');
  }

  bool _isLoweCorrectAnswer(String input) {
    final normalized = _normalizeAnswer(input);

    const acceptedAnswers = {
      'OVERRIDE_REAR_DOOR 14:20 REAR DOOR',
      'OVERRIDE REAR DOOR 14:20 REAR DOOR',
      'UNKNOWN_BIO OVERRIDE_REAR_DOOR 14:20 REAR DOOR',
      'UNKNOWN BIO OVERRIDE REAR DOOR 14:20 REAR DOOR',
      'REAR DOOR',
      'THE REAR DOOR',
    };

    return acceptedAnswers.contains(normalized);
  }

  void _submitAnswer() async {
    if (!_hasLives) {
      setState(() {
        isQuestionVisible = false;
      });
      showNoLivesPopup();
      return;
    }

    if (_isLoweCorrectAnswer(_answerController.text)) {
      await playCorrectSound();
      setState(() {
        isQuestionVisible = false;
        isCorrectVisible = true;
        isWrongVisible = false;
      });
    } else {
      livesManager.deductLife();
      await playWrongSound();
      setState(() {
        isQuestionVisible = false;
        isWrongVisible = true;
        isCorrectVisible = false;
      });
    }
  }

  void _runSqlQuery() {
    final rawQuery = _sqlController.text.trim();

    if (rawQuery.isEmpty) {
      setState(() {
        _filteredLedgerMaps = List.from(_allLedgerMaps);
        _visibleHeaders = List.from(_headers);
        isTableVisible = true;
      });
      return;
    }

    try {
      final result = _sqlEngine.execute(rawQuery);

      setState(() {
        _filteredLedgerMaps = result.rows;
        _visibleHeaders = result.columns;
        isTableVisible = true;
      });
    } catch (_) {
      setState(() {
        _filteredLedgerMaps = [];
        _visibleHeaders = List.from(_headers);
        isTableVisible = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or unsupported query format.')),
      );
    }
  }

  Widget _buildAsteriskIcon(double width) {
    return GlowingClue(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: FloatingBubble(
          child: GestureDetector(
            onTap: () async {
              await playButtonSound();

              if (!_hasLives) {
                showNoLivesPopup();
                return;
              }

              setState(() {
                isQuestionVisible = true;
                isQueryVisible = false;
                isTableVisible = false;
              });
            },
            child: Opacity(
              opacity: _hasLives ? 1.0 : 0.45,
              child: Image.asset(
                'assets/mystery/asterisk.png',
                width: width,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/mystery/Case3/lowe_loc.png',
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 25,
                    bottom: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
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
                          const Spacer(),
                          InkWell(
                            onTap: () => onButtonTap(() {
                              setState(() {
                                isQueryVisible = true;
                                isTableVisible = false;
                                isQuestionVisible = false;
                              });
                            }),
                            child: Image.asset(
                              'assets/mystery/query_button.png',
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.38,
                left: constraints.maxWidth * 0.69,
                child: _buildAsteriskIcon(50),
              ),
              Positioned(
                top: constraints.maxHeight * 0.56,
                left: constraints.maxWidth * 0.25,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  35,
                  "A tiered white cake, with several slices placed on plates nearby.",
                  'audio/case3/lowe/1.mp3',
                  const Duration(seconds: 5),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.32,
                left: constraints.maxWidth * 0.02,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  40,
                  "A framed poster titled â€œART OF WARâ€.",
                  'audio/case3/lowe/2.mp3',
                  const Duration(seconds: 3),
                ),
              ),
              if (activeInvestigationText != null)
                Center(
                  child: SizedBox(
                    width: constraints.maxWidth * 0.6,
                    child: InvestigationTypewriter(
                      key: ValueKey(activeInvestigationText),
                      text: activeInvestigationText!,
                      typingDuration:
                          activeTypingDuration ?? const Duration(seconds: 3),
                      onFinished: () async {
                        await stopClueSound();
                        await Future.delayed(const Duration(seconds: 1));
                        if (!mounted) return;
                        setState(() {
                          activeInvestigationText = null;
                          activeTypingDuration = null;
                        });
                      },
                    ),
                  ),
                ),
              if (isQueryVisible)
                AnimatedPopup(child: _buildPopUpContainer(constraints)),
              if (isQuestionVisible)
                AnimatedPopup(child: _buildQuestionPopUp(constraints)),
              if (isCorrectVisible)
                AnimatedPopup(child: _buildCorrectPopUp(constraints)),
              if (isWrongVisible)
                AnimatedPopup(child: _buildWrongPopUp(constraints)),
              if (isQuestionVisible)
                KeyboardAccessoryBar(
                  controller: _answerController,
                  hintText: "Type Answer",
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionPopUp(BoxConstraints constraints) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.68,
          height: constraints.maxHeight * 0.65,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/mystery/Case3/lowe_question.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 25,
                right: 15,
                child: InkWell(
                  onTap: () => onButtonTap(() {
                    setState(() => isQuestionVisible = false);
                  }),
                  child: Image.asset('assets/mystery/close_button.png', height: 25),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.24,
                left: constraints.maxWidth * 0.08,
                right: constraints.maxWidth * 0.08,
                child: const Text(
                  "Identify the action and timestamp of the override event that occurred between the 911 call and Mark Loweâ€™s official arrival. Which location did this unknown entity use to enter the premises?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.44,
                left: constraints.maxWidth * 0.15,
                right: constraints.maxWidth * 0.10,
                child: Opacity(
                  opacity: 0.50,
                  child: TextField(
                    controller: _answerController,
                    autofocus: _hasLives,
                    enabled: _hasLives,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Luckiest Guy',
                    ),
                    decoration: InputDecoration(
                      hintText: _hasLives ? "TYPE ANSWER..." : "NO LIVES LEFT",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 35,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: _hasLives ? 1.0 : 0.45,
                    child: InkWell(
                      onTap: () async {
                        await playButtonSound();
                        if (_hasLives) {
                          _submitAnswer();
                        } else {
                          showNoLivesPopup();
                        }
                      },
                      child: Image.asset(
                        'assets/mystery/submit_button.png',
                        height: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorrectPopUp(BoxConstraints constraints) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.65,
          height: constraints.maxHeight * 0.50,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/mystery/correct.png', fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 110,
                child: InkWell(
                  onTap: () => onButtonTap(() {
                    setState(() => isCorrectVisible = false);
                  }),
                  child: Image.asset('assets/mystery/close_button.png', height: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWrongPopUp(BoxConstraints constraints) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.65,
          height: constraints.maxHeight * 0.50,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/mystery/wrong.png', fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 110,
                child: InkWell(
                  onTap: () => onButtonTap(() {
                    setState(() => isWrongVisible = false);
                  }),
                  child: Image.asset('assets/mystery/close_button.png', height: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopUpContainer(BoxConstraints constraints) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.68,
          height: constraints.maxHeight * 0.75,
          child: isTableVisible
              ? _buildTableView(constraints)
              : _buildQueryView(constraints),
        ),
      ),
    );
  }

  Widget _buildTableView(BoxConstraints constraints) {
    const headerStyle = TextStyle(
      fontFamily: 'Consolas',
      color: Colors.red,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/mystery/Case3/smart_home.png', fit: BoxFit.fill),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: InkWell(
            onTap: () => onButtonTap(() {
              setState(() => isTableVisible = false);
            }),
            child: Image.asset('assets/mystery/close_button.png', height: 25),
          ),
        ),
        Positioned(
          top: constraints.maxHeight * 0.210,
          left: constraints.maxWidth * 0.04,
          right: constraints.maxWidth * 0.02,
          child: Row(
            children: List.generate(_visibleHeaders.length, (index) {
              return Expanded(
                flex: _flexForHeader(_visibleHeaders[index]),
                child: Center(
                  child: Text(
                    _visibleHeaders[index],
                    style: headerStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),
        ),
        Positioned(
          top: constraints.maxHeight * 0.290,
          left: constraints.maxWidth * 0.02,
          right: constraints.maxWidth * 0.03,
          bottom: constraints.maxHeight * 0.05,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Table(
              columnWidths: {
                for (int i = 0; i < _visibleHeaders.length; i++)
                  i: FlexColumnWidth(
                    _flexForHeader(_visibleHeaders[i]).toDouble(),
                  ),
              },
              children: _buildTableRowsList(),
            ),
          ),
        ),
      ],
    );
  }

  int _flexForHeader(String header) {
    switch (header) {
      case 'log_id':
        return 3;
      case 'user_code':
        return 3;
      case 'action':
        return 4;
      case 'entry_time':
        return 3;
      case 'exit_time':
        return 4;
      default:
        return 3;
    }
  }

  List<TableRow> _buildTableRowsList() {
    const cellStyle = TextStyle(
      fontFamily: 'Consolas',
      color: Colors.black,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    return List<TableRow>.generate(_filteredLedgerMaps.length, (index) {
      final row = _filteredLedgerMaps[index];

      return TableRow(
        decoration: BoxDecoration(
          color: index % 2 == 0
              ? const Color(0xFFFFF9C4).withValues(alpha: 0.7)
              : const Color(0xFFF0E68C).withValues(alpha: 0.5),
        ),
        children: _visibleHeaders.map((header) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 5.0,
            ),
            child: Text(
              row[header] ?? '',
              style: cellStyle,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildQueryView(BoxConstraints constraints) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/mystery/Case3/lowe_query.png', fit: BoxFit.fill),
        ),
        Positioned(
          top: 10,
          right: 20,
          child: InkWell(
            onTap: () => onButtonTap(() {
              setState(() => isQueryVisible = false);
            }),
            child: Image.asset('assets/mystery/close_button.png', height: 25),
          ),
        ),
        Positioned(
          top: constraints.maxHeight * 0.15,
          left: constraints.maxWidth * 0.05,
          right: constraints.maxWidth * 0.08,
          bottom: constraints.maxHeight * 0.18,
          child: Container(
            alignment: Alignment.topLeft,
            child: Scrollbar(
              controller: _sqlScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _sqlScrollController,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight * 0.40,
                  ),
                  child: Stack(
                    children: [
                      RichText(
                        text: _buildSqlHighlightedText(
                          _sqlController.text.isEmpty
                              ? "ENTER SQL QUERY..."
                              : _sqlController.text,
                          isHint: _sqlController.text.isEmpty,
                        ),
                      ),
                      TextField(
                        controller: _sqlController,
                        autofocus: true,
                        maxLines: null,
                        minLines: 12,
                        scrollController: _sqlScrollController,
                        cursorColor: Colors.black,
                        style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Consolas',
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: constraints.maxHeight * 0.03,
          left: constraints.maxWidth * 0.03,
          right: constraints.maxWidth * 0.03,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onButtonTap(() {
                  setState(() {
                    _filteredLedgerMaps = List.from(_allLedgerMaps);
                    _visibleHeaders = List.from(_headers);
                    isTableVisible = true;
                  });
                }),
                child: Image.asset('assets/mystery/tables_button.png', height: 35),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => onButtonTap(() {
                      _sqlController.clear();
                    }),
                    child: Image.asset('assets/mystery/clear_button.png', height: 35),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      await playButtonSound();
                      _runSqlQuery();
                    },
                    child: Image.asset('assets/mystery/run_button.png', height: 35),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextSpan _buildSqlHighlightedText(String text, {bool isHint = false}) {
    return _sqlEngine.buildHighlightedSqlText(text, isHint: isHint);
  }

  Widget _buildOverlayIcon(
    String asset,
    double width,
    String description,
    String audioPath,
    Duration typingDuration,
  ) {
    return GlowingClue(
      child: FloatingBubble(
        child: GestureDetector(
          onTap: () async {
            await playButtonSound();
            await playClueSound(audioPath);

            setState(() {
              activeInvestigationText = description;
              activeTypingDuration = typingDuration;
            });
          },
          child: Image.asset(asset, width: width, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class InvestigationTypewriter extends StatefulWidget {
  final String text;
  final VoidCallback onFinished;
  final Duration typingDuration;

  const InvestigationTypewriter({
    super.key,
    required this.text,
    required this.onFinished,
    required this.typingDuration,
  });

  @override
  State<InvestigationTypewriter> createState() =>
      _InvestigationTypewriterState();
}

class _InvestigationTypewriterState extends State<InvestigationTypewriter> {
  String _displayedText = "";
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    final int delayMs = widget.text.isEmpty
        ? 40
        : (widget.typingDuration.inMilliseconds / widget.text.length).round();

    _timer = Timer.periodic(Duration(milliseconds: delayMs), (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
        }
      } else {
        _timer?.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Text(
        _displayedText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Consolas',
        ),
      ),
    );
  }
}

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
      builder: (context, child) => Transform.translate(
        offset: Offset(0, widget.offset * _controller.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class GlowingClue extends StatefulWidget {
  final Widget child;

  const GlowingClue({super.key, required this.child});

  @override
  State<GlowingClue> createState() => _GlowingClueState();
}

class _GlowingClueState extends State<GlowingClue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glow = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFFFA8).withValues(alpha: _glow.value * 0.55),
                blurRadius: 18 + (_glow.value * 10),
                spreadRadius: 3 + (_glow.value * 3),
              ),
              BoxShadow(
                color: const Color(0xFFB388FF).withValues(alpha: _glow.value * 0.35),
                blurRadius: 30 + (_glow.value * 12),
                spreadRadius: 2 + (_glow.value * 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AnimatedPopup extends StatefulWidget {
  final Widget child;

  const AnimatedPopup({super.key, required this.child});

  @override
  State<AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<AnimatedPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(
      begin: 0.93,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/domain/usecases/simple_sql_engine.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';
import 'package:graphics_project/presentation/controllers/mystery_sql_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/controllers/points_controller.dart';

class WasteCorpScreen extends StatefulWidget {
  const WasteCorpScreen({super.key});

  @override
  State<WasteCorpScreen> createState() => _WasteCorpScreenState();
}

class _WasteCorpScreenState extends State<WasteCorpScreen>
    with CaseScreenHelper {
  bool isQueryVisible = false;
  bool isTableVisible = false;
  bool isQuestionVisible = false;
  bool isCorrectVisible = false;
  bool isWrongVisible = false;

  String? activeInvestigationText;
  Duration? activeTypingDuration;

  bool get _hasLives => hasLives;

  late final MysterySqlController _sqlController;
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _sqlScrollController = ScrollController();

  final List<String> _headers = const [
    'scan_id',
    'truck_id',
    'origin_route',
    'object',
    'timestamp',
  ];

  final List<List<String>> _conveyorScanLogs = [
    ['S-9001', 'T-12', 'North Ward', 'Plastic_Mixed', '14:00'],
    ['S-9002', 'T-12', 'North Ward', 'Paper_Cardboard', '14:02'],
    ['S-9003', 'T-44', 'West Ward', 'Glass_Bottles', '14:05'],
    ['S-9004', 'T-44', 'West Ward', 'Metal_Scrap', '14:08'],
    ['S-9005', 'T-05', 'East Ward', 'Organic_Food_Waste', '14:10'],
    ['S-9006', 'T-05', 'East Ward', 'Textile_Fabric', '14:12'],
    ['S-9007', 'T-92', 'South Ward', 'Plastic_Industrial', '14:14'],
    ['S-9008', 'T-92', 'South Ward', 'Paper_Mixed', '14:15'],
    ['S-9009', 'T-92', 'South Ward', 'HIGH_DENSITY_ORGANIC', '14:17'],
    ['S-9010', 'T-92', 'South Ward', 'Glass_Clear', '14:19'],
    ['S-9011', 'T-05', 'East Ward', 'Electronic_Waste', '14:22'],
    ['S-9012', 'T-88', 'North Ward', 'Metal_Aluminum', '14:25'],
    ['S-9013', 'T-88', 'North Ward', 'Organic_Green_Waste', '14:28'],
    ['S-9014', 'T-10', 'South Ward', 'Paper_Cardboard', '14:30'],
    ['S-9015', 'T-10', 'South Ward', 'Plastic_PET', '14:32'],
    ['S-9016', 'T-92', 'South Ward', 'UNIDENTIFIED_LEATHER', '14:35'],
    ['S-9017', 'T-33', 'Industrial', 'Construction_Debris', '14:38'],
    ['S-9018', 'T-33', 'Industrial', 'Metal_Steel', '14:41'],
    ['S-9019', 'T-12', 'North Ward', 'Plastic_HDPE', '14:45'],
    ['S-9020', 'T-44', 'West Ward', 'Glass_Colored', '14:48'],
    ['S-9021', 'T-92', 'South Ward', 'Organic_Food_Waste', '14:50'],
    ['S-9022', 'T-05', 'East Ward', 'Textile_Waste', '14:53'],
    ['S-9023', 'T-88', 'North Ward', 'Paper_Newsprint', '14:55'],
    ['S-9024', 'T-10', 'South Ward', 'Plastic_Mixed', '14:58'],
    ['S-9025', 'T-33', 'Industrial', 'Chemical_Container', '15:00'],
  ];

  late final SimpleSqlEngine _sqlEngine;
  List<Map<String, String>> _allLedgerMaps = [];
  List<Map<String, String>> _filteredLedgerMaps = [];
  List<String> _visibleHeaders = [];

  @override
  void initState() {
    super.initState();

    initCaseHelper();

    _allLedgerMaps = _conveyorScanLogs.map((row) {
      return {
        'scan_id': row[0],
        'truck_id': row[1],
        'origin_route': row[2],
        'object': row[3],
        'timestamp': row[4],
      };
    }).toList();

    _sqlEngine = SimpleSqlEngine(
      tableName: 'conveyor_scan_logs',
      headers: _headers,
      rows: _allLedgerMaps,
      numericColumns: const {},
    );
    _sqlController = MysterySqlController(sqlEngine: _sqlEngine);

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
        .replaceAll(';', '')
        .replaceAll(r'$', '')
        .replaceAll(',', '') // Remove all commas
        .replaceAll(' AND ', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isWasteCorpCorrectAnswer(String input) {
    final normalized = _normalizeAnswer(input);
    final opt1 = _normalizeAnswer('T-92 SOUTH WARD');
    final opt2 = _normalizeAnswer('T92 SOUTH WARD');
    final opt3 = _normalizeAnswer('TRUCK T-92 SOUTH WARD');
    final opt4 = _normalizeAnswer('TRUCK T92 SOUTH WARD');

    return normalized == opt1 ||
        normalized == opt2 ||
        normalized == opt3 ||
        normalized == opt4;
  }

  void _submitAnswer() async {
    if (!_hasLives) {
      setState(() {
        isQuestionVisible = false;
      });
      showNoLivesPopup();
      return;
    }

    if (_isWasteCorpCorrectAnswer(_answerController.text)) {
      unawaited(playCorrectSound());
      setState(() {
        isQuestionVisible = false;
        isCorrectVisible = true;
        isWrongVisible = false;
      });

      // Save solving state
      final auth = context.read<AuthController>();
      final userId = auth.currentUser!.id;
      final solveKey = 'case3_waste_corp_solved_$userId';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(solveKey, true);

      // Award points
      await PointsController.instance.addLocationScore('case3_waste_corp', 200);
    } else {
      livesManager.deductLife();
      unawaited(playWrongSound());
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

              if (!mounted) return;
              final auth = context.read<AuthController>();
              final userId = auth.currentUser!.id;
              final solveKey = 'case3_waste_corp_solved_$userId';

              final prefs = await SharedPreferences.getInstance();
              final bool alreadySolved = prefs.getBool(solveKey) ?? false;

              if (alreadySolved) {
                showAlreadySolvedPopup();
                return;
              }

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
                  'assets/mystery/Case3/waste_corp_loc.png',
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
                top: constraints.maxHeight * 0.32,
                left: constraints.maxWidth * 0.32,
                child: _buildAsteriskIcon(35),
              ),
              Positioned(
                top: constraints.maxHeight * 0.70,
                left: constraints.maxWidth * 0.23,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  40,
                  "A large grey sorting machine labeled \"BALDWIN CITY WASTE MANAGEMENT CORP. - SORTING ZONE\"",
                  'audio/case3/wasteCorp/1.mp3',
                  const Duration(seconds: 6),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.53,
                left: constraints.maxWidth * 0.48,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  50,
                  "A long, blue industrial conveyor belt filled with various recyclable waste materials.",
                  'audio/case3/wasteCorp/2.mp3',
                  const Duration(seconds: 6),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.56,
                left: constraints.maxWidth * 0.87,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  40,
                  "A computer screen showing a diagram of the waste material.",
                  'audio/case3/wasteCorp/3.mp3',
                  const Duration(seconds: 4),
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
                  'assets/mystery/Case3/waste_corp_question.png',
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
                  child: Image.asset(
                    'assets/mystery/close_button.png',
                    height: 25,
                  ),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.23,
                left: constraints.maxWidth * 0.08,
                right: constraints.maxWidth * 0.08,
                child: const Text(
                  "Which truck_id was responsible for the HIGH_DENSITY_ORGANIC alert? \nList the route that truck took earlier that day.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 15,
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
                child: Image.asset(
                  'assets/mystery/correct.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 10,
                right: 110,
                child: InkWell(
                  onTap: () => onButtonTap(() {
                    setState(() => isCorrectVisible = false);
                  }),
                  child: Image.asset(
                    'assets/mystery/close_button.png',
                    height: 20,
                  ),
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
                child: Image.asset(
                  'assets/mystery/wrong.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 10,
                right: 110,
                child: InkWell(
                  onTap: () => onButtonTap(() {
                    setState(() => isWrongVisible = false);
                  }),
                  child: Image.asset(
                    'assets/mystery/close_button.png',
                    height: 20,
                  ),
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
      fontSize: 15,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/mystery/Case3/conveyor_scan.png',
            fit: BoxFit.fill,
          ),
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
          left: constraints.maxWidth * 0.02,
          right: constraints.maxWidth * 0.03,
          bottom: constraints.maxHeight * 0.05,
          child: Column(
            children: [
              Table(
                columnWidths: {
                  for (int i = 0; i < _visibleHeaders.length; i++)
                    i: FlexColumnWidth(
                      _flexForHeader(_visibleHeaders[i]).toDouble(),
                    ),
                },
                children: [
                  TableRow(
                    children: _visibleHeaders.map((header) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 6.0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            header,
                            style: headerStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Expanded(
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
          ),
        ),
      ],
    );
  }

  int _flexForHeader(String header) {
    switch (header) {
      case 'scan_id':
        return 2;
      case 'truck_id':
        return 3;
      case 'origin_route':
        return 4;
      case 'object':
        return 3;
      case 'timestamp':
        return 3;
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
              vertical: 12.0,
              horizontal: 6.0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                row[header] ?? '',
                style: cellStyle,
                textAlign: TextAlign.center,
              ),
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
          child: Image.asset(
            'assets/mystery/Case3/waste_corp_query.png',
            fit: BoxFit.fill,
          ),
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
                  child: TextField(
                    controller: _sqlController,
                    autofocus: true,
                    maxLines: null,
                    minLines: 12,
                    scrollController: _sqlScrollController,
                    cursorColor: Colors.black,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Consolas',
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: "ENTER SQL QUERY...",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Consolas',
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    onChanged: (_) => setState(() {}),
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
                child: Image.asset(
                  'assets/mystery/tables_button.png',
                  height: 35,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => onButtonTap(() {
                      _sqlController.clear();
                    }),
                    child: Image.asset(
                      'assets/mystery/clear_button.png',
                      height: 35,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      await playButtonSound();
                      _runSqlQuery();
                    },
                    child: Image.asset(
                      'assets/mystery/run_button.png',
                      height: 35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
                color: const Color(
                  0xFFFFFFA8,
                ).withValues(alpha: _glow.value * 0.55),
                blurRadius: 18 + (_glow.value * 10),
                spreadRadius: 3 + (_glow.value * 3),
              ),
              BoxShadow(
                color: const Color(
                  0xFFB388FF,
                ).withValues(alpha: _glow.value * 0.35),
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

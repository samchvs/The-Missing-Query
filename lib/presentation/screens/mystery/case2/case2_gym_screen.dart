import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/domain/usecases/simple_sql_engine.dart';
import 'package:graphics_project/presentation/controllers/case_screen_helper.dart';
import 'package:graphics_project/presentation/controllers/mystery_sql_controller.dart';
import 'package:graphics_project/core/utils/text_formatters.dart';
import 'package:graphics_project/presentation/controllers/points_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> with CaseScreenHelper {
  bool isQueryVisible = false;
  bool isTableVisible = false;
  bool isQuestionVisible = false;
  bool isCorrectVisible = false;
  bool isWrongVisible = false;
  bool _isSolved = false;

  String? activeInvestigationText;
  Duration? activeTypingDuration;

  bool get _hasLives => hasLives;

  late final MysterySqlController _sqlController;
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _sqlScrollController = ScrollController();

  final List<String> _headers = const [
    'checkout_id',
    'item_name',
    'student_id',
    'time_out',
    'time_in',
  ];

  final List<List<String>> _equipmentRegistry = [
    [
      'G-701',
      'Basketball',
      '2024-015',
      '2026-03-30 10:00:00',
      '2026-03-30 12:00:00',
    ],
    [
      'G-702',
      'Yoga Mat',
      '2024-045',
      '2026-03-30 11:30:00',
      '2026-03-30 13:00:00',
    ],
    [
      'G-703',
      'Jump Rope',
      '2024-022',
      '2026-03-30 12:00:00',
      '2026-03-30 13:30:00',
    ],
    [
      'G-704',
      'Stopwatch',
      '2024-012',
      '2026-03-30 13:00:00',
      '2026-03-30 14:00:00',
    ],
    [
      'G-705',
      'Basketball',
      '2024-055',
      '2026-03-30 14:15:00',
      '2026-03-30 16:15:00',
    ],
    [
      'G-706',
      'Yoga Mat',
      '2024-010',
      '2026-03-30 15:00:00',
      '2026-03-30 16:30:00',
    ],
    [
      'G-707',
      '10lb Dumbbell',
      '2024-006',
      '2026-03-30 15:45:00',
      '2026-03-30 17:00:00',
    ],
    [
      'G-708',
      '10lb Dumbbell',
      '2024-006',
      '2026-03-30 15:45:00',
      '2026-03-30 17:00:00',
    ],
    [
      'G-709',
      'Medicine Ball',
      '2024-007',
      '2026-03-30 16:30:00',
      '2026-03-30 18:00:00',
    ],
    ['G-710', '20lb Iron Plate', '2024-003', '2026-03-30 17:15:00', 'NULL'],
    ['G-711', '20lb Iron Plate', '2024-003', '2026-03-30 17:15:00', 'NULL'],
    [
      'G-712',
      'Yoga Mat',
      '2024-099',
      '2026-03-30 18:00:00',
      '2026-03-30 19:30:00',
    ],
    [
      'G-713',
      'Basketball',
      '2024-015',
      '2026-03-30 19:00:00',
      '2026-03-30 21:00:00',
    ],
    [
      'G-714',
      'Jump Rope',
      '2024-045',
      '2026-03-30 20:30:00',
      '2026-03-30 21:30:00',
    ],
    [
      'G-715',
      '5lb Dumbbell',
      '2024-022',
      '2026-03-30 21:00:00',
      '2026-03-30 22:00:00',
    ],
    [
      'G-716',
      '5lb Dumbbell',
      '2024-022',
      '2026-03-30 21:00:00',
      '2026-03-30 22:00:00',
    ],
    [
      'G-717',
      'Stopwatch',
      '2024-012',
      '2026-03-31 8:00:00',
      '2026-03-31 9:00:00',
    ],
    [
      'G-718',
      'Basketball',
      '2024-055',
      '2026-03-31 9:30:00',
      '2026-03-31 11:30:00',
    ],
    [
      'G-719',
      'Yoga Mat',
      '2024-006',
      '2026-03-31 10:15:00',
      '2026-03-31 11:45:00',
    ],
    [
      'G-720',
      'Medicine Ball',
      '2024-010',
      '2026-03-31 11:00:00',
      '2026-03-31 12:30:00',
    ],
    ['G-721', '15lb Kettleball', '2024-003', '2026-03-31 13:00', 'NULL'],
    [
      'G-722',
      'Yoga Mat',
      '2024-002',
      '2026-03-31 14:00',
      '2026-03-31 15:30:00',
    ],
    [
      'G-723',
      'Jump Rope',
      '2024-001',
      '2026-03-31 15:15',
      '2026-03-31 16:15:00',
    ],
    [
      'G-724',
      'Basketball',
      '2024-007',
      '2026-03-31 16:45',
      '2026-03-31 18:45:00',
    ],
    [
      'G-725',
      '10lb Dumbbell',
      '2024-015',
      '2026-03-31 17:30',
      '2026-03-31 18:30:00',
    ],
  ];

  late final SimpleSqlEngine _sqlEngine;
  List<Map<String, String>> _allEquipmentMaps = [];
  List<Map<String, String>> _filteredEquipmentMaps = [];
  List<String> _visibleHeaders = [];

  @override
  void initState() {
    super.initState();

    initCaseHelper();

    _allEquipmentMaps = _equipmentRegistry.map((row) {
      return {
        'checkout_id': row[0],
        'item_name': row[1],
        'student_id': row[2],
        'time_out': row[3],
        'time_in': row[4],
      };
    }).toList();

    _sqlEngine = SimpleSqlEngine(
      tableName: 'equipment_registry',
      headers: _headers,
      rows: _allEquipmentMaps,
    );
    _sqlController = MysterySqlController(sqlEngine: _sqlEngine);

    _filteredEquipmentMaps = List.from(_allEquipmentMaps);
    _visibleHeaders = List.from(_headers);

    _sqlController.addListener(() {
      if (mounted) setState(() {});
    });
    _answerController.addListener(() {
      final text = _answerController.text;
      if (text != text.toUpperCase()) {
        _answerController.value = _answerController.value.copyWith(
          text: text.toUpperCase(),
          selection: _answerController.selection,
        );
      }
      if (mounted) setState(() {});
    });

    _checkIfSolved();
  }

  Future<void> _checkIfSolved() async {
    final auth = context.read<AuthController>();
    final userId = auth.currentUser!.id;
    final solveKey = 'case2_gym_solved_$userId';
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isSolved = prefs.getBool(solveKey) ?? false;
      });
    }
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
        .replaceAll(';', '')
        .toUpperCase()
        .replaceAll(RegExp(r'\s*,\s*'), ', ') // Standardize comma spacing
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isGymCorrectAnswer(String input) {
    final normalized = _normalizeAnswer(input);
    // Accepting formats like '2024-003, 3' or '2024003, 3'
    return normalized == '2024-003, 3' || normalized == '2024003, 3';
  }

  void _submitAnswer() async {
    if (!_hasLives) {
      setState(() {
        isQuestionVisible = false;
      });
      showNoLivesPopup();
      return;
    }

    if (_isGymCorrectAnswer(_answerController.text)) {
      unawaited(playCorrectSound());
      if (mounted) {
        setState(() {
          isQuestionVisible = false;
          isCorrectVisible = true;
          isWrongVisible = false;
        });
      }

      if (!mounted) return;
      final auth = context.read<AuthController>();
      final userId = auth.currentUser!.id;
      final solveKey = 'case2_gym_solved_$userId';

      final prefs = await SharedPreferences.getInstance();
      final bool alreadySolved = prefs.getBool(solveKey) ?? false;

      if (!alreadySolved) {
        await PointsController.instance.addLocationScore('case2_gym', 100);
        await prefs.setBool(solveKey, true);
        if (mounted) {
          setState(() {
            _isSolved = true;
          });
        }
      }
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
        _filteredEquipmentMaps = List.from(_allEquipmentMaps);
        _visibleHeaders = List.from(_headers);
        isTableVisible = true;
      });
      return;
    }

    try {
      final result = _sqlEngine.execute(rawQuery);

      setState(() {
        _filteredEquipmentMaps = result.rows;
        _visibleHeaders = result.columns;
        isTableVisible = true;
      });
    } catch (_) {
      setState(() {
        _filteredEquipmentMaps = [];
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
              final solveKey = 'case2_gym_solved_$userId';

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

              if (mounted) {
                setState(() {
                  isQuestionVisible = true;
                  isQueryVisible = false;
                  isTableVisible = false;
                });
              }
            },
            child: Opacity(
              opacity: (_hasLives && !_isSolved) ? 1.0 : 0.45,
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
                  'assets/mystery/Case2/gym_loc.png',
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
                top: constraints.maxHeight * 0.50,
                left: constraints.maxWidth * 0.04,
                child: _buildAsteriskIcon(40),
              ),
              Positioned(
                top: constraints.maxHeight * 0.26,
                left: constraints.maxWidth * 0.15,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  30,
                  "A slightly faded poster outlining use etiquette and safety guidelines.",
                  'audio/case2/gym/1.mp3',
                  const Duration(seconds: 5),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.40,
                left: constraints.maxWidth * 0.50,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  40,
                  "Shelves with various training gear.",
                  'audio/case2/gym/2.mp3',
                  const Duration(seconds: 2),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.35,
                left: constraints.maxWidth * 0.92,
                child: _buildOverlayIcon(
                  'assets/mystery/investigate.png',
                  40,
                  "A heavy metal door leading outside the Gym Storeroom.",
                  'audio/case2/gym/3.mp3',
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
                  'assets/mystery/Case2/gym_question.png',
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
                  "Identify any student_id who currently has more than 2 items that have not been returned. List the student_id and the total count of unreturned items.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 14,
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
                    inputFormatters: [UpperCaseTextFormatter()],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Luckiest Guy',
                    ),
                    onChanged: (value) {
                      if (value != value.toUpperCase()) {
                        _answerController.value = _answerController.value
                            .copyWith(
                              text: value.toUpperCase(),
                              selection: _answerController.selection,
                            );
                      }
                    },
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
      fontSize: 13,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/mystery/Case2/equipment.png',
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          top: 10,
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
      case 'checkout_id':
        return 3;
      case 'item_name':
        return 3;
      case 'student_id':
        return 3;
      case 'time_out':
        return 4;
      case 'time_in':
        return 4;
      default:
        return 3;
    }
  }

  List<TableRow> _buildTableRowsList() {
    const cellStyle = TextStyle(
      fontFamily: 'Consolas',
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    return List<TableRow>.generate(_filteredEquipmentMaps.length, (index) {
      final row = _filteredEquipmentMaps[index];

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
            'assets/mystery/Case2/gym_query.png',
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
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: const [],
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
                    _filteredEquipmentMaps = List.from(_allEquipmentMaps);
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

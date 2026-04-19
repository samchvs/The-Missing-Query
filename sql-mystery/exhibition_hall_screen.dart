import 'dart:async';
import 'package:flutter/material.dart';
import 'simple_sql_engine.dart';

class ExhibitionHallScreen extends StatefulWidget {
  const ExhibitionHallScreen({super.key});

  @override
  State<ExhibitionHallScreen> createState() => _ExhibitionHallScreenState();
}

class _ExhibitionHallScreenState extends State<ExhibitionHallScreen> {
  bool isQueryVisible = false;
  bool isTableVisible = false;
  bool isQuestionVisible = false;
  bool isCorrectVisible = false;
  bool isWrongVisible = false;

  String? activeInvestigationText;

  final TextEditingController _sqlController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _sqlScrollController = ScrollController();

  final List<String> _headers = const [
    'log_id',
    'access_time',
    'source_ip',
    'target',
    'action',
    'tool_used',
  ];

  final List<List<String>> _allLogs = [
    [
      'N385',
      '0:05:00',
      '192.168.1.10',
      'Lobby_Cam_01',
      'HEARTBEAT',
      'SysCheck',
    ],
    ['N386', '0:12:00', '10.0.0.12', 'Staff_WiFi', 'LOGIN', 'Mobile_OS'],
    ['N387', '0:30:00', '208.70.1.12', 'Giovanni_Email', 'SYNC', 'Exchange'],
    [
      'N388',
      '1:00:00',
      '192.168.1.50',
      'Server_Room',
      'TEMP_CHECK',
      'IoT_Sensor',
    ],
    [
      'N389',
      '1:15:00',
      '172.16.5.10',
      'External_Gate',
      'SCAN_CARD',
      'RFID_Reader',
    ],
    ['N390', '1:20:00', '45.12.90.1', 'Web_Server', 'PING', 'Unknown'],
    ['N391', '1:45:00', '192.168.1.15', 'Main_Server', 'REINDEX', 'SQL_Admin'],
    ['N392', '1:55:00', '10.0.0.8', 'Staff_WiFi', 'DISCONNECT', 'Timeout'],
    ['N399', '2:00:00', '192.168.1.15', 'Main_Server', 'BACKUP', 'ADMIN_ROSSI'],
    [
      'N400a',
      '2:05:00',
      '192.168.1.20',
      'Hall_Monitor',
      'REBOOT',
      'System_Task',
    ],
    ['N400', '2:15:00', '10.0.0.5', 'Vault_Gate', 'FAILED_LOGIN', 'Unknown'],
    [
      'N400b',
      '2:20:00',
      '172.16.10.5',
      'Viore_Proxy',
      'VPN_CONNECT',
      'OpenVPN',
    ],
    ['N400c', '2:35:00', '10.0.0.15', 'Guest_WiFi', 'DOWNLOAD', 'Browser'],
    ['N400d', '2:45:00', '192.168.1.12', 'CCTV_Main', 'ROTATE_LOGS', 'CronJob'],
    [
      'N401',
      '2:50:00',
      '172.16.10.20',
      'Vault_Gate',
      'PORT_SCAN',
      'NullByte-v7',
    ],
    [
      'N402',
      '3:00:00',
      '172.16.10.20',
      'Vault_Lock',
      'OVERRIDE',
      'NullByte-v7',
    ],
    [
      'N403',
      '3:05:00',
      '172.16.10.20',
      'Pearl_Pedestal',
      'OPEN',
      'ADMIN_ROSSI',
    ],
    [
      'N403a',
      '3:10:00',
      '172.16.10.20',
      'Exit_Sensor',
      'TRIGGER',
      'Laser_Trip',
    ],
    [
      'N403b',
      '3:15:00',
      '192.168.1.15',
      'Main_Server',
      'SYNC_COMPLETE',
      'SQL_Admin',
    ],
    ['N403c', '3:30:00', '10.0.0.1', 'Router_Main', 'RESTART', 'Admin_Panel'],
    [
      'N403d',
      '3:45:00',
      '45.12.90.1',
      'Web_Server',
      'DDOS_ATTACK',
      'Botnet_01',
    ],
    ['N403e', '3:50:00', '192.168.1.1', 'Firewall', 'BLOCK_IP', 'Auto_Guard'],
    [
      'N403f',
      '4:00:00',
      '192.168.1.10',
      'Lobby_Cam_01',
      'HEARTBEAT',
      'SysCheck',
    ],
    [
      'N403g',
      '4:15:00',
      '172.16.5.15',
      'Service_Lift',
      'CALIBRATE',
      'Mech_App',
    ],
    ['N404', '4:30:00', '208.70.1.12', 'Giovanni_Email', 'LOGIN', 'Outlook'],
    ['N405', '4:45:00', '10.0.0.12', 'Staff_WiFi', 'LOGIN', 'Mobile_OS'],
  ];

  late final SimpleSqlEngine _sqlEngine;
  late List<Map<String, String>> _allLogMaps;
  late List<Map<String, String>> _filteredLogMaps;
  late List<String> _visibleHeaders;

  @override
  void initState() {
    super.initState();

    _allLogMaps = _allLogs.map((row) {
      return {
        'log_id': row[0],
        'access_time': row[1],
        'source_ip': row[2],
        'target': row[3],
        'action': row[4],
        'tool_used': row[5],
      };
    }).toList();

    _sqlEngine = SimpleSqlEngine(
      tableName: 'network_logs',
      headers: _headers,
      rows: _allLogMaps,
      timeColumns: const {'access_time'},
    );

    _filteredLogMaps = List.from(_allLogMaps);
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
    _sqlController.dispose();
    _answerController.dispose();
    _sqlScrollController.dispose();
    super.dispose();
  }

  void _runSqlQuery() {
    final rawQuery = _sqlController.text.trim();

    if (rawQuery.isEmpty) {
      setState(() {
        _filteredLogMaps = List.from(_allLogMaps);
        _visibleHeaders = List.from(_headers);
        isTableVisible = true;
      });
      return;
    }

    try {
      final result = _sqlEngine.execute(rawQuery);

      setState(() {
        _filteredLogMaps = result.rows;
        _visibleHeaders = result.columns;
        isTableVisible = true;
      });
    } catch (_) {
      setState(() {
        _filteredLogMaps = [];
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
      child: FloatingBubble(
        child: GestureDetector(
          onTap: () {
            setState(() {
              isQuestionVisible = true;
              isQueryVisible = false;
              isTableVisible = false;
            });
          },
          child: Image.asset(
            'assets/asterisk.png',
            width: width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerKeyboardPreview() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (!isQuestionVisible || keyboardHeight == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 20,
      right: 20,
      bottom: keyboardHeight + 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF7A4B28), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            _answerController.text.isEmpty
                ? 'TYPE ANSWER...'
                : _answerController.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _answerController.text.isEmpty
                  ? Colors.grey
                  : Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Luckiest Guy',
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
                  'assets/exhibition_hall_loc.png',
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
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
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isQueryVisible = true;
                                isTableVisible = false;
                                isQuestionVisible = false;
                              });
                            },
                            child: Image.asset(
                              'assets/query_button.png',
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
                top: constraints.maxHeight * 0.53,
                left: constraints.maxWidth * 0.11,
                child: _buildAsteriskIcon(55),
              ),
              Positioned(
                top: constraints.maxHeight * 0.25,
                left: constraints.maxWidth * 0.10,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  50,
                  "A broken CCTV camera.",
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.44,
                left: constraints.maxWidth * 0.505,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  50,
                  "A reinforced glass pedestal that once held the Pearl of the Orient Sea.",
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.47,
                left: constraints.maxWidth * 0.583,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  45,
                  "A digital keypad that requires admin privileges to disarm.",
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.80,
                left: constraints.maxWidth * 0.71,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  50,
                  "Dusty footprints leading to the glass pedestal.",
                ),
              ),
              if (activeInvestigationText != null)
                Center(
                  child: SizedBox(
                    width: constraints.maxWidth * 0.6,
                    child: InvestigationTypewriter(
                      key: ValueKey(activeInvestigationText),
                      text: activeInvestigationText!,
                      onFinished: () =>
                          setState(() => activeInvestigationText = null),
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
              _buildAnswerKeyboardPreview(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionPopUp(BoxConstraints constraints) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.68,
          height: constraints.maxHeight * 0.65,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/giovanni_question.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 30,
                right: 20,
                child: InkWell(
                  onTap: () => setState(() => isQuestionVisible = false),
                  child: Image.asset('assets/close_button.png', height: 25),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.25,
                left: constraints.maxWidth * 0.08,
                right: constraints.maxWidth * 0.08,
                child: const Text(
                  "Identify the source_ip used to override the Vault_Lock.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 20,
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
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Luckiest Guy',
                    ),
                    decoration: const InputDecoration(
                      hintText: "TYPE ANSWER...",
                      hintStyle: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.005,
                left: 35,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (_answerController.text.trim().toUpperCase() ==
                          "172.16.10.20") {
                        setState(() {
                          isQuestionVisible = false;
                          isCorrectVisible = true;
                          isWrongVisible = false;
                        });
                      } else {
                        setState(() {
                          isQuestionVisible = false;
                          isWrongVisible = true;
                          isCorrectVisible = false;
                        });
                      }
                    },
                    child: Image.asset('assets/submit_button.png', height: 32),
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.65,
          height: constraints.maxHeight * 0.50,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/correct.png', fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 110,
                child: InkWell(
                  onTap: () => setState(() => isCorrectVisible = false),
                  child: Image.asset('assets/close_button.png', height: 20),
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: SizedBox(
          width: constraints.maxWidth * 0.65,
          height: constraints.maxHeight * 0.50,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/wrong.png', fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 110,
                child: InkWell(
                  onTap: () => setState(() => isWrongVisible = false),
                  child: Image.asset('assets/close_button.png', height: 20),
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
      color: Colors.black.withOpacity(0.5),
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
      fontSize: 12,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/network_logs.png', fit: BoxFit.fill),
        ),
        Positioned(
          top: 10,
          right: 20,
          child: InkWell(
            onTap: () => setState(() => isTableVisible = false),
            child: Image.asset('assets/close_button.png', height: 25),
          ),
        ),
        Positioned(
          top: constraints.maxHeight * 0.210,
          left: constraints.maxWidth * 0.03,
          right: constraints.maxWidth * 0.01,
          child: Row(
            children: List.generate(_visibleHeaders.length, (index) {
              return Expanded(
                flex: _flexForHeader(_visibleHeaders[index]),
                child: Text(_visibleHeaders[index], style: headerStyle),
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
        return 2;
      case 'access_time':
        return 3;
      case 'source_ip':
        return 4;
      case 'target':
        return 4;
      case 'action':
        return 3;
      case 'tool_used':
        return 3;
      default:
        return 3;
    }
  }

  List<TableRow> _buildTableRowsList() {
    const cellStyle = TextStyle(
      fontFamily: 'Consolas',
      color: Colors.black,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    return List<TableRow>.generate(_filteredLogMaps.length, (index) {
      final row = _filteredLogMaps[index];

      return TableRow(
        decoration: BoxDecoration(
          color: index % 2 == 0
              ? const Color(0xFFFFF9C4).withOpacity(0.7)
              : const Color(0xFFF0E68C).withOpacity(0.5),
        ),
        children: _visibleHeaders.map((header) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 6.0,
            ),
            child: Text(row[header] ?? '', style: cellStyle),
          );
        }).toList(),
      );
    });
  }

  Widget _buildQueryView(BoxConstraints constraints) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/giovanni_query.png', fit: BoxFit.fill),
        ),
        Positioned(
          top: 10,
          right: 20,
          child: InkWell(
            onTap: () => setState(() => isQueryVisible = false),
            child: Image.asset('assets/close_button.png', height: 25),
          ),
        ),
        Positioned(
          top: constraints.maxHeight * 0.15,
          left: constraints.maxWidth * 0.05,
          right: constraints.maxWidth * 0.08,
          bottom: constraints.maxHeight * 0.22,
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
          bottom: constraints.maxHeight * 0.02,
          left: constraints.maxWidth * 0.03,
          right: constraints.maxWidth * 0.03,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _filteredLogMaps = List.from(_allLogMaps);
                    _visibleHeaders = List.from(_headers);
                    isTableVisible = true;
                  });
                },
                child: Image.asset('assets/tables_button.png', height: 35),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _sqlController.clear();
                      });
                    },
                    child: Image.asset('assets/clear_button.png', height: 35),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _runSqlQuery,
                    child: Image.asset('assets/run_button.png', height: 35),
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

  Widget _buildOverlayIcon(String asset, double width, String description) {
    return GlowingClue(
      child: FloatingBubble(
        child: GestureDetector(
          onTap: () {
            setState(() {
              activeInvestigationText = description;
            });
          },
          child: Image.asset(asset, width: width, fit: BoxFit.contain),
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
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _glow = Tween<double>(
      begin: 0.45,
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
                color: const Color(0xFFFFFFA8).withOpacity(_glow.value * 0.55),
                blurRadius: 20 + (_glow.value * 10),
                spreadRadius: 3 + (_glow.value * 3),
              ),
              BoxShadow(
                color: const Color(0xFFB388FF).withOpacity(_glow.value * 0.35),
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

class InvestigationTypewriter extends StatefulWidget {
  final String text;
  final VoidCallback onFinished;

  const InvestigationTypewriter({
    super.key,
    required this.text,
    required this.onFinished,
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

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
        }
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) widget.onFinished();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey, width: 2),
      ),
      child: Text(
        _displayedText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Consolas',
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'simple_sql_engine.dart';

class ITScreen extends StatefulWidget {
  const ITScreen({super.key});

  @override
  State<ITScreen> createState() => _ITScreenState();
}

class _ITScreenState extends State<ITScreen> {
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
    'session_id',
    'admin_id',
    'command',
    'keystroke',
  ];

  final List<List<String>> _adminAuditTrail = [
    ['501', 'Morris_J', 'SCAN_NETWORK_INTEGRITY', '52'],
    ['502', 'Engr_Erwin', 'UPDATE_FIREWALL_V4', '55'],
    ['503', 'Engr_Erwin', 'CLEAR_TEMP_CACHE', '50'],
    ['504', 'Morris_J', 'START_CRYPTO_NODE_X8', '58'],
    ['505', 'Morris_J', 'CHECK_SERVER_UPS', '54'],
    ['506', 'Engr_Erwin', 'REBOOT_LAB_ROUTER', '56'],
    ['507', 'Engr_Erwin', 'ASSIGN_IP_DHCP', '55'],
    ['508', 'Morris_J', "SET_SYSTEM_TIME = '2023-11-12'", '112'],
    ['509', 'Richard_R', 'UPLOAD_NEW_FILE', '110'],
    ['510', 'Morris_J', "SET_SYSTEM_TIME = '2026-03-31'", '115'],
    ['511', 'Morris_J', 'LOGOUT', '55'],
    ['512', 'Morris_J', 'LOGIN', '52'],
    ['513', 'Morris_J', 'VIEW_ERROR_LOGS', '54'],
    ['514', 'Morris_J', 'RESTART_APACHE', '56'],
    ['515', 'Morris_J', 'MODIFY_USER_PERMISSIONS', '53'],
    ['516', 'Morris_J', 'RUN_DAILY_BACKUP', '55'],
    ['517', 'Engr_Erwin', 'SCAN_FOR_MALWARE', '58'],
    ['518', 'Engr_Erwin', 'UPDATE_SSL_CERT', '54'],
    ['519', 'Engr_Erwin', 'DISCONNECT_IDLE_SESSIONS', '55'],
    ['520', 'Morris_J', 'LOGOUT', '50'],
    ['521', 'Richard_R', 'VIEW_STUDENT_GRADES', '45'],
    ['522', 'Richard_R', 'UPDATE_ENROLLMENT_LIST', '110'],
    ['523', 'Engr_Erwin', 'CHECK_NETWORK_STABILITY', '65'],
    ['524', 'Engr_Erwin', "SET_SYSTEM_TIME = '2026-03-31'", '112'],
    ['525', 'Richard_R', 'RECOVER_DELETED_THESIS', '200'],
    ['526', 'Morris_J', 'DELETE_TEMP_USER_01', '55'],
    ['527', 'Morris_J', 'LOGOUT', '40'],
  ];

  late final SimpleSqlEngine _sqlEngine;
  List<Map<String, String>> _allAuditMaps = [];
  List<Map<String, String>> _filteredAuditMaps = [];
  List<String> _visibleHeaders = [];

  @override
  void initState() {
    super.initState();

    _allAuditMaps = _adminAuditTrail.map((row) {
      return {
        'session_id': row[0],
        'admin_id': row[1],
        'command': row[2],
        'keystroke': row[3],
      };
    }).toList();

    _sqlEngine = SimpleSqlEngine(
      tableName: 'admin_audit_trail',
      headers: _headers,
      rows: _allAuditMaps,
      numericColumns: const {'keystroke'},
    );

    _filteredAuditMaps = List.from(_allAuditMaps);
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

  String _normalizeAnswer(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isItCorrectAnswer(String input) {
    final normalized = _normalizeAnswer(input);
    const acceptedAnswers = {
      'MORRIS_J, 508, 510',
      'MORRIS_J 508 510',
      'MORRIS_J,508,510',
    };
    return acceptedAnswers.contains(normalized);
  }

  void _runSqlQuery() {
    final rawQuery = _sqlController.text.trim();

    if (rawQuery.isEmpty) {
      setState(() {
        _filteredAuditMaps = List.from(_allAuditMaps);
        _visibleHeaders = List.from(_headers);
        isTableVisible = true;
      });
      return;
    }

    try {
      final result = _sqlEngine.execute(rawQuery);

      setState(() {
        _filteredAuditMaps = result.rows;
        _visibleHeaders = result.columns;
        isTableVisible = true;
      });
    } catch (_) {
      setState(() {
        _filteredAuditMaps = [];
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
                  'assets/Case2/it_loc.png',
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
                top: constraints.maxHeight * 0.38,
                left: constraints.maxWidth * 0.56,
                child: _buildAsteriskIcon(50),
              ),
              Positioned(
                top: constraints.maxHeight * 0.50,
                left: constraints.maxWidth * 0.63,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  30,
                  "A worn leather-bound journal. Its edges are slightly frayed from frequent use.",
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.20,
                left: constraints.maxWidth * 0.07,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  40,
                  "A small framed signage.",
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.45,
                left: constraints.maxWidth * 0.27,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  40,
                  "A long coat draped over the back of an office chair.",
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
                  'assets/Case2/it_question.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: InkWell(
                  onTap: () => setState(() => isQuestionVisible = false),
                  child: Image.asset('assets/close_button.png', height: 25),
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.23,
                left: constraints.maxWidth * 0.08,
                right: constraints.maxWidth * 0.08,
                child: const Text(
                  "Find the admin_id and the specific session_id where an administrator attempted to manipulate the system clock. Return admins who have done this more than once.",
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
                    autofocus: true,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Luckiest Guy',
                    ),
                    decoration: const InputDecoration(
                      hintText: "TYPE ANSWER...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
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
                  child: InkWell(
                    onTap: () {
                      if (_isItCorrectAnswer(_answerController.text)) {
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
                    child: Image.asset('assets/submit_button.png', height: 35),
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
      fontSize: 11,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Case2/audit.png', fit: BoxFit.fill),
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
      case 'session_id':
        return 2;
      case 'admin_id':
        return 2;
      case 'command':
        return 3;
      case 'keystroke':
        return 2;
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

    return List<TableRow>.generate(_filteredAuditMaps.length, (index) {
      final row = _filteredAuditMaps[index];

      return TableRow(
        decoration: BoxDecoration(
          color: index % 2 == 0
              ? const Color(0xFFFFF9C4).withOpacity(0.7)
              : const Color(0xFFF0E68C).withOpacity(0.5),
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
          child: Image.asset('assets/Case2/it_query.png', fit: BoxFit.fill),
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
                onTap: () {
                  setState(() {
                    _filteredAuditMaps = List.from(_allAuditMaps);
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
          onTap: () => setState(() => activeInvestigationText = description),
          child: Image.asset(asset, width: width, fit: BoxFit.contain),
        ),
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
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
                color: const Color(0xFFFFFFA8).withOpacity(_glow.value * 0.55),
                blurRadius: 18 + (_glow.value * 10),
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

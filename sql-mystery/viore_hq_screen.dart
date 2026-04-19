import 'dart:async';
import 'package:flutter/material.dart';
import 'simple_sql_engine.dart';

class VioreHqScreen extends StatefulWidget {
  const VioreHqScreen({super.key});

  @override
  State<VioreHqScreen> createState() => _VioreHqScreenState();
}

class _VioreHqScreenState extends State<VioreHqScreen> {
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
    'company_name',
    'public_ip_range',
    'unique_software',
    'license_status',
    'asset_value',
  ];

  final List<List<String>> _intelligenceData = [
    ['Viore Corp', '172.16.10.0/24', 'NullByte-v7', 'ACTIVE', '1,500,000'],
    ['Giovanni Ltd', '208.70.1.0/24', 'Legacy_SAP_v4', 'EXPIRED', '12,000'],
    ['Thorne Appraisals', '192.168.5.1', 'GemScan_Pro', 'ACTIVE', '45,000'],
    ['District Coffee', '10.0.0.0/8', 'POS_Brew_v2', 'ACTIVE', '5,000'],
    ['Press_Corp', '45.12.33.0/24', 'EditMaster_Pro', 'ACTIVE', '250,000'],
    ['Thorne Security', '10.0.0.5/32', 'SpyGlass_Lite', 'TRIAL', '85,000'],
    ['Blue_Dolphin_Pub', '192.168.10.12', 'BarKeep_3000', 'ACTIVE', '2,500'],
    ['Metro_Logistics', '172.16.20.0/24', 'FleetTrack_v9', 'ACTIVE', '400,000'],
    ['Silver_Lining_Inc', '208.70.5.50', 'CloudVault_01', 'ACTIVE', '95,000'],
    ['Pearl_City_Gym', '10.0.0.122', 'FitLogic_Pro', 'EXPIRED', '1,200'],
    ['Vane_Logistics_Sub', '172.16.10.45', 'Courier_Sync', 'ACTIVE', '15,000'],
    ['District_Library', '45.12.90.0/24', 'BookStack_SQL', 'ACTIVE', '50,000'],
    ['Zenith_Telecom', '172.16.0.0/16', 'NetCommander', 'ACTIVE', '3,200,000'],
    ['Old_Town_Bakery', '192.168.1.10', 'FlourPower_v1', 'EXPIRED', '400'],
    ['Aqua_Cleaners', '10.10.5.1', 'DryWash_Manager', 'TRIAL', '3,000'],
    ['Rossi_Cyber_Cons', '172.16.10.101', 'ShieldWall_v2', 'ACTIVE', '110,000'],
    ['Golden_Grains', '208.70.1.5', 'Harvest_Tracker', 'EXPIRED', '8,500'],
    ['The_Loupe_Lounge', '192.168.55.1', 'Pour_Control_X', 'ACTIVE', '12,000'],
    [
      'Municipal_Records',
      '45.12.1.0/24',
      'Archive_Deep_04',
      'ACTIVE',
      '500,000',
    ],
    ['Fast_Lane_Auto', '10.0.4.20', 'GearShift_ERP', 'ACTIVE', '22,000'],
    ['Urban_Design_Co', '172.16.88.10', 'SketchBuild_3D', 'ACTIVE', '140,000'],
    ['Miller_Finance', '208.70.1.15', 'TaxCalc_Gold', 'ACTIVE', '35,000'],
    ['Spark_Electricity', '45.12.15.5', 'GridMaster_v5', 'ACTIVE', '900,000'],
    ['Neon_Signs_Ltd', '192.168.3.3', 'GlowControl', 'TRIAL', '4,500'],
    ['Dela_Cruz_Imports', '172.16.55.20', 'CargoLog_v2', 'EXPIRED', '60,000'],
    ['Tech_Savvy_Repair', '10.0.9.9', 'FixIt_Toolkit', 'ACTIVE', '7,500'],
  ];

  late final SimpleSqlEngine _sqlEngine;
  late List<Map<String, String>> _allCompanyMaps;
  late List<Map<String, String>> _filteredCompanyMaps;
  late List<String> _visibleHeaders;

  @override
  void initState() {
    super.initState();

    _allCompanyMaps = _intelligenceData.map((row) {
      return {
        'company_name': row[0],
        'public_ip_range': row[1],
        'unique_software': row[2],
        'license_status': row[3],
        'asset_value': row[4],
      };
    }).toList();

    _sqlEngine = SimpleSqlEngine(
      tableName: 'intelligence_data',
      headers: _headers,
      rows: _allCompanyMaps,
      numericColumns: const {'asset_value'},
    );

    _filteredCompanyMaps = List.from(_allCompanyMaps);
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

  bool _isVioreCorrectAnswer(String input) {
    final normalized = _normalizeAnswer(input);
    const acceptedAnswers = {'VIORE CORP', 'VIORE'};
    return acceptedAnswers.contains(normalized);
  }

  void _runSqlQuery() {
    final rawQuery = _sqlController.text.trim();

    if (rawQuery.isEmpty) {
      setState(() {
        _filteredCompanyMaps = List.from(_allCompanyMaps);
        _visibleHeaders = List.from(_headers);
        isTableVisible = true;
      });
      return;
    }

    try {
      final result = _sqlEngine.execute(rawQuery);

      setState(() {
        _filteredCompanyMaps = result.rows;
        _visibleHeaders = result.columns;
        isTableVisible = true;
      });
    } catch (_) {
      setState(() {
        _filteredCompanyMaps = [];
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
                child: Image.asset('assets/viore_hq_loc.png', fit: BoxFit.fill),
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
                left: constraints.maxWidth * 0.48,
                child: _buildAsteriskIcon(55),
              ),
              Positioned(
                top: constraints.maxHeight * 0.47,
                left: constraints.maxWidth * 0.810,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  45,
                  "A secure workstation displaying encrypted logs.",
                ),
              ),
              Positioned(
                top: constraints.maxHeight * 0.80,
                left: constraints.maxWidth * 0.35,
                child: _buildOverlayIcon(
                  'assets/investigate.png',
                  50,
                  "Access credentials found on a discarded badge.",
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
                  'assets/viore_question.png',
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
                top: constraints.maxHeight * 0.25,
                left: constraints.maxWidth * 0.08,
                right: constraints.maxWidth * 0.08,
                child: const Text(
                  "Who is the owner of the NullByte-v7 software?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 18,
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
                bottom: constraints.maxHeight * 0.005,
                left: 35,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (_isVioreCorrectAnswer(_answerController.text)) {
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
      fontSize: 12,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/intelligence.png', fit: BoxFit.fill),
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
      case 'company_name':
        return 4;
      case 'public_ip_range':
        return 4;
      case 'unique_software':
        return 4;
      case 'license_status':
        return 4;
      case 'asset_value':
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

    return List<TableRow>.generate(_filteredCompanyMaps.length, (index) {
      final row = _filteredCompanyMaps[index];

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
          child: Image.asset('assets/viore_query.png', fit: BoxFit.fill),
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
                    _filteredCompanyMaps = List.from(_allCompanyMaps);
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
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glow = Tween<double>(
      begin: 0.25,
      end: 0.85,
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
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  254,
                  255,
                  213,
                ).withOpacity(_glow.value * 0.40),
                blurRadius: 13 + (_glow.value * 5),
                spreadRadius: 1 + (_glow.value * 2),
              ),
              BoxShadow(
                color: const Color(0xFF6A008A).withOpacity(_glow.value * 0.15),
                blurRadius: 24 + (_glow.value * 10),
                spreadRadius: _glow.value,
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

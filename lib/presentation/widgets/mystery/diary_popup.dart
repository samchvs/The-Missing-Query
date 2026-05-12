import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/presentation/controllers/diary_controller.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';

/// Full-screen overlay notebook popup for the CRUD diary.
/// Drop this on top of any stack with showDiaryPopup().
class DiaryPopup extends StatefulWidget {
  final DiaryController controller;

  const DiaryPopup({
    super.key,
    required this.controller,
  });

  @override
  State<DiaryPopup> createState() => _DiaryPopupState();
}

class _DiaryPopupState extends State<DiaryPopup>
    with SingleTickerProviderStateMixin {
  late final DiaryController _controller;
  late final TextEditingController _sqlController;
  late final AnimationController _anim;
  late final Animation<double> _scaleAnim;

  bool _isLoading = true;
  DiaryResult? _lastResult;
  bool _showTable = false;
  bool _showNotebook = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _sqlController = TextEditingController(text: _controller.draftSql);
    _sqlController.addListener(() {
      _controller.draftSql = _sqlController.text;
    });
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _anim.forward();

    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadExisting();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runQuery() async {
    final sql = _sqlController.text.trim();
    if (sql.isEmpty) return;

    final result = await _controller.execute(sql);
    if (mounted) {
      setState(() {
        _lastResult = result;
        _showTable = result.success && result.rows != null;
        _showNotebook = false;
      });
    }
  }

  void _clearAll() {
    _sqlController.clear();
  }

  void _close() {
    _anim.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _sqlController.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Builder(
            builder: (context) {
              final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              final bool isKeyboardOpen = keyboardHeight > 0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Notebook Layout
                  if (_showNotebook)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _close,
                            child: Container(color: Colors.transparent),
                          ),
                          Center(
                            child: Transform.translate(
                              offset: Offset(
                                -80,
                                isKeyboardOpen ? -85.0 : 0.0,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: Image.asset(
                                      AppAssets.notebookLayout,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    top: 65,
                                    left: 55,
                                    right: 25,
                                    bottom: 60,
                                    child: _isLoading 
                                        ? const Center(child: CircularProgressIndicator()) 
                                        : ScrollConfiguration(
                                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                            child: TextField(
                                              controller: _sqlController,
                                              maxLines: null,
                                              style: GoogleFonts.inconsolata(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                height: 1.5,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                hintText: 'Type SQL here...\ne.g. CREATE TABLE my_notes (\n  id INT PRIMARY KEY,\n  note VARCHAR(100)\n);',
                                                hintStyle: GoogleFonts.inconsolata(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                  // Close Button
                                  Positioned(
                                    top: 20,
                                    right: 30,
                                    child: BouncingButton(
                                      onPressed: _close,
                                      child: Image.asset(
                                        AppAssets.closeBtn,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  // Bottom buttons
                                  Positioned(
                                    bottom: 25,
                                    left: 15,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        BouncingButton(
                                          onPressed: () {
                                            if (_controller.hasTable) {
                                              setState(() {
                                                _lastResult = DiaryResult(
                                                  success: true,
                                                  message: 'Table "${_controller.table!.name}".',
                                                  rows: _controller.table!.rows,
                                                  columns: _controller.table!.columns,
                                                );
                                                _showTable = true;
                                                _showNotebook = false;
                                              });
                                            } else {
                                              setState(() {
                                                _lastResult = const DiaryResult(
                                                  success: false,
                                                  message: 'No table created yet.',
                                                );
                                                _showTable = false;
                                                _showNotebook = false;
                                              });
                                            }
                                          },
                                          child: Image.asset(
                                            AppAssets.tablesBtn,
                                            width: 60,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        BouncingButton(
                                          onPressed: _clearAll,
                                          child: Image.asset(
                                            AppAssets.clearBtn,
                                            width: 50,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        BouncingButton(
                                          onPressed: _runQuery,
                                          child: Image.asset(
                                            AppAssets.runBtn,
                                            width: 65,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Result / Diary Table View
                  if (!_showNotebook)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                          child: Container(
                            width: 600,
                            height: 350,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB347),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD38312),
                              width: 4,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 10,
                                left: 15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1C1),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: const Color(0xFFD38312),
                                    ),
                                  ),
                                  child: Text(
                                    _controller.table != null 
                                        ? "TABLE: ${_controller.table!.name.toUpperCase()}" 
                                        : "CRUD DIARY",
                                    style: GoogleFonts.londrinaSolid(
                                      fontSize: 16,
                                      color: const Color(0xFF542E2E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Close Button (goes back to notebook)
                              Positioned(
                                top: 5,
                                right: 10,
                                child: BouncingButton(
                                  onPressed: () => setState(
                                    () => _showNotebook = true,
                                  ),
                                  child: Image.asset(
                                    AppAssets.closeBtn,
                                    width: 25,
                                  ),
                                ),
                              ),
                              // Main Content Area
                              Positioned(
                                top: 45,
                                left: 15,
                                right: 15,
                                bottom: 15,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7E0),
                                    border: Border.all(
                                      color: const Color(0xFFD38312),
                                    ),
                                  ),
                                  child: _buildResultArea(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  KeyboardAccessoryBar(
                    controller: _sqlController,
                    hintText: 'e.g. CREATE TABLE...',
                    isMultiline: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_lastResult == null) {
      return Center(
        child: Text(
          'Run a query to see results here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inconsolata(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (!_lastResult!.success) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'ERROR',
                  style: GoogleFonts.inconsolata(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _lastResult!.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inconsolata(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    // Success with table
    if (_showTable && _lastResult!.rows != null) {
      return _buildTableView(
        _lastResult!.columns ?? [],
        _lastResult!.rows!,
        _lastResult!.message,
      );
    }

    // Success message only
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              Text(
                'SUCCESS',
                style: GoogleFonts.inconsolata(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _lastResult!.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inconsolata(
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(
    List<String> columns,
    List<Map<String, String>> rows,
    String message,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: columns.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              '(empty table)',
                              style: GoogleFonts.inconsolata(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth > (columns.length * 100)
                                  ? constraints.maxWidth
                                  : (columns.length * 100).toDouble(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row
                                Container(
                                  color: const Color(0xFFFFF1C1),
                                  child: Row(
                                    children: columns.map((col) {
                                      final isNotes = col.toLowerCase() == 'notes';
                                      return Container(
                                        width: isNotes ? 300 : 120,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        child: Text(
                                          col,
                                          style: GoogleFonts.londrinaSolid(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // Data Rows
                                ...rows.map((row) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: columns.map((col) {
                                          final isNotes = col.toLowerCase() == 'notes';
                                          return Container(
                                            width: isNotes ? 300 : 120,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            child: Text(
                                              row[col] ?? '',
                                              softWrap: true,
                                              style: GoogleFonts.inconsolata(
                                                fontSize: 13,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
        // Prompt message at the bottom
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1C1),
            border: Border(top: BorderSide(color: Color(0xFFD38312))),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inconsolata(
              fontSize: 13,
              color: const Color(0xFF542E2E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Convenience function to open the diary popup from any map screen.
Future<void> showDiaryPopup(
  BuildContext context, {
  required DiaryController controller,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Diary',
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => DiaryPopup(
      controller: controller,
    ),
  );
}

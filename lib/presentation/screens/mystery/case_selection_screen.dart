import 'package:flutter/material.dart';
import 'package:graphics_project/core/utils/page_transitions.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/screens/mystery/case1/case1_description_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case2/case2_description_screen.dart';
import 'package:graphics_project/presentation/screens/mystery/case3/case3_description_screen.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/controllers/points_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// --- SCREEN: CASE SELECTION ---
class CaseSelectionScreen extends StatefulWidget {
  const CaseSelectionScreen({super.key});

  @override
  State<CaseSelectionScreen> createState() => _CaseSelectionScreenState();
}

class _CaseSelectionScreenState extends State<CaseSelectionScreen> {
  bool _isCase2Unlocked = false;
  bool _isCase3Unlocked = false; // Currently locked

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.id ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    
    // Case 2 Unlock Condition: Police Station Solved AND Case 1 Points >= 550
    final bool policeSolved = prefs.getBool('case1_police_station_solved_$userId') ?? false;
    final int points = PointsController.instance.getPointsForCase('case1');

    setState(() {
      _isCase2Unlocked = policeSolved && points >= 550;
      _isCase3Unlocked = false; // Keep Case 3 locked for now
    });
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Case Locked. Complete previous case to unlock.',
          style: TextStyle(fontFamily: 'Consolas', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF330066), Color(0xFF6A008A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 25,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    BouncingButton(
                      onPressed: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/mystery/back_button.png',
                        height: 40,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Image.asset(
                        'assets/mystery/select_case.png',
                        height: 62,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Spacer(),
              Consumer<PointsController>(
                builder: (context, pointsController, child) {
                  // Trigger a re-check when points change
                  _checkUnlockStatus();
                  
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BouncingButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                slideRoute(const CaseDescription1()),
                              ).then((_) => _checkUnlockStatus());
                            },
                            child: const CaseFolder(
                              caseTitle: "CASE FILE 01:\nTHE PEARL ROBBERY",
                              isLocked: false,
                            ),
                          ),
                          BouncingButton(
                            onPressed: () {
                              if (_isCase2Unlocked) {
                                Navigator.push(
                                  context,
                                  slideRoute(const CaseDescription2()),
                                ).then((_) => _checkUnlockStatus());
                              } else {
                                _showLockedMessage();
                              }
                            },
                            child: CaseFolder(
                              caseTitle: "CASE FILE 02:\nProject Chimera",
                              isLocked: !_isCase2Unlocked,
                            ),
                          ),

                          BouncingButton(
                            onPressed: () {
                              if (_isCase3Unlocked) {
                                Navigator.push(
                                  context,
                                  slideRoute(const CaseDescription3()),
                                ).then((_) => _checkUnlockStatus());
                              } else {
                                _showLockedMessage();
                              }
                            },
                            child: CaseFolder(
                              caseTitle: "CASE FILE 03:\n9-1-1",
                              isLocked: !_isCase3Unlocked,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CASE FOLDER WIDGET ---
class CaseFolder extends StatelessWidget {
  final String caseTitle;
  final bool isLocked;

  const CaseFolder({
    super.key,
    required this.caseTitle,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.82,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/mystery/folder.png',
                  fit: BoxFit.contain,
                  color: isLocked ? Colors.black.withValues(alpha: 0.45) : null,
                  colorBlendMode: isLocked ? BlendMode.srcOver : null,
                ),
                if (isLocked)
                  FractionallySizedBox(
                    heightFactor: 0.68,
                    child: Image.asset('assets/mystery/question.png'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBE6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF7A4B28), width: 3.5),
            ),
            child: Text(
              caseTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4A2C15), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sql_mystery/page_transition.dart';
import 'case_description1.dart';
import 'case_description2.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const CaseSelectionApp());
}

class CaseSelectionApp extends StatelessWidget {
  const CaseSelectionApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Luckiest Guy'),
    home: const CaseSelectionScreen(),
  );
}
}

// --- SCREEN: CASE SELECTION ---
class CaseSelectionScreen extends StatelessWidget {
  const CaseSelectionScreen({super.key});

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => debugPrint("Back pressed"),
                      child: Image.asset('assets/back_button.png', height: 40),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Image.asset(
                        'assets/select_case.png',
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            slideRoute(const CaseDescription1()),
                          );
                        },
                        child: const CaseFolder(
                          caseTitle: "CASE FILE 01:\nTHE PEARL ROBBERY",
                          isLocked: false,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            slideRoute(const CaseDescription2()),
                          );
                        },
                        child: const CaseFolder(
                          caseTitle: "CASE FILE 02:\nProject Chimera",
                          isLocked: false,
                        ),
                      ),
                      const CaseFolder(
                        caseTitle: "CASE FILE 03:\n???",
                        isLocked: true,
                      ),
                    ],
                  ),
                ),
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
                  'assets/folder.png',
                  fit: BoxFit.contain,
                  color: isLocked ? Colors.black.withOpacity(0.45) : null,
                  colorBlendMode: isLocked ? BlendMode.srcOver : null,
                ),
                if (isLocked)
                  FractionallySizedBox(
                    heightFactor: 0.68,
                    child: Image.asset('assets/question.png'),
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

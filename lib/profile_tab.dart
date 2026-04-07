import 'package:flutter/material.dart';
import 'splash_screen.dart';

class ProfileTab extends StatefulWidget {
  final String username;
  final String characterPath;
  final Function(String) onUsernameChanged;
  final Function(String) onCharacterChanged;

  const ProfileTab({
    super.key,
    required this.username,
    required this.characterPath,
    required this.onUsernameChanged,
    required this.onCharacterChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late String _localUsername;
  late String _localCharacter;

  // Global map defining specific graphics layout bounds for BOTH the modal and the mini-badge
  final List<Map<String, dynamic>> characters = [
    {
      'path': 'assets/Beanie.png',
      'height': 90.0,
      'top': 90.0,
      'name': 'Beanie',
      'badgeLeft': 8.0,
      'badgeTop': -0.20,
      'badgeWidth': 70.0,
    },
    {
      'path': 'assets/Carrotino.png',
      'height': 75.0,
      'top': 95.0,
      'name': 'Carrotino',
      'badgeLeft': 20.0,
      'badgeTop': 5.0,
      'badgeWidth': 33.0,
    },
    {
      'path': 'assets/Broccoliandro.png',
      'height': 75.0,
      'top': 95.0,
      'name': 'Broccoliandro',
      'badgeLeft': 20.0,
      'badgeTop': 7.0,
      'badgeWidth': 45.0,
    },
    {
      'path': 'assets/Tomathomas.png',
      'height': 75.0,
      'top': 95.0,
      'name': 'Tomathomas',
      'badgeLeft': -10.0,
      'badgeTop': -30.0,
      'badgeWidth': 70.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _localUsername = widget.username;
    _localCharacter = widget.characterPath;
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.username != oldWidget.username) {
      _localUsername = widget.username;
    }
    if (widget.characterPath != oldWidget.characterPath) {
      _localCharacter = widget.characterPath;
    }
  }

  //Modal pop up
  Future<void> _showEditModal(BuildContext context) async {
    TextEditingController modalController = TextEditingController(
      text: _localUsername,
    );

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      useSafeArea: false,
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/usernameModal.png',
                        width: 450,
                        fit: BoxFit.contain,
                      ),

                      Positioned(
                        top: 48,
                        left: 180,
                        right: 50,
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: modalController,
                            autofocus: true,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFF542E2E),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 70,
                        child: BouncingButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            'assets/cancel-btn.png',
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        right: 70,
                        child: BouncingButton(
                          onPressed: () {
                            if (modalController.text.trim().isNotEmpty) {
                              setState(() {
                                _localUsername = modalController.text.trim();
                              });
                              widget.onUsernameChanged(_localUsername);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Image.asset(
                            'assets/confirm-btn.png',
                            width: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- CHARACTER MODAL POPUP LOGIC ---
  Future<void> _showCharacterModal(BuildContext context) async {
    int _currentCharacterIndex = 0;

    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      useSafeArea: false,
      builder: (BuildContext context) {
        // StatefulBuilder allows the modal to redraw ITSELF without redrawing the whole screen!
        return StatefulBuilder(
          builder: (context, setModalState) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(viewInsets: EdgeInsets.zero),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Your Character Modal Graphic
                          Image.asset(
                            'assets/characterModal.png',
                            width: 300,
                            fit: BoxFit.contain,
                          ),

                          // THE SELECTED CHARACTER
                          Positioned(
                            top: characters[_currentCharacterIndex]['top'],
                            child: Image.asset(
                              characters[_currentCharacterIndex]['path'],
                              height:
                                  characters[_currentCharacterIndex]['height'],
                              fit: BoxFit.contain,
                            ),
                          ),

                          // THE CHARACTER NAME
                          Positioned(
                            top:
                                190, // Adjust this 'top' to place the text directly under the character!
                            child: Text(
                              characters[_currentCharacterIndex]['name'],
                              style: const TextStyle(
                                color: Colors
                                    .white, // Matches your app's brown text palette
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // LEFT ARROW Button
                          Positioned(
                            left: 60,
                            // Adjust 'top' to perfectly center the arrow vertically!
                            top: 140,
                            child: BouncingButton(
                              onPressed: () {
                                setModalState(() {
                                  _currentCharacterIndex--;
                                  if (_currentCharacterIndex < 0) {
                                    _currentCharacterIndex =
                                        characters.length - 1; // loop to back
                                  }
                                });
                              },
                              child: Image.asset(
                                'assets/arrowLeft-btn.png',
                                width: 30, // Adjust arrow size here
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // RIGHT ARROW Button
                          Positioned(
                            right: 60,
                            top: 140,
                            child: BouncingButton(
                              onPressed: () {
                                setModalState(() {
                                  _currentCharacterIndex++;
                                  if (_currentCharacterIndex >=
                                      characters.length) {
                                    _currentCharacterIndex = 0; // loop to front
                                  }
                                });
                              },
                              child: Image.asset(
                                'assets/arrowRight-btn.png',
                                width: 30,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // CANCEL Button
                          Positioned(
                            bottom: 35,
                            left: 40,
                            child: BouncingButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                'assets/cancel-btn.png',
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // CONFIRM Button
                          Positioned(
                            bottom: 35,
                            right: 40,
                            child: BouncingButton(
                              onPressed: () {
                                // Broadcasting the chosen character path entirely upward into App state
                                widget.onCharacterChanged(
                                  characters[_currentCharacterIndex]['path'],
                                );
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                'assets/confirm-btn.png',
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //displaySettings contents
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.15, -0.5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/username-edit.png',
            width: 320,
            fit: BoxFit.contain,
          ),

          // DISPLAY CHOSEN CHARACTER BADGE OVER USERNAME BAR
          Builder(
            builder: (context) {
              final Map<String, dynamic> charData = characters.firstWhere(
                (c) => c['path'] == _localCharacter,
                orElse: () => characters[0],
              );

              return Positioned(
                left:
                    charData['badgeLeft'], // Tweak left placement per-character
                top: charData['badgeTop'], // Tweak top height per-character
                child: Image.asset(
                  _localCharacter,
                  width: charData['badgeWidth'], // Rendered size per-character
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            top: 80,
            left: -100,
            child: Image.asset(
              'assets/rankDisplay.png',
              width: 550,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 100,
            top: 24,
            child: Text(
              _localUsername,
              style: const TextStyle(
                color: Color(0xFF542E2E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 250,
            top: 11.5,
            child: BouncingButton(
              onPressed: () {
                _showEditModal(context);
              },
              child: Image.asset(
                'assets/edit-btn.png',
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // pencil button
          Positioned(
            left: 65,
            top: 43,
            child: BouncingButton(
              onPressed: () {
                _showCharacterModal(context);
              },
              child: Image.asset(
                'assets/pencil-btn.png',
                width: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

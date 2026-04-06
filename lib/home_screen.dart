import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUserDisplayVisible = false;
  bool _isSignoutConfirmationVisible = false;
  bool _isQuitConfirmationVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/home_screen.png'), context);
    precacheImage(const AssetImage('assets/play-btn.png'), context);
    precacheImage(const AssetImage('assets/settings-btn.png'), context);
    precacheImage(const AssetImage('assets/userIcon-btn.png'), context);
    precacheImage(const AssetImage('assets/userDisplay.png'), context);
    precacheImage(const AssetImage('assets/innerUserDisplay.png'), context);
    precacheImage(const AssetImage('assets/signout-btn.png'), context);
    precacheImage(const AssetImage('assets/no-btn.png'), context);
    precacheImage(const AssetImage('assets/yes-btn.png'), context);
    precacheImage(const AssetImage('assets/signoutDisplay.png'), context);
    precacheImage(const AssetImage('assets/quitDisplay.png'), context);
    precacheImage(const AssetImage('assets/settings_screen.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/home_screen.png',
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: BouncingButton(
              onPressed: () {
                debugPrint('Settings button tapped');
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SettingsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Image.asset('assets/settings-btn.png', width: 50),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'WELCOME, ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: '${widget.username}!',
                        style: const TextStyle(color: Colors.yellow),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                BouncingButton(
                  onPressed: () {
                    debugPrint('User button tapped');
                    setState(() {
                      _isUserDisplayVisible = true;
                    });
                  },
                  child: Image.asset('assets/userIcon-btn.png', width: 50),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.4),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: BouncingButton(
                onPressed: () {
                  debugPrint('Play button tapped');
                },
                child: Image.asset('assets/play-btn.png', width: 110),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.6),
            child: BouncingButton(
              onPressed: () {
                debugPrint('Tutorial button tapped');
              },
              child: Image.asset('assets/tutorial-btn.png', width: 140),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.8),
            child: BouncingButton(
              onPressed: () {
                debugPrint('Quit button tapped');
                setState(() {
                  _isQuitConfirmationVisible = true;
                });
              },
              child: Image.asset('assets/quit-btn.png', width: 100),
            ),
          ),
          if (_isUserDisplayVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isUserDisplayVisible = false;
                  });
                },
                child: Container(color: Colors.black54),
              ),
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Stack(
                children: [
                  Image.asset('assets/userDisplay.png', width: 250),
                  Positioned(
                    top: 30,
                    left: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/innerUserDisplay.png', width: 60),
                        const SizedBox(width: 15),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Color(0xFF542E2E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: BouncingButton(
                        onPressed: () {
                          debugPrint('Sign out button tapped');
                          setState(() {
                            _isUserDisplayVisible = false;
                            _isSignoutConfirmationVisible = true;
                          });
                        },
                        child: Image.asset(
                          'assets/signout-btn.png',
                          width: 120,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isSignoutConfirmationVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignoutConfirmationVisible = false;
                  });
                },
                child: Container(
                  color: Colors.black87, // Stronger darken for focus
                ),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/signoutDisplay.png', width: 300),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0), // Shifted further right for balance
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BouncingButton(
                              onPressed: () {
                                setState(() {
                                  _isSignoutConfirmationVisible = false;
                                });
                              },
                              child: Image.asset('assets/no-btn.png', width: 120),
                            ),
                            const SizedBox(width: 5), // Reduced gap to 5 to bring buttons closer
                            BouncingButton(
                              onPressed: () {
                                debugPrint('Sign out confirmed');
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 600),
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const SplashScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Image.asset('assets/yes-btn.png', width: 120),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_isQuitConfirmationVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isQuitConfirmationVisible = false;
                  });
                },
                child: Container(
                  color: Colors.black87, // Darken background for focus
                ),
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/quitDisplay.png', width: 300),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0), 
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BouncingButton(
                              onPressed: () {
                                setState(() {
                                  _isQuitConfirmationVisible = false;
                                });
                              },
                              child: Image.asset('assets/no-btn.png', width: 120),
                            ),
                            const SizedBox(width: 5),
                            BouncingButton(
                              onPressed: () {
                                debugPrint('Quit confirmed');
                                SystemNavigator.pop();
                              },
                              child: Image.asset('assets/yes-btn.png', width: 120),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

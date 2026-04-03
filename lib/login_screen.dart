import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  String? _passwordError;

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null;
      } else if (value.length < 8) {
        _passwordError = "Minimum 8 characters required";
      } else if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>0-9]'))) {
        _passwordError = "Requires a symbol or number";
      } else {
        _passwordError = null;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Changed from transparent to avoid white flash
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_screen.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Username Field
          Positioned(
            left: MediaQuery.of(context).size.width * (260 / 896.0),
            top: MediaQuery.of(context).size.height * (150 / 414.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    "Username:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF542E2E),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Image.asset('assets/input-box.png', width: 240),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _usernameController,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            counterText: "",
                          ),
                          style: const TextStyle(fontSize: 16, color: Color(0xFF542E2E)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Password Field
          Positioned(
            left: MediaQuery.of(context).size.width * (260 / 896.0),
            top: MediaQuery.of(context).size.height * (210 / 414.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        "Password:",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF542E2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Image.asset('assets/input-box.png', width: 240),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 40.0),
                          child: SizedBox(
                            width: 160,
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _isObscured,
                              onChanged: _validatePassword,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 16, color: Color(0xFF542E2E)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                            child: Icon(
                              _isObscured ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF542E2E),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 110.0, top: 4),
                    child: Text(
                      _passwordError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Login Button
          Positioned(
            left: MediaQuery.of(context).size.width * (400 / 896.0),
            top: MediaQuery.of(context).size.height * (290 / 414.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (_usernameController.text.isEmpty ||
                    _passwordController.text.isEmpty ||
                    _passwordError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid username and password"),
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }
                print("Login Inner button pressed");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(username: _usernameController.text)),
                );
              },
              child: Image.asset(
                'assets/loginInner-btn.png',
                width: 120,
              ),
            ),
          ),
          // Back Button
          Positioned(
            left: 20,
            top: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SplashScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Image.asset(
                'assets/back-btn.png',
                width: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

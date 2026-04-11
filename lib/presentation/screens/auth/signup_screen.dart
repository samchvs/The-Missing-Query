import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/domain/usecases/validate_password_usecase.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/screens/splash/splash_screen.dart';
import 'package:graphics_project/presentation/screens/home/home_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';

/// Signup screen — takes Email + Password only.
/// The username was already collected on UsernameEntryScreen and is passed in via [prefilledUsername].
enum SignupStep { username, credentials }

class SignupScreen extends StatefulWidget {
  final AuthController authController;

  const SignupScreen({
    super.key,
    required this.authController,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupStep _currentStep = SignupStep.username;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _validatePassword = const ValidatePasswordUseCase();
  bool _isObscured = true;
  String? _passwordError;
  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateUsername(String value) {
    if (value.trim().isEmpty) return 'Username cannot be empty';
    if (value.trim().length < 2) return 'At least 2 characters required';
    return null;
  }

  void _onNext() {
    final error = _validateUsername(_usernameController.text);
    if (error != null) {
      setState(() => _usernameError = error);
      return;
    }
    setState(() {
      _usernameError = null;
      _currentStep = SignupStep.credentials;
    });
  }

  Future<void> _onSignup() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email and password'),
          backgroundColor: AppColors.redAccent,
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await widget.authController.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: widget.authController.displayUsername,
            authController: widget.authController,
          ),
          settings: const RouteSettings(name: '/home'),
        ),
        (route) => false,
      );
    } else {
      final msg = widget.authController.errorMessage ?? 'Signup failed';
      widget.authController.clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _onSkip() async {
    FocusScope.of(context).unfocus();
    final username = _usernameController.text.trim();
    await widget.authController.saveGuestUsername(username);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          username: username,
          authController: widget.authController,
        ),
        settings: const RouteSettings(name: '/home'),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authController,
      builder: (context, _) {
        final controller = widget.authController;
        return Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.signupScreen),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // First Input Field (Username or Email)
          Positioned(
            left: MediaQuery.of(context).size.width * (260 / 896.0),
            top: MediaQuery.of(context).size.height * (150 / 414.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    _currentStep == SignupStep.username ? 'Username:' : 'Email:',
                    style: const TextStyle(fontSize: 18, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Image.asset(AppAssets.inputBox, width: 240),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _currentStep == SignupStep.username
                              ? _usernameController
                              : _emailController,
                          focusNode: _currentStep == SignupStep.username
                              ? _usernameFocus
                              : _emailFocus,
                          keyboardType: _currentStep == SignupStep.username
                              ? TextInputType.text
                              : TextInputType.emailAddress,
                          onChanged: (v) {
                            if (_currentStep == SignupStep.username) {
                              setState(() => _usernameError = _validateUsername(v));
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Second Input Field (Visible only in credentials step)
          if (_currentStep == SignupStep.credentials)
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
                          'Password:',
                          style: TextStyle(fontSize: 18, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Image.asset(AppAssets.inputBox, width: 240),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 40.0),
                            child: SizedBox(
                              width: 160,
                              child: TextField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _isObscured,
                                onChanged: (value) {
                                  setState(() {
                                    _passwordError = _validatePassword(value);
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isObscured = !_isObscured);
                              },
                              child: Icon(
                                _isObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primary,
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
                          color: AppColors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Username error message
          if (_currentStep == SignupStep.username && _usernameError != null)
            Positioned(
              left: MediaQuery.of(context).size.width * (370 / 896.0),
              top: MediaQuery.of(context).size.height * (195 / 414.0),
              child: Text(
                _usernameError!,
                style: const TextStyle(
                  color: AppColors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Main Button (Next or Sign Up)
          Positioned(
            left: MediaQuery.of(context).size.width * (400 / 896.0),
            top: MediaQuery.of(context).size.height * (290 / 414.0),
            child: controller.isLoading
                ? const SizedBox(
                    width: 120,
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : BouncingButton(
                    onPressed: _currentStep == SignupStep.username ? _onNext : _onSignup,
                    child: Image.asset(
                      _currentStep == SignupStep.username ? AppAssets.nextBtn : AppAssets.signupInnerBtn,
                      width: 120,
                    ),
                  ),
          ),
          // Skip Button (Visible only in credentials step)
          if (_currentStep == SignupStep.credentials)
            Positioned(
              left: MediaQuery.of(context).size.width * (400 / 896.0),
              top: MediaQuery.of(context).size.height * (340 / 414.0),
              child: BouncingButton(
                onPressed: _onSkip,
                child: const Text(
                  'PLAY AS GUEST (SKIP)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          // Back Button
          Positioned(
            left: 20,
            top: 20,
            child: BouncingButton(
              onPressed: () {
                if (_currentStep == SignupStep.credentials) {
                  setState(() => _currentStep = SignupStep.username);
                } else {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, _, __) => SplashScreen(
                        authController: widget.authController,
                      ),
                      transitionsBuilder: (context, animation, __, child) {
                        const begin = Offset(-1.0, 0.0);
                        const end = Offset.zero;
                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: Curves.easeInOut));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                }
              },
              child: Image.asset(AppAssets.backBtn, width: 50),
            ),
          ),
          KeyboardAccessoryBar(
            controller: _currentStep == SignupStep.username ? _usernameController : _emailController,
            focusNode: _currentStep == SignupStep.username ? _usernameFocus : _emailFocus,
          ),
          if (_currentStep == SignupStep.credentials)
            KeyboardAccessoryBar(
              controller: _passwordController,
              focusNode: _passwordFocus,
            ),
        ],
      ),
        ); // Scaffold
      }, // builder
    ); // ListenableBuilder
  }
}

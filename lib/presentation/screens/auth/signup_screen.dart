import 'package:flutter/material.dart';
import 'package:graphics_project/core/constants/app_assets.dart';
import 'package:graphics_project/core/constants/app_colors.dart';
import 'package:graphics_project/domain/usecases/validate_password_usecase.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/screens/splash/splash_screen.dart';
import 'package:graphics_project/presentation/screens/home/home_screen.dart';
import 'package:graphics_project/presentation/widgets/common/bouncing_button.dart';
import 'package:graphics_project/presentation/widgets/common/keyboard_accessory_bar.dart';
import 'package:graphics_project/presentation/controllers/home_music_controller.dart';

/// Signup screen — takes Username, Email + Password.
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  final _validatePassword = const ValidatePasswordUseCase();
  bool _isObscured = true;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    HomeMusicController().play();
  }

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
    if (value.trim().isEmpty) return 'Username required';
    if (value.trim().length < 2) return 'At least 2 characters';
    return null;
  }

  Future<void> _onSignup() async {
    FocusScope.of(context).unfocus();

    final uError = _validateUsername(_usernameController.text);
    if (uError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(uError),
          backgroundColor: AppColors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid email and password'),
          backgroundColor: AppColors.redAccent,
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
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authController,
      builder: (context, _) {
        final controller = widget.authController;
        final size = MediaQuery.of(context).size;

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
              
              // 1. Username Field
              Positioned(
                left: size.width * (300 / 896.0),
                top: size.height * (155 / 414.0),
                child: _buildInputRow(
                  label: 'Username:',
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                ),
              ),

              // 2. Email Field
              Positioned(
                left: size.width * (300 / 896.0),
                top: size.height * (200 / 414.0),
                child: _buildInputRow(
                  label: 'Email:',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  inputType: TextInputType.emailAddress,
                ),
              ),

              // 3. Password Field
              Positioned(
                left: size.width * (300 / 896.0),
                top: size.height * (245 / 414.0),
                child: _buildInputRow(
                  label: 'Password:',
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  isPassword: true,
                  onChanged: (v) {
                    setState(() => _passwordError = _validatePassword(v));
                  },
                ),
              ),

              // Sign Up Button
              Positioned(
                left: size.width * (400 / 896.0),
                top: size.height * (295 / 414.0),
                child: controller.isLoading
                    ? _buildLoading()
                    : BouncingButton(
                        onPressed: _onSignup,
                        child: Image.asset(AppAssets.signupInnerBtn, width: 100),
                      ),
              ),

              // Back Button
              Positioned(
                left: 20,
                top: 20,
                child: BouncingButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SplashScreen(authController: widget.authController),
                      ),
                    );
                  },
                  child: Image.asset(AppAssets.backBtn, width: 50),
                ),
              ),

              KeyboardAccessoryBar(controller: _usernameController, focusNode: _usernameFocus),
              KeyboardAccessoryBar(controller: _emailController, focusNode: _emailFocus),
              KeyboardAccessoryBar(controller: _passwordController, focusNode: _passwordFocus),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Image.asset(AppAssets.inputBox, width: 190), 
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 35.0),
              child: SizedBox(
                width: 140,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword && _isObscured,
                  keyboardType: inputType,
                  onChanged: (v) {
                    if (onChanged != null) onChanged(v);
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14, color: AppColors.primary),
                ),
              ),
            ),
            if (isPassword)
              Positioned(
                right: 15,
                child: GestureDetector(
                  onTap: () => setState(() => _isObscured = !_isObscured),
                  child: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }



  Widget _buildLoading() {
    return const SizedBox(
      width: 120,
      height: 40,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
    );
  }
}

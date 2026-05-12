import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphics_project/core/config/supabase_config.dart';
import 'package:graphics_project/presentation/controllers/auth_controller.dart';
import 'package:graphics_project/presentation/controllers/points_controller.dart';
import 'package:graphics_project/presentation/controllers/lives_controller.dart';
import 'package:graphics_project/presentation/screens/home/home_screen.dart';
import 'package:graphics_project/presentation/screens/splash/splash_screen.dart';
import 'package:graphics_project/presentation/screens/splash/loading_screen.dart';
import 'package:graphics_project/presentation/widgets/common/developer_error_box.dart';
import 'package:graphics_project/core/constants/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialise Supabase (must be done before AuthController.create())
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Pre-load auth state (local username + Supabase session)
  final authController = await AuthController.create();

  runApp(MyApp(authController: authController));
}

class MyApp extends StatelessWidget {
  final AuthController authController;

  const MyApp({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    // Decide the initial route based on persisted state
    final Widget nextScreen = authController.localUsername != null
        ? HomeScreen(
            username: authController.displayUsername,
            authController: authController,
          )
        : SplashScreen(authController: authController);

    final Widget home = LoadingScreen(nextScreen: nextScreen);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<PointsController>.value(value: PointsController.instance),
        ChangeNotifierProvider<LivesController>.value(value: LivesController.instance),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          canvasColor: Colors.black,
          textTheme: GoogleFonts.luckiestGuyTextTheme(),
        ),
        home: home,
        navigatorObservers: [AppRoutes.routeObserver],
        builder: (context, child) {
          return Stack(
            children: [
              ?child,
              // This makes the error box available globally
              DeveloperErrorBox(),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/theme.dart';
import 'utils/app_routes.dart';
import 'services/auth_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching to prevent black screen on emulators
  // without internet. Fonts will fall back to system defaults gracefully.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Create AuthService immediately — initialization happens async in splash.
  final authService = AuthService();

  // Launch the app IMMEDIATELY — don't block on Firebase or AuthService init.
  // Heavy initialization is deferred to the splash screen so the UI renders
  // right away instead of showing a black screen on slow emulators.
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: authService),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => UserViewModel(authService)),
      ],
      child: const BmiApp(),
    ),
  );
}

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

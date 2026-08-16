import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/auth_service.dart';
import '../utils/app_routes.dart';
import '../viewmodels/user_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Performs all heavy initialization (Firebase + AuthService) here,
  /// AFTER the splash screen is already visible — preventing the black screen.
  Future<void> _initializeApp() async {
    // 1. Initialize Firebase
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }

    // 2. Initialize AuthService (loads profiles from SharedPreferences)
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.init();
    } catch (e, st) {
      debugPrint('AuthService init failed: $e');
      debugPrint('$st');
    }

    if (!mounted) return;

    // 3. Reload user data in the ViewModel
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    userVM.loadUser();

    setState(() => _initDone = true);

    // 4. Small delay for splash animation, then navigate
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (userVM.currentUser != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final isLoggedIn = _initDone && userVM.currentUser != null;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/splash.json',
                width: screenHeight * 0.28,
                height: screenHeight * 0.28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite_rounded,
                    size: 80,
                    color: Color(0xFFF92B54),
                  );
                },
              ),
              const SizedBox(height: 16),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Welcome to Vermo — Know Your BMI, Instantly.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (!_initDone)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFF92B54),
                  ),
                ),
              if (_initDone && !isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    label: const Icon(Icons.arrow_forward, size: 20),
                  ),
                ),
              if (isLoggedIn) const SizedBox(height: 56),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

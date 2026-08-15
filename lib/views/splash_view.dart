import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../utils/app_routes.dart';
import '../viewmodels/user_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    
    if (userVM.currentUser != null) {
      // If authenticated, small delay to show splash animation gracefully, then navigate to Dashboard
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      userVM.loadUser();
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
    // If not authenticated, we do nothing and wait for the "Get Started" button press.
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final isLoggedIn = userVM.currentUser != null;

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
                width: 250,
                height: 250,
                fit: BoxFit.contain,
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
              if (!isLoggedIn)
                ElevatedButton(
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
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isLoggedIn)
                const SizedBox(height: 56), // Keep layout stable
                
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

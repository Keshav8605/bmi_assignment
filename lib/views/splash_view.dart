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
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2.5 seconds to show splash
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    final userVM = Provider.of<UserViewModel>(context, listen: false);

    if (userVM.currentUser != null) {
      userVM.loadUser();
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Extra space at bottom offsets the content slightly upwards
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

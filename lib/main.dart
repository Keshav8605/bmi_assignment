import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/theme.dart';
import 'utils/app_routes.dart';
import 'services/auth_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: authService),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => UserViewModel(authService)),
      ],
      child: BmiApp(authService: authService),
    ),
  );
}

class BmiApp extends StatelessWidget {
  final AuthService authService;
  
  const BmiApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium BMI App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

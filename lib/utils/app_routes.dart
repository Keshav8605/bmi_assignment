import 'package:flutter/material.dart';

import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/user_details_view.dart';
import '../views/dashboard_view.dart';
import '../views/settings_view.dart';
import '../views/splash_view.dart';
import '../views/main_view.dart';
import '../views/gender_selection_view.dart';
import '../views/goal_setting_view.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String userDetails = '/user_details';
  static const String dashboard = '/dashboard';
  static const String main = '/main';
  static const String settings = '/settings';
  static const String genderSelection = '/gender_selection';
  static const String goalSetting = '/goal_setting';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashView(),
      login: (context) => const LoginView(),
      signup: (context) => const SignupView(),
      userDetails: (context) => const UserDetailsView(),
      dashboard: (context) => const DashboardView(),
      main: (context) => const MainView(),
      settings: (context) => const SettingsView(),
      genderSelection: (context) => const GenderSelectionView(),
      goalSetting: (context) => const GoalSettingView(),
    };
  }
}

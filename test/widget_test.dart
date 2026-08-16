import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bmi_app/main.dart';
import 'package:bmi_app/services/auth_service.dart';
import 'package:bmi_app/viewmodels/auth_viewmodel.dart';
import 'package:bmi_app/viewmodels/user_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final authService = AuthService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: authService),
          ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
          ChangeNotifierProvider(create: (_) => UserViewModel(authService)),
        ],
        child: const BmiApp(),
      ),
    );

    // Verify that splash screen text is present
    expect(find.text('Welcome to Vermo — Know Your BMI, Instantly.'), findsOneWidget);
  });
}

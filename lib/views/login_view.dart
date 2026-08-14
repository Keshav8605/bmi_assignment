import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import 'widgets/premium_loader.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.login(_emailController.text, _passwordController.text);
    
    if (success && mounted) {
      Provider.of<UserViewModel>(context, listen: false).loadUser();
      Navigator.pushReplacementNamed(context, AppRoutes.genderSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = Provider.of<AuthViewModel>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: PremiumLoader(
        isLoading: authVM.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo Placeholder
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.change_history, size: 80, color: theme.primaryColor),
                        Positioned(
                          top: 10,
                          child: Icon(Icons.change_history, size: 50, color: theme.primaryColor.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vermo',
                      style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Social Login Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: authVM.isLoading ? null : _login,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 20),
                      label: Text('Facebook', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: authVM.isLoading ? null : _login,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 28), // Google icon placeholder
                      label: Text('Google', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Center(child: Text('or', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400))),
              const SizedBox(height: 32),
              
              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email ID',
                ),
              ),
              const SizedBox(height: 24),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              
              // Forgot Password
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Login Button
              ElevatedButton(
                onPressed: authVM.isLoading ? null : _login,
                child: const Text('Login'),
              ),
              
              const SizedBox(height: 48),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.signup);
                    },
                    child: Text(
                      'Register Now',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

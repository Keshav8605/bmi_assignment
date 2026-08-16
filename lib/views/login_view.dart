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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.login(email, password);

    if (success && mounted) {
      Provider.of<UserViewModel>(context, listen: false).loadUser();
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect email or password.')),
      );
    }
  }

  void _googleLogin() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.loginWithGoogle();

    if (success && mounted) {
      Provider.of<UserViewModel>(context, listen: false).loadUser();
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;

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
                SizedBox(height: screenHeight * 0.06),
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
                        'Vero',
                        style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email ID'),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Forgot Password feature coming soon.')),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: Text('or', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400))),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: authVM.isLoading ? null : _googleLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 28),
                  label: Text('Continue with Google', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authVM.isLoading ? null : _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: Text(
                        'Register Now',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../utils/app_routes.dart';
import 'widgets/premium_loader.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all required fields.')));
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.register(name, email, password);
    
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: PremiumLoader(
        isLoading: authVM.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register to Vermo',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 32),
              
              // Full Name Field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              const SizedBox(height: 24),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 24),
              
              // Mobile Number Field
              const TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
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
              const SizedBox(height: 24),
              
              // Confirm Password Field
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
              const SizedBox(height: 48),
              
              // Sign Up Button
              ElevatedButton(
                onPressed: authVM.isLoading ? null : _signup,
                child: const Text('Register'),
              ),
              
              const SizedBox(height: 24),
              
              // Terms and Privacy Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  children: [
                    const TextSpan(text: 'By registering you agree to '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '\nand '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' of the Vermo'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

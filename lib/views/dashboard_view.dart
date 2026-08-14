import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_routes.dart';
import 'widgets/premium_loader.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback? onAnalyticsTap;

  const DashboardView({super.key, this.onAnalyticsTap});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: PremiumLoader(
          isLoading: _isLoading,
          child: Consumer<UserViewModel>(
            builder: (context, userVM, child) {
              final user = userVM.currentUser;
              final bmiValue = userVM.bmiValue;
              final bmiCategory = userVM.bmiCategory;
              
              if (user == null) {
                return const Center(child: Text('No User Found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User Greeting Header with Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                                child: Icon(Icons.person, color: theme.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, ${user.name}', 
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Track your health today', 
                                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.logout),
                              color: Colors.black87,
                              onPressed: () {
                                Provider.of<AuthViewModel>(context, listen: false).logout();
                                Navigator.pushReplacementNamed(context, AppRoutes.login);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Main BMI Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ]
                      ),
                      child: Column(
                        children: [
                          Text('Your Current BMI', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70)),
                          const SizedBox(height: 16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              bmiValue.toStringAsFixed(1), 
                              style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                bmiCategory,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text("Quick Actions", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context, 
                            icon: Icons.monitor_weight_outlined, 
                            title: "Update Vitals", 
                            color: Colors.blueAccent,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.userDetails),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionCard(
                            context, 
                            icon: Icons.analytics_outlined, 
                            title: "Full Analytics", 
                            color: Colors.purpleAccent,
                            onTap: widget.onAnalyticsTap ?? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Use the Analytics tab below'))
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, {required IconData icon, required String title, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

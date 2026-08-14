import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_routes.dart';
import 'widgets/premium_loader.dart';
import '../services/pdf_service.dart';

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
                    
                    // Goal Section
                    _buildGoalSection(context, user, userVM),
                    const SizedBox(height: 32),
                    
                    Text("Quick Actions", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.history,
                            title: "View History",
                            color: Colors.orange,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.main),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            icon: Icons.picture_as_pdf,
                            title: "Export Report",
                            color: Colors.redAccent,
                            onTap: () => _showExportOptions(context, user, userVM),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildGoalSection(BuildContext context, user, UserViewModel userVM) {
    final theme = Theme.of(context);
    
    if (user.targetWeight == null || user.targetDate == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Target Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Set a goal to stay motivated.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.goalSetting),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Set Goal', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }
    
    // Calculate progress
    final double startW = user.history.isNotEmpty ? user.history.last.weight : user.weight; 
    final double currentW = user.weight;
    final double targetW = user.targetWeight!;
    
    // Progress calculation (0 to 1)
    double progress = 0.0;
    if (startW != targetW) {
      final totalDiff = (targetW - startW).abs();
      final currentDiff = (currentW - startW).abs();
      progress = (currentDiff / totalDiff).clamp(0.0, 1.0);
      
      // If we are moving in the wrong direction (e.g. want to lose, but gained), progress is 0.
      if ((targetW < startW && currentW > startW) || (targetW > startW && currentW < startW)) {
        progress = 0.0;
      }
      
      // If we passed the target, progress is 1.0
      if ((targetW < startW && currentW <= targetW) || (targetW > startW && currentW >= targetW)) {
        progress = 1.0;
      }
    } else {
      progress = 1.0; // Target is same as start
    }
    
    final remaining = (currentW - targetW).abs();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current ${currentW.toStringAsFixed(1)} kg", 
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              Text(
                "Target ${targetW.toStringAsFixed(1)} kg", 
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${remaining.toStringAsFixed(1)} kg to your target",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.goalSetting),
                child: const Icon(Icons.edit, size: 20, color: Colors.grey),
              )
            ],
          )
        ],
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
  
  void _showExportOptions(BuildContext context, user, UserViewModel userVM) {
    final pdfService = PdfService();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Export Health Report",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Generate a PDF containing your profile, BMI, and history.",
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: const Icon(Icons.download, color: Colors.blue),
                  ),
                  title: const Text("Download PDF", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Save to your device"),
                  onTap: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating PDF...')),
                    );
                    final path = await pdfService.downloadReport(user, userVM);
                    if (!context.mounted) return;
                    if (path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved to: $path')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save PDF.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    child: const Icon(Icons.share, color: Colors.green),
                  ),
                  title: const Text("Share Report", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Send via WhatsApp, Email, etc."),
                  onTap: () {
                    Navigator.pop(context);
                    pdfService.shareReport(user, userVM);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

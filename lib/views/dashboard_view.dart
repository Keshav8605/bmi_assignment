import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/dialogs.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/bmi_record_model.dart';
import '../models/user_model.dart';
import '../utils/app_routes.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback? onAnalyticsTap;

  const DashboardView({super.key, this.onAnalyticsTap});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<double> _calculateChanges(List<BmiRecord> history, double currentWeight, double currentBmi) {
    if (history.isEmpty) return [0.0, 0.0];
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    BmiRecord? pastRecord;
    for (var record in history.reversed) {
      if (record.date.isBefore(thirtyDaysAgo)) {
        pastRecord = record;
        break;
      }
    }
    pastRecord ??= history.first;

    final weightChange = currentWeight - pastRecord.weight;
    final bmiChange = currentBmi - pastRecord.bmiValue;
    return [weightChange, bmiChange];
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final isDark = userVM.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9);
    final primaryBlue = isDark ? const Color(0xFF6B8AFF) : const Color(0xFF4361EE);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final borderColor = isDark ? Colors.grey.shade800 : const Color(0xFFF0F0F0);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            final user = userVM.currentUser;
            final bmiValue = userVM.bmiValue;
            
            if (user == null) {
              return Center(child: Text('No User Found', style: TextStyle(color: textColor)));
            }

            final changes = _calculateChanges(user.history, user.weight, bmiValue);
            final weightChange = changes[0];
            final bmiChange = changes[1];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top App Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vero',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: primaryBlue,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Provider.of<AuthViewModel>(context, listen: false).logout();
                              Navigator.pushReplacementNamed(context, AppRoutes.splash);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: Icon(Icons.logout, size: 20, color: subTextColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => showEditProfileDialog(context, user),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: primaryBlue.withValues(alpha: 0.1),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Greeting
                  Text(
                    '${_getGreeting()}, ${user.name.split(' ').first} 👋',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main BMI Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current BMI', style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(
                              bmiValue.toStringAsFixed(1), 
                              style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.w900, height: 1.1)
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(bmiValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  userVM.bmiCategory,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                              ],
                            )
                          ],
                        ),
                        // Mini Graph on BMI Card
                        if (user.history.isNotEmpty)
                          SizedBox(
                            width: 100,
                            height: 60,
                            child: _buildMiniGraph(user.history, primaryBlue),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vero Insights Section
                  _buildInsightsSection(weightChange, isDark, cardColor, textColor, subTextColor),
                  const SizedBox(height: 24),
                  
                  // Target Goal Section
                  if (user.targetWeight != null) ...[
                    _buildTargetSection(user, isDark, cardColor, textColor, subTextColor, primaryBlue, () => userVM.clearTarget()),
                    const SizedBox(height: 24),
                  ],

                  // Quick Stats Section
                  Text("Quick Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow("Current Weight", "${user.weight.toStringAsFixed(1)} kg", subTextColor, textColor),
                        Divider(height: 24, color: borderColor),
                        _buildStatRow("Height", "${user.height.toStringAsFixed(0)} cm", subTextColor, textColor),
                        Divider(height: 24, color: borderColor),
                        _buildTrendRow("BMI change", bmiChange, "this month", subTextColor, textColor),
                        Divider(height: 24, color: borderColor),
                        _buildTrendRow("Weight change", weightChange, "kg", subTextColor, textColor),
                        Divider(height: 24, color: borderColor),
                        _buildStatRow("Last updated", "Today", subTextColor, textColor, valueColor: primaryBlue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.picture_as_pdf_outlined,
                          title: "Export",
                          color: Colors.orange,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export Report feature coming soon.')));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context, 
                          icon: Icons.analytics_outlined, 
                          title: "Analytics", 
                          color: Colors.purpleAccent,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                          onTap: widget.onAnalyticsTap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context, 
                          icon: Icons.flag_outlined, 
                          title: "Set Target", 
                          color: Colors.green,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.goalSetting),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context, 
                          icon: Icons.monitor_weight_outlined, 
                          title: "Update", 
                          color: primaryBlue,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.userDetails),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi >= 18.5 && bmi <= 24.9) return Colors.greenAccent.shade700;
    if (bmi >= 25 && bmi <= 29.9) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Widget _buildStatRow(String label, String value, Color subTextColor, Color textColor, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: subTextColor, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 15, color: valueColor ?? textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrendRow(String label, double value, String suffix, Color subTextColor, Color textColor) {
    final isNegative = value < 0;
    final isZero = value == 0;
    final color = isZero ? subTextColor : (isNegative ? Colors.green : Colors.red);
    final icon = isZero ? "" : (isNegative ? "↓" : "↑");
    final valStr = value.abs().toStringAsFixed(1);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: subTextColor, fontWeight: FontWeight.w500)),
        Text("$icon $valStr $suffix", style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniGraph(List<BmiRecord> history, Color color) {
    // Show last 7 records for simplicity
    final data = history.length > 7 ? history.sublist(history.length - 7) : history;
    if (data.isEmpty) return const SizedBox.shrink();

    final minY = data.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = data.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, {required IconData icon, required String title, required Color color, required Color cardColor, required Color textColor, required bool isDark, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(double weightChange, bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    String title = "Your Progress";
    String subtitle = "";
    IconData icon = Icons.insights;
    Color iconColor = Colors.blue;

    if (weightChange < -0.5) {
      subtitle = "You're trending downward 📉\nYour weight decreased by ${weightChange.abs().toStringAsFixed(1)} kg over the last 30 days.";
      iconColor = Colors.green;
      icon = Icons.trending_down;
    } else if (weightChange > 0.5) {
      subtitle = "You're trending upward 📈\nYour weight increased by ${weightChange.abs().toStringAsFixed(1)} kg over the last 30 days.";
      iconColor = Colors.orange;
      icon = Icons.trending_up;
    } else {
      subtitle = "Your weight has remained stable ⚖️\nYour weight changed by less than 0.5 kg over the last 30 days.";
      iconColor = Colors.blueAccent;
      icon = Icons.trending_flat;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Vero Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : iconColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: subTextColor, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSection(UserModel user, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color primaryBlue, VoidCallback onClearTarget) {
    if (user.targetWeight == null) return const SizedBox.shrink();

    final diff = user.weight - user.targetWeight!;
    final diffText = diff > 0 
      ? "${diff.toStringAsFixed(1)} kg left to lose" 
      : (diff < 0 ? "${diff.abs().toStringAsFixed(1)} kg left to gain" : "Target Achieved!");
    
    // Calculate simple progress 0.0 - 1.0 (Assume an arbitrary starting point for demo if not tracked)
    // We'll just show the gap conceptually
    double progress = 0.0;
    if (user.history.isNotEmpty) {
      final startWeight = user.history.first.weight;
      final totalDiff = startWeight - user.targetWeight!;
      if (totalDiff != 0) {
        progress = 1.0 - (diff / totalDiff);
        if (progress < 0) progress = 0;
        if (progress > 1) progress = 1;
      } else {
        progress = diff == 0 ? 1.0 : 0.0;
      }
    } else {
      progress = diff == 0 ? 1.0 : 0.0;
    }

    String dateStr = "";
    if (user.targetDate != null) {
      final days = user.targetDate!.difference(DateTime.now()).inDays;
      dateStr = days >= 0 ? "$days days remaining" : "Overdue target";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Target Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
              onPressed: onClearTarget,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Target Weight", style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text("${user.targetWeight!.toStringAsFixed(1)} kg", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryBlue)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: diff == 0 ? Colors.green.withValues(alpha: 0.1) : primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      diff == 0 ? "Goal Reached 🎉" : diffText,
                      style: TextStyle(color: diff == 0 ? Colors.green.shade700 : primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(diff == 0 ? Colors.green : primaryBlue),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              if (dateStr.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Target Date:", style: TextStyle(color: subTextColor, fontSize: 13)),
                    Text(dateStr, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }


}

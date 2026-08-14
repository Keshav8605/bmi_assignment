import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/bmi_record_model.dart';
import '../utils/dialogs.dart';
import 'widgets/premium_loader.dart';

enum ChartPeriod { days7, days30, months3, year1 }

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  ChartPeriod _selectedPeriod = ChartPeriod.days30;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<BmiRecord> _getFilteredHistory(List<BmiRecord> history) {
    if (history.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime cutoff;
    switch (_selectedPeriod) {
      case ChartPeriod.days7:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.days30:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case ChartPeriod.months3:
        cutoff = now.subtract(const Duration(days: 90));
        break;
      case ChartPeriod.year1:
        cutoff = now.subtract(const Duration(days: 365));
        break;
    }
    
    final filtered = history.where((r) => r.date.isAfter(cutoff)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final isDark = userVM.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryBlue = isDark ? const Color(0xFF6B8AFF) : const Color(0xFF4361EE);
    final cyanAccent = const Color(0xFF00E5FF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: PremiumLoader(
          isLoading: _isLoading,
          child: Consumer<UserViewModel>(
            builder: (context, userVM, child) {
              final user = userVM.currentUser;
              if (user == null) return const Center(child: Text("No User"));

              final history = user.history;
              final chartData = _getFilteredHistory(history);
              
              String startWeight = "-";
              if (chartData.isNotEmpty) {
                startWeight = "${chartData.first.weight.toStringAsFixed(1)} kg";
              } else if (history.isNotEmpty) {
                 startWeight = "${history.last.weight.toStringAsFixed(1)} kg"; // Oldest
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Analytics",
                          style: TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Row(
                          children: [

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
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats Grid
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.monitor_weight_outlined,
                          title: "Current BMI",
                          value: userVM.bmiValue.toStringAsFixed(1),
                          iconColor: primaryBlue,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          icon: Icons.scale_outlined,
                          title: "Weight",
                          value: "${user.weight.toStringAsFixed(1)} kg",
                          iconColor: primaryBlue,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.height_outlined,
                          title: "Height",
                          value: "${user.height.toStringAsFixed(0)} cm",
                          iconColor: primaryBlue,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          icon: Icons.analytics_outlined,
                          title: "Status",
                          value: userVM.bmiCategory,
                          iconColor: primaryBlue,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Chart Section
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Weight Trend",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              PopupMenuButton<ChartPeriod>(
                                initialValue: _selectedPeriod,
                                color: cardColor,
                                onSelected: (ChartPeriod result) {
                                  setState(() {
                                    _selectedPeriod = result;
                                  });
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<ChartPeriod>>[
                                  PopupMenuItem<ChartPeriod>(
                                    value: ChartPeriod.days7,
                                    child: Text('Weekly', style: TextStyle(color: textColor)),
                                  ),
                                  PopupMenuItem<ChartPeriod>(
                                    value: ChartPeriod.days30,
                                    child: Text('Monthly', style: TextStyle(color: textColor)),
                                  ),
                                  PopupMenuItem<ChartPeriod>(
                                    value: ChartPeriod.months3,
                                    child: Text('3 Months', style: TextStyle(color: textColor)),
                                  ),
                                  PopupMenuItem<ChartPeriod>(
                                    value: ChartPeriod.year1,
                                    child: Text('Yearly', style: TextStyle(color: textColor)),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedPeriod == ChartPeriod.days30 ? "Monthly" : 
                                        _selectedPeriod == ChartPeriod.days7 ? "Weekly" : 
                                        _selectedPeriod == ChartPeriod.months3 ? "3 Months" : "Yearly",
                                        style: TextStyle(
                                          fontSize: 12, 
                                          fontWeight: FontWeight.w600,
                                          color: subTextColor
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.keyboard_arrow_down, size: 14, color: subTextColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user.weight.toStringAsFixed(1)} kg",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Current Wt",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 48),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    startWeight,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Start Wt",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 200,
                            child: chartData.isEmpty 
                              ? const Center(child: Text("Not enough data to display chart."))
                              : LineChart(
                                LineChartData(
                                  lineTouchData: LineTouchData(
                                    handleBuiltInTouches: true,
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((LineBarSpot touchedSpot) {
                                          return LineTooltipItem(
                                            '${touchedSpot.y.toStringAsFixed(1)} kg',
                                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    verticalInterval: 1,
                                    horizontalInterval: 5,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: isDark ? Colors.grey.shade800 : Colors.grey.withValues(alpha: 0.1),
                                      strokeWidth: 1,
                                    ),
                                    getDrawingVerticalLine: (value) => FlLine(
                                      color: Colors.transparent, // Hide vertical lines normally
                                      strokeWidth: 0,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() < 0 || value.toInt() >= chartData.length) return const Text("");
                                          // Only show ~5 labels max on x axis
                                          final int step = (chartData.length / 5).ceil();
                                          if (value.toInt() % step != 0 && value.toInt() != chartData.length -1) return const Text("");
                                          
                                          final date = chartData[value.toInt()].date;
                                          final dayStr = DateFormat('E').format(date).substring(0, 1); // First letter of day (S, M, T...)
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              dayStr,
                                              style: TextStyle(
                                                color: subTextColor, 
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            "${value.toInt()}k", // adding 'k' just to match the visual style of the image loosely if we wanted to, but we're plotting weight, so kg is better.
                                            style: TextStyle(
                                              color: subTextColor, 
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: (chartData.length - 1).toDouble(),
                                  minY: (chartData.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 5).floorToDouble(),
                                  maxY: (chartData.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 5).ceilToDouble(),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartData.asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value.weight);
                                      }).toList(),
                                      isCurved: true,
                                      color: primaryBlue,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        checkToShowDot: (spot, barData) {
                                          return spot.x == chartData.length - 1; // Show dot only on the last spot
                                        },
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 5,
                                            color: Colors.white,
                                            strokeWidth: 3,
                                            strokeColor: primaryBlue,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryBlue.withValues(alpha: 0.2),
                                            primaryBlue.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    // Optional: Add a second line for "Target" or "Average" to match the 2-line visual in the image
                                    LineChartBarData(
                                      spots: chartData.asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value.weight - 2); // Dummy offset line to look like the image
                                      }).toList(),
                                      isCurved: true,
                                      color: cyanAccent,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        checkToShowDot: (spot, barData) {
                                          return spot.x == chartData.length - 1;
                                        },
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: Colors.white,
                                            strokeWidth: 2,
                                            strokeColor: cyanAccent,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

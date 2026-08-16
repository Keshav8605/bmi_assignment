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

  String _periodLabel(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.days7: return "Weekly";
      case ChartPeriod.days30: return "Monthly";
      case ChartPeriod.months3: return "3 Months";
      case ChartPeriod.year1: return "Yearly";
    }
  }

  List<BmiRecord> _getFilteredHistory(List<BmiRecord> history) {
    if (history.isEmpty) return [];

    final now = DateTime.now();
    final days = switch (_selectedPeriod) {
      ChartPeriod.days7 => 7,
      ChartPeriod.days30 => 30,
      ChartPeriod.months3 => 90,
      ChartPeriod.year1 => 365,
    };
    final cutoff = now.subtract(Duration(days: days));

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
            BoxShadow(color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor)),
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
                startWeight = "${history.last.weight.toStringAsFixed(1)} kg";
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnalyticsHeader(user, primaryBlue, textColor),
                    const SizedBox(height: 24),
                    _buildStatsGrid(userVM, primaryBlue, cardColor, textColor, subTextColor, isDark),
                    const SizedBox(height: 32),
                    _buildChartSection(user, chartData, startWeight, bgColor, cardColor, primaryBlue, cyanAccent, textColor, subTextColor, isDark),
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

  Widget _buildAnalyticsHeader(dynamic user, Color primaryBlue, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Analytics", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
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
    );
  }

  Widget _buildStatsGrid(UserViewModel userVM, Color primaryBlue, Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    final user = userVM.currentUser!;
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(icon: Icons.monitor_weight_outlined, title: "Current BMI", value: userVM.bmiValue.toStringAsFixed(1), iconColor: primaryBlue, cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, isDark: isDark),
            const SizedBox(width: 16),
            _buildStatCard(icon: Icons.scale_outlined, title: "Weight", value: "${user.weight.toStringAsFixed(1)} kg", iconColor: primaryBlue, cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, isDark: isDark),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(icon: Icons.height_outlined, title: "Height", value: "${user.height.toStringAsFixed(0)} cm", iconColor: primaryBlue, cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, isDark: isDark),
            const SizedBox(width: 16),
            _buildStatCard(icon: Icons.analytics_outlined, title: "Status", value: userVM.bmiCategory, iconColor: primaryBlue, cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, isDark: isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(dynamic user, List<BmiRecord> chartData, String startWeight, Color bgColor, Color cardColor, Color primaryBlue, Color cyanAccent, Color textColor, Color subTextColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Weight Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              PopupMenuButton<ChartPeriod>(
                initialValue: _selectedPeriod,
                color: cardColor,
                onSelected: (result) => setState(() => _selectedPeriod = result),
                itemBuilder: (context) => ChartPeriod.values.map((p) =>
                  PopupMenuItem(value: p, child: Text(_periodLabel(p), style: TextStyle(color: textColor))),
                ).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Text(_periodLabel(_selectedPeriod), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subTextColor)),
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
              _buildWeightLabel("${user.weight.toStringAsFixed(1)} kg", "Current Wt", textColor, subTextColor),
              const SizedBox(width: 48),
              _buildWeightLabel(startWeight, "Start Wt", textColor, subTextColor),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: chartData.isEmpty
                ? const Center(child: Text("Not enough data to display chart."))
                : _buildLineChart(chartData, primaryBlue, cyanAccent, subTextColor, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLabel(String value, String label, Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLineChart(List<BmiRecord> chartData, Color primaryBlue, Color cyanAccent, Color subTextColor, bool isDark) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem('${spot.y.toStringAsFixed(1)} kg', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
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
          getDrawingVerticalLine: (value) => const FlLine(color: Colors.transparent, strokeWidth: 0),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= chartData.length) return const Text("");
                final step = (chartData.length / 5).ceil();
                if (value.toInt() % step != 0 && value.toInt() != chartData.length - 1) return const Text("");

                final dayStr = DateFormat('E').format(chartData[value.toInt()].date).substring(0, 1);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(dayStr, style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text("${value.toInt()}k", style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w500));
              },
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
          _buildChartLine(chartData, primaryBlue, showArea: true),
          _buildChartLine(chartData, cyanAccent, offset: -2),
        ],
      ),
    );
  }

  LineChartBarData _buildChartLine(List<BmiRecord> data, Color color, {bool showArea = false, double offset = 0}) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight + offset)).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) => spot.x == data.length - 1,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: showArea ? 5 : 4,
            color: Colors.white,
            strokeWidth: showArea ? 3 : 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: showArea,
        gradient: showArea
            ? LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/bmi_record_model.dart';
import 'widgets/premium_loader.dart';

enum ChartPeriod { days7, days30, months3, year1 }

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  ChartPeriod _selectedPeriod = ChartPeriod.days7;
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
    
    // Sort from oldest to newest for the chart
    final filtered = history.where((r) => r.date.isAfter(cutoff)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildToggleButton('7D', ChartPeriod.days7),
          _buildToggleButton('30D', ChartPeriod.days30),
          _buildToggleButton('3M', ChartPeriod.months3),
          _buildToggleButton('1Y', ChartPeriod.year1),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, ChartPeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: PremiumLoader(
        isLoading: _isLoading,
        child: Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            final user = userVM.currentUser;
            if (user == null) return const Center(child: Text("No User"));

            final history = user.history;
            final chartData = _getFilteredHistory(history);
            
            // Calculate 30-day changes for stats
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            final oldRecords = history.where((r) => r.date.isBefore(thirtyDaysAgo)).toList();
            oldRecords.sort((a, b) => b.date.compareTo(a.date)); // newest first
            
            double bmiChange = 0;
            double weightChange = 0;
            if (oldRecords.isNotEmpty && history.isNotEmpty) {
              // newest is history.first (assuming history is newest first)
              final currentWeight = user.weight;
              final currentBmi = userVM.bmiValue;
              
              final oldWeight = oldRecords.first.weight;
              final oldBmi = oldRecords.first.bmiValue;
              
              weightChange = currentWeight - oldWeight;
              bmiChange = currentBmi - oldBmi;
            }

            // Trend for selected period
            String trendText = "Not enough data";
            if (chartData.length >= 2) {
              final first = chartData.first.weight;
              final last = chartData.last.weight;
              final diff = last - first;
              
              String pText = "";
              switch (_selectedPeriod) {
                case ChartPeriod.days7: pText = "7 days"; break;
                case ChartPeriod.days30: pText = "30 days"; break;
                case ChartPeriod.months3: pText = "3 months"; break;
                case ChartPeriod.year1: pText = "1 year"; break;
              }
              
              if (diff < 0) {
                trendText = "↓ ${diff.abs().toStringAsFixed(1)} kg over the last $pText";
              } else if (diff > 0) {
                trendText = "↑ ${diff.abs().toStringAsFixed(1)} kg over the last $pText";
              } else {
                trendText = "Stable over the last $pText";
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Analytics",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Top Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Current BMI", style: TextStyle(color: Colors.grey.shade600)),
                                const SizedBox(height: 4),
                                Text(
                                  userVM.bmiValue.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "🟢 ${userVM.bmiCategory}",
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(),
                        ),
                        _buildInfoRow("Current Weight:", "${user.weight.toStringAsFixed(1)} kg"),
                        _buildInfoRow("Height:", "${user.height.toStringAsFixed(0)} cm"),
                        _buildInfoRow(
                          "BMI change:", 
                          "${bmiChange < 0 ? '↓' : '↑'} ${bmiChange.abs().toStringAsFixed(1)} this month",
                          valueColor: bmiChange <= 0 ? Colors.green : Colors.red,
                        ),
                        _buildInfoRow(
                          "Weight change:", 
                          "${weightChange < 0 ? '↓' : '↑'} ${weightChange.abs().toStringAsFixed(1)} kg",
                          valueColor: weightChange <= 0 ? Colors.green : Colors.red,
                        ),
                        _buildInfoRow("Last updated:", "Today", valueColor: Colors.grey.shade500),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Interactive Chart Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Weight History",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildPeriodToggle(),
                        const SizedBox(height: 24),
                        
                        // FlChart implementation
                        SizedBox(
                          height: 220,
                          child: chartData.isEmpty 
                            ? const Center(child: Text("Not enough data to display chart."))
                            : LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((LineBarSpot touchedSpot) {
                                        final record = chartData[touchedSpot.spotIndex];
                                        final dateStr = DateFormat('MMM d').format(record.date);
                                        return LineTooltipItem(
                                          '$dateStr\n',
                                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          children: [
                                            TextSpan(
                                              text: '${record.weight} kg',
                                              style: const TextStyle(fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 5,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    strokeWidth: 1,
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
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            DateFormat('MMM d').format(date),
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
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
                                // Adjust min/max Y nicely
                                minY: (chartData.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2).floorToDouble(),
                                maxY: (chartData.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2).ceilToDouble(),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: chartData.asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value.weight);
                                    }).toList(),
                                    isCurved: true,
                                    color: theme.primaryColor,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: chartData.length < 10, // Only show dots if few points
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: theme.primaryColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                        
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            "Your weight trend\n$trendText",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

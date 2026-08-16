import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';

class GoalSettingView extends StatefulWidget {
  const GoalSettingView({super.key});

  @override
  State<GoalSettingView> createState() => _GoalSettingViewState();
}

class _GoalSettingViewState extends State<GoalSettingView> {
  double _targetWeight = 70.0;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    if (userVM.currentUser?.targetWeight != null) {
      _targetWeight = userVM.currentUser!.targetWeight!;
    } else if (userVM.currentUser != null) {
      _targetWeight = userVM.currentUser!.weight - 2.0;
    }

    if (userVM.currentUser?.targetDate != null) {
      _targetDate = userVM.currentUser!.targetDate!;
    }
  }

  void _saveGoal() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    userVM.setTarget(_targetWeight, _targetDate);
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userVM = Provider.of<UserViewModel>(context);
    final currentWeight = userVM.currentUser?.weight ?? 0.0;

    final isDark = userVM.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final primaryBlue = isDark ? const Color(0xFF6B8AFF) : theme.primaryColor;

    final diff = currentWeight - _targetWeight;
    final diffText = diff > 0
        ? "Lose ${diff.toStringAsFixed(1)} kg"
        : (diff < 0 ? "Gain ${diff.abs().toStringAsFixed(1)} kg" : "Maintain weight");

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Set Your Goal",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Define your target weight and timeframe to stay motivated.",
                style: TextStyle(color: subTextColor, fontSize: 16),
              ),
              const SizedBox(height: 48),
              _buildTargetWeightCard(cardColor, textColor, primaryBlue, isDark, diffText, diff),
              const SizedBox(height: 24),
              _buildTargetDateCard(cardColor, textColor, subTextColor, primaryBlue, isDark),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Save Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetWeightCard(Color cardColor, Color textColor, Color primaryBlue, bool isDark, String diffText, double diff) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Target Weight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Text(
                "${_targetWeight.toStringAsFixed(1)} kg",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryBlue,
              inactiveTrackColor: primaryBlue.withValues(alpha: 0.2),
              thumbColor: primaryBlue,
              overlayColor: primaryBlue.withValues(alpha: 0.1),
              trackHeight: 8,
            ),
            child: Slider(
              value: _targetWeight,
              min: 30.0,
              max: 150.0,
              onChanged: (val) => setState(() => _targetWeight = val),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: diff > 0 ? Colors.green.withValues(alpha: 0.1) : primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              diffText,
              style: TextStyle(
                color: diff > 0 ? Colors.green.shade700 : primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDateCard(Color cardColor, Color textColor, Color subTextColor, Color primaryBlue, bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Target Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text(
                  "${_targetDate.day}/${_targetDate.month}/${_targetDate.year}",
                  style: TextStyle(fontSize: 16, color: subTextColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month, color: primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}

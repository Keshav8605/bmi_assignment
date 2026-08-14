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
      // Default to slightly less than current weight
      _targetWeight = userVM.currentUser!.weight - 2.0; 
    }
    
    if (userVM.currentUser?.targetDate != null) {
      _targetDate = userVM.currentUser!.targetDate!;
    }
  }

  void _saveGoal() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    userVM.setTarget(_targetWeight, _targetDate);
    Navigator.pop(context); // Return to Dashboard
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years out
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
      setState(() {
        _targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userVM = Provider.of<UserViewModel>(context);
    final currentWeight = userVM.currentUser?.weight ?? 0.0;
    
    final diff = currentWeight - _targetWeight;
    final diffText = diff > 0 
      ? "Lose ${diff.toStringAsFixed(1)} kg" 
      : (diff < 0 ? "Gain ${diff.abs().toStringAsFixed(1)} kg" : "Maintain weight");

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Define your target weight and timeframe to stay motivated.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 48),
              
              // Target Weight Card
              Container(
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Target Weight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          "${_targetWeight.toStringAsFixed(1)} kg",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: theme.primaryColor,
                        inactiveTrackColor: theme.primaryColor.withValues(alpha: 0.2),
                        thumbColor: theme.primaryColor,
                        overlayColor: theme.primaryColor.withValues(alpha: 0.1),
                        trackHeight: 8,
                      ),
                      child: Slider(
                        value: _targetWeight,
                        min: 30.0,
                        max: 150.0,
                        onChanged: (val) {
                          setState(() {
                            _targetWeight = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: diff > 0 ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        diffText,
                        style: TextStyle(
                          color: diff > 0 ? Colors.green.shade700 : Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Target Date Card
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Target Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            "${_targetDate.day}/${_targetDate.month}/${_targetDate.year}",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_month, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: theme.primaryColor,
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
}

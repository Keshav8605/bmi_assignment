import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_routes.dart';
import '../viewmodels/user_viewmodel.dart';

class UserDetailsView extends StatefulWidget {
  const UserDetailsView({super.key});

  @override
  State<UserDetailsView> createState() => _UserDetailsViewState();
}

class _UserDetailsViewState extends State<UserDetailsView> {
  // We manage the local state for sliders, then save to ViewModel
  double _weight = 53.0;
  double _height = 160.0;
  
  // Local unit toggles (syncs with userVM eventually)
  bool _isKg = true;
  bool _isCm = true;

  @override
  void initState() {
    super.initState();
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    _isKg = userVM.isKg;
    _isCm = userVM.isCm;
    
    if (userVM.currentUser != null) {
      _weight = userVM.currentUser!.weight;
      _height = userVM.currentUser!.height;
      
      // If we need to display in lbs/ft, convert for the slider max/mins
      if (!_isKg) _weight = _weight * 2.20462;
      if (!_isCm) _height = _height / 30.48; // using rough ft (e.g., 5.3)
    }
  }

  void _onNext() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    
    // Convert back to metric if stored locally in imperial
    double saveWeight = _weight;
    double saveHeight = _height;
    
    if (!_isKg) saveWeight = saveWeight / 2.20462;
    if (!_isCm) saveHeight = saveHeight * 30.48;

    userVM.toggleWeightUnit(_isKg);
    userVM.toggleHeightUnit(_isCm);
    userVM.updateVitals(weight: saveWeight, height: saveHeight);
    
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  Widget _buildUnitToggle({
    required bool isFirstActive,
    required String firstLabel,
    required String secondLabel,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final activeBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200;
    final activeTextColor = isDark ? Colors.white : Colors.black;
    final inactiveTextColor = isDark ? Colors.grey.shade500 : Colors.grey;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isFirstActive ? activeBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(firstLabel, style: TextStyle(fontSize: 10, fontWeight: isFirstActive ? FontWeight.bold : FontWeight.normal, color: isFirstActive ? activeTextColor : inactiveTextColor)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: !isFirstActive ? activeBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(secondLabel, style: TextStyle(fontSize: 10, fontWeight: !isFirstActive ? FontWeight.bold : FontWeight.normal, color: !isFirstActive ? activeTextColor : inactiveTextColor)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final String gender = userVM.currentUser?.gender ?? 'Female';
    final String imageAsset = gender == 'Female' ? 'assets/images/female.png' : 'assets/images/male.png';
    final isDark = userVM.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final pinkAccent = isDark ? const Color(0xFFFF7B93) : const Color(0xFFED5D73);
    final purpleSlider = isDark ? const Color(0xFFC062A4) : const Color(0xFF9E4784); // Purple from image

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Your height & weight',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Unit toggles row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildUnitToggle(
                    isFirstActive: _isKg, 
                    firstLabel: 'kg', 
                    secondLabel: 'lbs',
                    isDark: isDark,
                    onToggle: () {
                      setState(() {
                        if (_isKg) {
                           _weight = _weight * 2.20462; // convert to lbs
                        } else {
                           _weight = _weight / 2.20462; // convert to kg
                        }
                        _isKg = !_isKg;
                      });
                    }
                  ),
                  _buildUnitToggle(
                    isFirstActive: _isCm, 
                    firstLabel: 'cm', 
                    secondLabel: 'ft', 
                    isDark: isDark,
                    onToggle: () {
                      setState(() {
                        if (_isCm) {
                          _height = _height / 30.48; // convert to ft
                        } else {
                          _height = _height * 30.48; // convert to cm
                        }
                        _isCm = !_isCm;
                      });
                    }
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weight Slider
                    Expanded(
                      flex: 2,
                      child: CustomVerticalSlider(
                        value: _weight,
                        min: _isKg ? 20 : 44, // 20kg or 44lbs
                        max: _isKg ? 150 : 330, // 150kg or 330lbs
                        unit: _isKg ? 'kg' : 'lbs',
                        color: purpleSlider,
                        isLeftAligned: true,
                        title: 'Weight',
                        onChanged: (val) => setState(() => _weight = val),
                      ),
                    ),
                    
                    // Center Image
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Image.asset(
                          imageAsset,
                          height: 350,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              width: 80,
                              decoration: BoxDecoration(
                                color: gender == 'Female' ? Colors.pink.shade200 : Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Height Slider
                    Expanded(
                      flex: 2,
                      child: CustomVerticalSlider(
                        value: _height,
                        min: _isCm ? 100 : 3.0, // 100cm or 3ft
                        max: _isCm ? 220 : 7.5, // 220cm or 7.5ft
                        unit: _isCm ? 'cm' : 'ft',
                        color: purpleSlider,
                        isLeftAligned: false,
                        title: 'Height',
                        onChanged: (val) => setState(() => _height = val),
                        formatValue: (v) {
                          if (!_isCm) {
                            int ft = v.floor();
                            int inches = ((v - ft) * 12).round();
                            return "$ft'$inches";
                          }
                          return "${v.toInt()}";
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              // Next Button
              Center(
                child: InkWell(
                  onTap: _onNext,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: pinkAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: pinkAccent.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomVerticalSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final bool isLeftAligned;
  final String title;
  final ValueChanged<double> onChanged;
  final String Function(double)? formatValue;

  const CustomVerticalSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.isLeftAligned,
    required this.title,
    required this.onChanged,
    this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight - 40; // reserve space for title
        final percent = (value - min) / (max - min);
        final fillHeight = height * percent.clamp(0.0, 1.0);
        
        final displayValue = formatValue != null ? formatValue!(value) : "${value.toInt()}";

        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  // delta.dy is negative when moving up
                  final dy = details.localPosition.dy;
                  final newPercent = 1.0 - (dy / height).clamp(0.0, 1.0);
                  final newValue = min + (max - min) * newPercent;
                  onChanged(newValue);
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent, // Capture touches
                  child: Stack(
                    alignment: isLeftAligned ? Alignment.bottomLeft : Alignment.bottomRight,
                    children: [
                      // The slider bar background
                      Positioned(
                        left: isLeftAligned ? 20 : null,
                        right: !isLeftAligned ? 20 : null,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // The fill
                              Container(
                                height: fillHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              // Ticks (mockup)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(10, (index) => Container(
                                  width: 8,
                                  height: 1,
                                  color: Colors.grey.shade400,
                                  margin: const EdgeInsets.only(top: 10),
                                )),
                              )
                            ],
                          ),
                        ),
                      ),
                      // The thumb / value indicator
                      Positioned(
                        bottom: fillHeight - 10, // center it
                        left: isLeftAligned ? 40 : null,
                        right: !isLeftAligned ? 40 : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isLeftAligned) Text(
                              "$displayValue $unit",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            if (!isLeftAligned) const SizedBox(width: 4),
                            // Thumb line
                            Container(
                              width: 12,
                              height: 2,
                              color: Colors.black87,
                            ),
                            if (isLeftAligned) const SizedBox(width: 4),
                            if (isLeftAligned) Text(
                              "$displayValue $unit",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        );
      }
    );
  }
}

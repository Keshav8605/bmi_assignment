import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_routes.dart';
import '../viewmodels/user_viewmodel.dart';

class GenderSelectionView extends StatefulWidget {
  const GenderSelectionView({super.key});

  @override
  State<GenderSelectionView> createState() => _GenderSelectionViewState();
}

class _GenderSelectionViewState extends State<GenderSelectionView> {
  String _selectedGender = 'Female'; // Default to match the UI image

  void _onNext() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    userVM.updateGender(_selectedGender);
    Navigator.pushNamed(context, AppRoutes.userDetails);
  }

  Widget _buildCharacter({required String gender, required String imageAsset}) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 0.95, isSelected ? 1.05 : 0.95, 1.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular background highlight
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.grey.withValues(alpha: 0.1) : Colors.transparent,
              ),
            ),
            // Character Image
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.5,
              child: Image.asset(
                imageAsset,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is missing
                  return Container(
                    height: 150,
                    width: 70,
                    decoration: BoxDecoration(
                      color: gender == 'Female' ? Colors.pink.shade200 : Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(35),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF7F8FA);
    const pinkAccent = Color(0xFFED5D73);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose One',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Characters Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCharacter(gender: 'Female', imageAsset: 'assets/images/female.png'),
                        _buildCharacter(gender: 'Male', imageAsset: 'assets/images/male.png'),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Toggle Pill
                    Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedGender = 'Female'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'Female' ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  border: _selectedGender == 'Female' ? Border.all(color: Colors.grey.shade200) : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Female',
                                    style: TextStyle(
                                      color: _selectedGender == 'Female' ? Colors.black87 : Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedGender = 'Male'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'Male' ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  border: _selectedGender == 'Male' ? Border.all(color: Colors.grey.shade200) : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Male',
                                    style: TextStyle(
                                      color: _selectedGender == 'Male' ? Colors.black87 : Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Next Button
              Center(
                child: InkWell(
                  onTap: _onNext,
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

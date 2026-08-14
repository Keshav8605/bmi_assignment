import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../viewmodels/user_viewmodel.dart';

void showEditProfileDialog(BuildContext context, UserModel user) {
  final nameController = TextEditingController(text: user.name);
  final weightController = TextEditingController(text: user.weight.toString());
  final heightController = TextEditingController(text: user.height.toString());
  String selectedGender = user.gender;

  showDialog(
    context: context,
    builder: (context) {
      final userVM = Provider.of<UserViewModel>(context);
      final isDark = userVM.isDarkMode;
      final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black87;
      final primaryBlue = isDark ? const Color(0xFF6B8AFF) : const Color(0xFF4361EE);
      final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
      final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;
      
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedGender.isNotEmpty ? selectedGender : 'Other',
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          selectedGender = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
                            return;
                          }
                          double? w = double.tryParse(weightController.text);
                          double? h = double.tryParse(heightController.text);
                          
                          if (w == null || w <= 0 || w > 500) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid weight.')));
                            return;
                          }
                          if (h == null || h <= 0 || h > 300) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid height.')));
                            return;
                          }

                          final updatedUser = user.copyWith(
                            name: nameController.text.trim(),
                            height: h,
                            weight: w,
                            gender: selectedGender,
                          );
                          Provider.of<UserViewModel>(context, listen: false).updateCurrentUser(updatedUser);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      );
    }
  );
}

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
      final labelColor = isDark ? Colors.grey.shade400 : Colors.black54;

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
                  _buildTextField(nameController, 'Name', textColor, labelColor, borderColor, inputFillColor),
                  const SizedBox(height: 16),
                  _buildTextField(weightController, 'Weight (kg)', textColor, labelColor, borderColor, inputFillColor, isNumeric: true),
                  const SizedBox(height: 16),
                  _buildTextField(heightController, 'Height (cm)', textColor, labelColor, borderColor, inputFillColor, isNumeric: true),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedGender.isNotEmpty ? selectedGender : 'Other',
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: labelColor),
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
                        child: Text('Cancel', style: TextStyle(color: labelColor, fontWeight: FontWeight.bold)),
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
        },
      );
    },
  );
}

Widget _buildTextField(
  TextEditingController controller,
  String label,
  Color textColor,
  Color labelColor,
  Color borderColor,
  Color fillColor, {
  bool isNumeric = false,
}) {
  return TextField(
    controller: controller,
    keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
      filled: true,
      fillColor: fillColor,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/dialogs.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateControllers();
  }

  void _populateControllers() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    if (userVM.currentUser != null) {
      _weightController.text = userVM.currentUser!.weight.toString();
      _heightController.text = userVM.currentUser!.height.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    double? weight = double.tryParse(_weightController.text);
    double? height = double.tryParse(_heightController.text);

    if (height == null || height <= 0 || height > 300) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid height.')));
      return;
    }

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight must be greater than 0.')));
      return;
    }

    userVM.updateVitals(weight: weight, height: height);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vitals updated successfully')));
  }

  void _showDeleteConfirmation(BuildContext context, UserViewModel userVM) {
    final currentUser = userVM.currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete ${currentUser.name.split(' ').first}'s profile?"),
          content: const Text("This will permanently remove the profile and its history."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                nav.pop();
                final authVM = Provider.of<AuthViewModel>(context, listen: false);
                await authVM.deleteProfile(currentUser.id);

                if (authVM.authService.currentUser == null) {
                  nav.pushReplacementNamed('/login');
                } else if (mounted) {
                  _populateControllers();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProfileDialog(BuildContext context, UserViewModel userVM) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Profile'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Profile Name',
              hintText: 'e.g. Jane Doe',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  userVM.addProfile(nameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userVM, child) {
        final isDark = userVM.isDarkMode;
        final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9);
        final primaryBlue = isDark ? const Color(0xFF6B8AFF) : const Color(0xFF4361EE);
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.black54;
        final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        final dividerColor = isDark ? Colors.grey.shade800 : Colors.black.withValues(alpha: 0.1);

        final currentUser = userVM.currentUser;
        final profiles = userVM.profiles;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(currentUser, primaryBlue, textColor),
                  const SizedBox(height: 24),
                  _buildVitalsSection(primaryBlue, cardColor, textColor, subTextColor, inputFillColor, borderColor, isDark),
                  const SizedBox(height: 32),
                  _buildPreferencesSection(userVM, primaryBlue, cardColor, textColor, subTextColor, isDark),
                  const SizedBox(height: 32),
                  _buildProfilesSection(userVM, profiles, currentUser, primaryBlue, cardColor, textColor, subTextColor, dividerColor, isDark),
                  const SizedBox(height: 48),
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, userVM),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Delete Current Profile', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(dynamic currentUser, Color primaryBlue, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Settings", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
        GestureDetector(
          onTap: () {
            if (currentUser != null) showEditProfileDialog(context, currentUser);
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: primaryBlue.withValues(alpha: 0.1),
            child: Text(
              currentUser?.name.isNotEmpty == true ? currentUser!.name[0].toUpperCase() : 'U',
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsSection(Color primaryBlue, Color cardColor, Color textColor, Color subTextColor, Color inputFillColor, Color borderColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Update Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildInputField(_heightController, 'Height (cm)', Icons.height, primaryBlue, textColor, subTextColor, inputFillColor, borderColor),
              const SizedBox(height: 16),
              _buildInputField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, primaryBlue, textColor, subTextColor, inputFillColor, borderColor),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, Color primaryBlue, Color textColor, Color subTextColor, Color fillColor, Color borderColor) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subTextColor),
        prefixIcon: Icon(icon, color: primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }

  Widget _buildPreferencesSection(UserViewModel userVM, Color primaryBlue, Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("App Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            subtitle: Text("Toggle premium dark aesthetic", style: TextStyle(fontSize: 12, color: subTextColor)),
            value: userVM.isDarkMode,
            activeThumbColor: primaryBlue,
            onChanged: (val) => userVM.toggleTheme(),
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.dark_mode, color: primaryBlue, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilesSection(UserViewModel userVM, List profiles, dynamic currentUser, Color primaryBlue, Color cardColor, Color textColor, Color subTextColor, Color dividerColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Family Profiles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text("Switch between different family members.", style: TextStyle(fontSize: 14, color: subTextColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              ...profiles.map((profile) {
                final isActive = profile.id == currentUser?.id;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isActive ? primaryBlue : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: isActive ? Colors.white : subTextColor, size: 20),
                      ),
                      title: Text(profile.name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: textColor)),
                      trailing: isActive ? Icon(Icons.check_circle, color: primaryBlue) : null,
                      onTap: () {
                        if (!isActive) {
                          userVM.switchProfile(profile.id);
                          _populateControllers();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Switched to ${profile.name}')));
                        }
                      },
                    ),
                    if (profile != profiles.last) Divider(height: 1, indent: 70, color: dividerColor),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(height: 32, color: dividerColor),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddProfileDialog(context, userVM),
                    icon: Icon(Icons.add, color: primaryBlue),
                    label: Text('Add New Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

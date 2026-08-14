import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';

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
    double weight = double.tryParse(_weightController.text) ?? 70.0;
    double height = double.tryParse(_heightController.text) ?? 170.0;
    
    userVM.updateVitals(weight: weight, height: height);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vitals updated successfully')),
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
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userVM, child) {
          final currentUser = userVM.currentUser;
          final profiles = userVM.profiles;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Update Vitals (${currentUser?.name})', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                
                // Update Height
                TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Update Weight
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Changes'),
                ),
                
                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 24),
                
                Text('Multi-User Support', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Switch between family members', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                
                // List dynamic profiles
                ...profiles.map((profile) {
                  final isActive = profile.id == currentUser?.id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isActive ? theme.primaryColor : Colors.grey.shade300,
                      child: Icon(Icons.person, color: isActive ? Colors.white : Colors.grey),
                    ),
                    title: Text(profile.name),
                    trailing: isActive ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      if (!isActive) {
                        userVM.switchProfile(profile.id);
                        _populateControllers(); // update the text fields
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Switched to ${profile.name}')),
                        );
                      }
                    },
                  );
                }),
                
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showAddProfileDialog(context, userVM),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Profile'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

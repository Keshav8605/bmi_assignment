import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_routes.dart';
import '../viewmodels/user_viewmodel.dart';
import 'widgets/premium_loader.dart';

class UserDetailsView extends StatefulWidget {
  const UserDetailsView({super.key});

  @override
  State<UserDetailsView> createState() => _UserDetailsViewState();
}

class _UserDetailsViewState extends State<UserDetailsView> {
  String _selectedGender = 'Male';
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with mock data if available
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    if (userVM.currentUser != null) {
      _weightController.text = userVM.currentUser!.weight.toString();
      _heightController.text = userVM.currentUser!.height.toString();
      _selectedGender = userVM.currentUser!.gender;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _saveDetails() async {
    setState(() => _isLoading = true);
    
    // Simulate premium calculation delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userVM = Provider.of<UserViewModel>(context, listen: false);
    double weight = double.tryParse(_weightController.text) ?? 70.0;
    double height = double.tryParse(_heightController.text) ?? 170.0;
    
    // convert back to metric if needed
    if (!userVM.isKg) {
      weight = weight * 0.453592; // lbs to kg
    }
    if (!userVM.isCm) {
      height = height * 30.48; // ft to cm (approx for simple ft)
    }

    userVM.updateVitals(weight: weight, height: height);
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userVM = Provider.of<UserViewModel>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Body Data', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: PremiumLoader(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about yourself',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 32),
              
              // Gender Selection
              Text('Gender', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Male', label: Text('Male')),
                  ButtonSegment(value: 'Female', label: Text('Female')),
                  ButtonSegment(value: 'Other', label: Text('Other')),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedGender = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Date of Birth (Placeholder for date picker)
              Text('Date of Birth', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Date', style: theme.textTheme.bodyLarge),
                      const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Height
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Height', style: theme.textTheme.titleLarge),
                  // Toggle CM / FT
                  Row(
                    children: [
                      Text('FT', style: TextStyle(color: userVM.isCm ? Colors.grey : theme.primaryColor, fontWeight: FontWeight.bold)),
                      Switch(
                        value: userVM.isCm,
                        onChanged: userVM.toggleHeightUnit,
                        activeTrackColor: theme.primaryColor,
                        activeThumbColor: Colors.white,
                      ),
                      Text('CM', style: TextStyle(color: userVM.isCm ? theme.primaryColor : Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: userVM.isCm ? 'Height (cm)' : 'Height (ft)',
                  suffixText: userVM.isCm ? 'cm' : 'ft',
                ),
              ),
              const SizedBox(height: 24),

              // Weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight', style: theme.textTheme.titleLarge),
                  // Toggle KG / LBS
                  Row(
                    children: [
                      Text('LBS', style: TextStyle(color: userVM.isKg ? Colors.grey : theme.primaryColor, fontWeight: FontWeight.bold)),
                      Switch(
                        value: userVM.isKg,
                        onChanged: userVM.toggleWeightUnit,
                        activeTrackColor: theme.primaryColor,
                        activeThumbColor: Colors.white,
                      ),
                      Text('KG', style: TextStyle(color: userVM.isKg ? theme.primaryColor : Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: userVM.isKg ? 'Weight (kg)' : 'Weight (lbs)',
                  suffixText: userVM.isKg ? 'kg' : 'lbs',
                ),
              ),
              const SizedBox(height: 48),

              // Continue Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDetails,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserViewModel extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _currentUser;
  
  bool _isKg = true;
  bool _isCm = true;

  bool get isKg => _isKg;
  bool get isCm => _isCm;
  UserModel? get currentUser => _currentUser;
  List<UserModel> get profiles => _authService.profiles;

  UserViewModel(this._authService) {
    _currentUser = _authService.currentUser;
  }

  void loadUser() {
    _currentUser = _authService.currentUser;
    notifyListeners();
  }
  
  void switchProfile(String id) {
    _authService.switchProfile(id);
    loadUser();
  }
  
  void addProfile(String name) {
    final newProfile = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: '',
      height: 170.0,
      weight: 65.0,
      gender: 'Other',
    );
    _authService.addProfile(newProfile);
    notifyListeners();
  }

  void toggleWeightUnit(bool isKg) {
    _isKg = isKg;
    notifyListeners();
  }

  void toggleHeightUnit(bool isCm) {
    _isCm = isCm;
    notifyListeners();
  }

  void updateVitals({required double weight, required double height}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(weight: weight, height: height);
      _authService.updateCurrentUser(_currentUser!);
      notifyListeners();
    }
  }

  double get bmiValue {
    if (_currentUser == null) return 0.0;
    
    // Always calculate using metric standard for internal logic if stored as metric.
    double heightInMeters = _currentUser!.height / 100;
    if (heightInMeters <= 0) return 0.0;
    
    return _currentUser!.weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    final bmi = bmiValue;
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi <= 24.9) return 'Normal Weight';
    if (bmi >= 25 && bmi <= 29.9) return 'Overweight';
    if (bmi >= 30) return 'Obese';
    return 'Unknown';
  }
}

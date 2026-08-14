import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel(this._authService);

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _authService.login(email, password);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _authService.register(name, email, password);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void logout() {
    _authService.logout();
    notifyListeners();
  }

  Future<void> deleteProfile(String id) async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.deleteProfile(id);
    
    _isLoading = false;
    notifyListeners();
  }

  AuthService get authService => _authService;
}

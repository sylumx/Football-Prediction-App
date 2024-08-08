import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  String _errorMessage = '';

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<bool> login(String email, String password) async {
    debugPrint('AuthProvider: Attempting login');
    final result = await _authService.login(email, password);
    debugPrint('AuthProvider: Login result: $result');
    if (result['success']) {
      _isLoggedIn = true;
      _userData = result['data'];
      _errorMessage = '';
    } else {
      _isLoggedIn = false;
      _userData = null;
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  Future<bool> register(String name, String email, String password,
      String phoneNumber, String countryCode, String countryName) async {
    final result = await _authService.register(
        name, email, password, phoneNumber, countryCode, countryName);
    if (result['success']) {
      _isLoggedIn = true;
      _userData = result['data'];
      _errorMessage = '';
    } else {
      _isLoggedIn = false;
      _userData = null;
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  Future<void> _checkLoginStatus() async {
    final result = await _authService.getUserInfo();
    if (result['success']) {
      _isLoggedIn = true;
      _userData = result['data'];
    } else {
      _isLoggedIn = false;
      _userData = null;
    }
    notifyListeners();
  }

  Future<bool> logout() async {
    final result = await _authService.logout();
    if (result['success']) {
      _isLoggedIn = false;
      _userData = null;
      _errorMessage = '';
    } else {
      _errorMessage = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  Future<void> refreshUserData() async {
    await _checkLoginStatus();
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'timezone_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  String _errorMessage = '';

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String get errorMessage => _errorMessage;

  bool get isSubscriptionActive {
    return _userData?['subscription_status'] == 'active';
  }

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    try {
      final result = await _authService.getUserInfo();
      if (result['success']) {
        _isLoggedIn = true;
        _userData = result['data'];
        if (_userData != null && _userData!['timezone'] != null) {
          Provider.of<TimezoneProvider>(context, listen: false)
              .setUserTimeZone(_userData!['timezone']);
        }
      } else {
        _isLoggedIn = false;
        _userData = null;
        _errorMessage = result['message'] ?? 'Failed to get user info';
      }
    } catch (e) {
      _isLoggedIn = false;
      _userData = null;
      _errorMessage = 'An error occurred: $e';
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);
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

  Future<void> checkSubscriptionStatus() async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo['success']) {
        _userData = userInfo['data'];
        notifyListeners();
      } else {
        _errorMessage = 'Failed to fetch user information';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'An error occurred while checking subscription status';
      notifyListeners();
    }
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

  Future<void> refreshUserData(BuildContext context) async {
    await checkLoginStatus(context);
  }
}

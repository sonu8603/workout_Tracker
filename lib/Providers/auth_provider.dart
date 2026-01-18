import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get username => _userData?['username'];
  String? get email => _userData?['email'];
  String? get phone => _userData?['phone'];

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _isLoggedIn = ApiService.isLoggedIn();
    _userData = ApiService.getUserData();

    if (kDebugMode) {
      debugPrint('🔐 Auth Status: ${_isLoggedIn ? "Logged In" : "Logged Out"}');
      if (_userData != null) {
        debugPrint('👤 User: ${_userData!['username']} (${_userData!['email']})');
      }
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.login(email: email, password: password);

    _isLoading = false;

    if (result['success']) {
      _isLoggedIn = true;
      _userData = result['user'];
      _error = null;

      if (kDebugMode) {
        debugPrint('✅ Login successful: ${_userData!['username']}');
      }

      notifyListeners();
      return true;
    } else {
      _error = result['message'];

      if (kDebugMode) {
        debugPrint('❌ Login failed: $_error');
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.register(
      username: username,
      email: email,
      password: password,
      phone: phone,
    );

    _isLoading = false;

    if (result['success']) {
      _isLoggedIn = true;
      _userData = result['user'];
      _error = null;

      if (kDebugMode) {
        debugPrint('✅ Registration successful: ${_userData!['username']}');
      }

      notifyListeners();
      return true;
    } else {
      _error = result['message'];

      if (kDebugMode) {
        debugPrint('❌ Registration failed: $_error');
      }

      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isLoggedIn = false;
    _userData = null;
    _error = null;

    if (kDebugMode) {
      debugPrint('🚪 User logged out');
    }

    notifyListeners();
  }

  Future<bool> updateProfile({
    required String username,
    required String email,
    required String phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.updateProfile(
      username: username,
      email: email,
      phone: phone,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;

    if (result['success']) {
      _userData = result['user'];
      _error = null;

      if (kDebugMode) {
        debugPrint('✅ Profile updated: ${_userData!['username']}');
      }

      notifyListeners();
      return true;
    } else {
      _error = result['message'];

      if (kDebugMode) {
        debugPrint('❌ Profile update failed: $_error');
      }

      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    final result = await ApiService.getProfile();

    if (result['success']) {
      _userData = result['profile'];
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
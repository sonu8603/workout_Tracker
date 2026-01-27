import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_service.dart';
import '../main.dart'; // for HiveConfig



class AuthProvider extends ChangeNotifier {
  final Box _authBox = Hive.box(HiveConfig.authBox);

  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  String? _token;
  String? _error;

  // ================= GETTERS =================

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get userData => _user;
  String? get token => _token;
  String? get error => _error;

  String? get username => _user?['username'];
  String? get email => _user?['email'];
  String? get phone => _user?['phone'];

  // ================= INIT =================

  AuthProvider() {
    _restoreAuthState();
  }

  // ================= CORE HELPERS =================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _restoreAuthState() async {
    try {
      final storedToken = _authBox.get('token');
      final storedUser = _authBox.get('user');

      if (storedToken != null && storedUser != null) {
        _token = storedToken;
        _user = Map<String, dynamic>.from(storedUser);
        _isLoggedIn = true;

        if (kDebugMode) {
          debugPrint('🔐 Restored login: ${_user!['username']}');
        }
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to restore auth state: $e');
      }
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistAuthState(String token, Map<String, dynamic> user) async {
    _token = token;
    _user = user;
    _isLoggedIn = true;

    await _authBox.put('token', token);
    await _authBox.put('user', user);

    notifyListeners();
  }

  Future<void> _clearAuthState() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;
    _error = null;

    await _authBox.delete('token');
    await _authBox.delete('user');

    notifyListeners();
  }

  Future<bool> _authWrapper(Future<Map<String, dynamic>> Function() action) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await action();

      if (result['success'] == true) {
        return true;
      } else {
        _error = result['message'] ?? 'Something went wrong';
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      if (kDebugMode) debugPrint('Auth error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================= PUBLIC API =================

  /// Login with email or username
  Future<bool> login(String identifier, String password) async {
    return _authWrapper(() async {
      final result = await ApiService.login(
        identifier: identifier,
        password: password,
      );

      if (result['success'] == true) {
        await _persistAuthState(result['token'], result['user']);
      }

      return result;
    });
  }

  /// Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    return _authWrapper(() async {
      final result = await ApiService.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      if (result['success'] == true) {
        await _persistAuthState(result['token'], result['user']);
      }

      return result;
    });
  }

  /// Logout
  Future<void> logout() async {
    await ApiService.logout();
    await _clearAuthState();

    if (kDebugMode) {
      debugPrint('🚪 User logged out');
    }
  }

  /// Update profile (username/email/phone/password)
  Future<bool> updateProfile({
    required String username,
    required String email,
    required String phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    return _authWrapper(() async {
      final result = await ApiService.updateProfile(
        username: username,
        email: email,
        phone: phone,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        _user = result['user'];
        await _authBox.put('user', _user);
        notifyListeners();
      }

      return result;
    });
  }

  /// Refresh profile from backend
  Future<void> refreshProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (result['success'] == true) {
        _user = result['profile'];
        await _authBox.put('user', _user);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Refresh profile failed: $e');
    }
  }

  // getuserimage




  void clearError() {
    _error = null;
    notifyListeners();
  }
}
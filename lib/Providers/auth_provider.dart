import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_service.dart';
import '../main.dart';

/// 🔥 COMPLETE FIX: Ensures UI updates immediately after registration
class AuthProvider extends ChangeNotifier {
  final Box _authBox = Hive.box(HiveConfig.authBox);

  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  String? _token;
  String? _error;

  // Lock-related properties
  bool _isLocked = false;
  int _remainingSeconds = 0;
  DateTime? _lockUntil;
  Timer? _lockTimer;

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

  bool get isLocked => _isLocked;
  int get remainingSeconds => _remainingSeconds;

  String get remainingTime {
    if (_remainingSeconds <= 0) return '';

    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;

    if (minutes > 0) {
      return '$minutes min ${seconds.toString().padLeft(2, '0')} sec';
    } else {
      return '$seconds sec';
    }
  }

  // ================= INIT =================

  AuthProvider() {
    _restoreAuthState();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
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
      // Read from ApiService's keys
      final storedToken = _authBox.get('auth_token');
      final storedUser = _authBox.get('user_data');

      if (kDebugMode) {
        debugPrint('🔷 Restoring auth state...');
        debugPrint('   Token exists: ${storedToken != null}');
        debugPrint('   User exists: ${storedUser != null}');
      }

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

      // Restore lock info
      final lockUntilMs = _authBox.get('lockUntil');
      if (lockUntilMs != null) {
        _lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilMs);
        _updateLockStatus();
        if (_isLocked) {
          _startLockTimer();
        }
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

  // 🔥 NEW: Force reload from Hive storage
  Future<void> _reloadFromStorage() async {
    try {
      final storedToken = _authBox.get('auth_token');
      final storedUser = _authBox.get('user_data');

      if (kDebugMode) {
        debugPrint('🔄 Reloading from storage...');
        debugPrint('   Token exists: ${storedToken != null}');
        debugPrint('   User exists: ${storedUser != null}');
        if (storedUser != null) {
          debugPrint('   User data: $storedUser');
        }
      }

      if (storedToken != null && storedUser != null) {
        _token = storedToken;
        _user = Map<String, dynamic>.from(storedUser);
        _isLoggedIn = true;

        if (kDebugMode) {
          debugPrint('✅ Reloaded: ${_user!['username']}');
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to reload from storage: $e');
      }
    }
  }

  Future<void> _clearAuthState() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;
    _error = null;

    await _authBox.delete('auth_token');
    await _authBox.delete('user_data');

    notifyListeners();
  }

  void _updateLockStatus() {
    if (_lockUntil == null) {
      _isLocked = false;
      _remainingSeconds = 0;
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(_lockUntil!) || now.isAtSameMomentAs(_lockUntil!)) {
      if (kDebugMode) debugPrint('🔓 Lock expired');
      _isLocked = false;
      _remainingSeconds = 0;
      _lockUntil = null;
      _lockTimer?.cancel();
      _lockTimer = null;
      _clearLockFromStorage();
      notifyListeners();
    } else {
      _isLocked = true;
      _remainingSeconds = _lockUntil!.difference(now).inSeconds;
      if (kDebugMode) debugPrint('🔒 Lock remaining: $_remainingSeconds seconds');
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();

    if (_lockUntil == null) return;

    if (kDebugMode) debugPrint('⏰ Starting lock timer');

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockUntil == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();

      if (now.isAfter(_lockUntil!) || now.isAtSameMomentAs(_lockUntil!)) {
        if (kDebugMode) debugPrint('🔓 Timer: Lock expired');
        _isLocked = false;
        _remainingSeconds = 0;
        _lockUntil = null;
        _clearLockFromStorage();
        timer.cancel();
        _lockTimer = null;
        notifyListeners();
      } else {
        _remainingSeconds = _lockUntil!.difference(now).inSeconds;

        if (kDebugMode && _remainingSeconds % 10 == 0) {
          debugPrint('⏰ Timer update: $_remainingSeconds seconds remaining');
        }

        notifyListeners();
      }
    });
  }

  Future<void> _saveLockToStorage() async {
    if (_lockUntil != null) {
      await _authBox.put('lockUntil', _lockUntil!.millisecondsSinceEpoch);
      if (kDebugMode) debugPrint('💾 Saved lock until: $_lockUntil');
    }
  }

  Future<void> _clearLockFromStorage() async {
    await _authBox.delete('lockUntil');
    if (kDebugMode) debugPrint('🗑️ Cleared lock from storage');
  }

  // ================= PUBLIC API =================

  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.login(
        identifier: identifier,
        password: password,
      );

      if (kDebugMode) debugPrint('📥 Login result: $result');

      if (result['code'] == 'ACCOUNT_LOCKED' || (result['success'] == false && result['lockUntil'] != null)) {
        _isLocked = true;
        _remainingSeconds = result['remainingSeconds'] ?? 0;

        if (result['lockUntil'] != null) {
          _lockUntil = DateTime.fromMillisecondsSinceEpoch(result['lockUntil']);
          await _saveLockToStorage();
          _startLockTimer();
          if (kDebugMode) {
            debugPrint('🔒 Account locked until: $_lockUntil');
            debugPrint('🔒 Remaining: $_remainingSeconds seconds');
          }
        }

        _error = result['message'] ?? 'Account is locked';
        _setLoading(false);
        return false;
      }

      if (result['success'] == true) {
        _isLocked = false;
        _remainingSeconds = 0;
        _lockUntil = null;
        _lockTimer?.cancel();
        _lockTimer = null;
        await _clearLockFromStorage();

        // 🔥 Reload from Hive after ApiService saved
        await _reloadFromStorage();

        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      if (kDebugMode) debugPrint('Login error: $e');
      _setLoading(false);
      return false;
    }
  }

  /// 🔥 FIXED: Register with immediate UI update
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (kDebugMode) {
      debugPrint('🔷 ==========================================');
      debugPrint('🔷 REGISTER called');
      debugPrint('🔷 Username: $username');
      debugPrint('🔷 Email: $email');
      debugPrint('🔷 ==========================================');
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      if (kDebugMode) {
        debugPrint('📥 Register API result: $result');
      }

      if (result['success'] == true) {
        if (kDebugMode) {
          debugPrint('✅ Registration successful, reloading state...');
        }

        // 🔥 CRITICAL FIX: Wait a tiny bit for ApiService to finish saving
        await Future.delayed(const Duration(milliseconds: 50));

        // 🔥 CRITICAL FIX: Force reload from Hive
        await _reloadFromStorage();

        // 🔥 CRITICAL FIX: Double-check the state is set
        if (kDebugMode) {
          debugPrint('🔷 After reload:');
          debugPrint('   _isLoggedIn: $_isLoggedIn');
          debugPrint('   _user: $_user');
          debugPrint('   username: $username');
        }

        _setLoading(false);

        // 🔥 CRITICAL FIX: One more notify to be absolutely sure
        notifyListeners();

        if (kDebugMode) {
          debugPrint('✅ ==========================================');
          debugPrint('✅ REGISTRATION COMPLETE');
          debugPrint('✅ isLoggedIn: $_isLoggedIn');
          debugPrint('✅ username: ${this.username}');
          debugPrint('✅ ==========================================');
        }

        return true;
      } else {
        _error = result['message'] ?? 'Registration failed';
        if (kDebugMode) debugPrint('❌ Registration failed: $_error');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      if (kDebugMode) debugPrint('❌ Register error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();

    _isLocked = false;
    _remainingSeconds = 0;
    _lockUntil = null;
    _lockTimer?.cancel();
    _lockTimer = null;
    await _clearLockFromStorage();

    await _clearAuthState();

    if (kDebugMode) {
      debugPrint('🚪 User logged out');
    }
  }

  Future<bool> updateProfile({
    required String username,
    required String email,
    required String phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.updateProfile(
        username: username,
        email: email,
        phone: phone,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        // Reload from Hive after ApiService updates
        await _reloadFromStorage();

        if (kDebugMode) {
          debugPrint('✅ Profile updated successfully');
        }

        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update profile';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      if (kDebugMode) debugPrint('Update profile error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final result = await ApiService.getProfile();

      if (result['success'] == true) {
        // Reload from Hive after ApiService updates
        await _reloadFromStorage();

        if (kDebugMode) {
          debugPrint('✅ Profile refreshed');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Refresh profile failed: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
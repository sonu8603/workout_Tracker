import 'dart:async';
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

  // Lock-related properties
  bool _isLocked = false;
  int _remainingSeconds = 0;
  DateTime? _lockUntil;
  Timer? _lockTimer;
  bool _isDisposed = false; // 🆕 Track disposal

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

  // Lock getters
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
    _isDisposed = true;
    _lockTimer?.cancel();
    _lockTimer = null;
    super.dispose();
  }

  // ================= CORE HELPERS =================

  void _setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
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

      // Restore lock info
      final lockUntilMs = _authBox.get('lockUntil');
      if (lockUntilMs != null && lockUntilMs is int) {
        try {
          _lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilMs);
          _updateLockStatus();
          if (_isLocked) {
            _startLockTimer();
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Invalid lock timestamp: $e');
          }
          await _clearLockFromStorage();
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

  Future<void> _persistAuthState(String token, Map<String, dynamic> user) async {
    try {
      _token = token;
      _user = user;
      _isLoggedIn = true;

      await _authBox.put('token', token);
      await _authBox.put('user', user);

      if (kDebugMode) {
        debugPrint('✅ Auth state persisted');
        debugPrint('   Username: ${user['username']}');
        debugPrint('   Email: ${user['email']}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to persist auth state: $e');
      }
    }
  }

  Future<void> _clearAuthState() async {
    try {
      _token = null;
      _user = null;
      _isLoggedIn = false;
      _error = null;

      await _authBox.delete('token');
      await _authBox.delete('user');

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear auth state: $e');
      }
    }
  }

  // Update lock status
  void _updateLockStatus() {
    if (_lockUntil == null) {
      _isLocked = false;
      _remainingSeconds = 0;
      return;
    }

    final now = DateTime.now();

    if (_lockUntil!.isBefore(now)) {
      // Lock expired
      if (kDebugMode) debugPrint('🔓 Lock expired');
      _isLocked = false;
      _remainingSeconds = 0;
      _lockUntil = null;
      _lockTimer?.cancel();
      _lockTimer = null;
      _clearLockFromStorage();
      notifyListeners();
    } else {
      // Still locked
      _isLocked = true;
      _remainingSeconds = _lockUntil!.difference(now).inSeconds;

      if (kDebugMode) debugPrint('🔒 Lock remaining: $_remainingSeconds seconds');
    }
  }

  // Start lock countdown timer
  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;

    if (_lockUntil == null || _isDisposed) return;

    if (kDebugMode) debugPrint('⏰ Starting lock timer');

    final now = DateTime.now();
    _remainingSeconds = _lockUntil!.difference(now).inSeconds;

    if (_remainingSeconds <= 0) {
      _isLocked = false;
      _remainingSeconds = 0;
      _lockUntil = null;
      _clearLockFromStorage();
      notifyListeners();
      return;
    }

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || _lockUntil == null) {
        timer.cancel();
        _lockTimer = null;
        return;
      }

      final now = DateTime.now();

      if (now.isAfter(_lockUntil!)) {
        if (kDebugMode) debugPrint('🔓 Timer: Lock expired');
        _isLocked = false;
        _remainingSeconds = 0;
        _lockUntil = null;
        _clearLockFromStorage();
        timer.cancel();
        _lockTimer = null;
        notifyListeners();
      } else {
        final previousSeconds = _remainingSeconds;
        _remainingSeconds = _lockUntil!.difference(now).inSeconds;

        if (previousSeconds != _remainingSeconds) {
          if (kDebugMode && _remainingSeconds % 10 == 0) {
            debugPrint('⏰ Timer: $_remainingSeconds seconds remaining');
          }
          notifyListeners();
        }
      }
    });
  }

  Future<void> _saveLockToStorage() async {
    try {
      if (_lockUntil != null) {
        await _authBox.put('lockUntil', _lockUntil!.millisecondsSinceEpoch);
        if (kDebugMode) debugPrint('💾 Saved lock until: $_lockUntil');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to save lock: $e');
    }
  }

  Future<void> _clearLockFromStorage() async {
    try {
      await _authBox.delete('lockUntil');
      if (kDebugMode) debugPrint('🗑️ Cleared lock from storage');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to clear lock: $e');
    }
  }

  // ================= PUBLIC API =================

  /// Login with email or username
  Future<bool> login(String identifier, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.login(
        identifier: identifier,
        password: password,
      );

      if (kDebugMode) debugPrint('📥 Login result: $result');

      // Handle account locked
      if (result['code'] == 'ACCOUNT_LOCKED' ||
          (result['success'] == false && result['lockUntil'] != null)) {
        _isLocked = true;

        final remainingSecondsValue = result['remainingSeconds'];
        _remainingSeconds = (remainingSecondsValue is int) ? remainingSecondsValue : 0;

        if (result['lockUntil'] != null) {
          try {
            final lockUntilValue = result['lockUntil'];
            if (lockUntilValue is int) {
              _lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilValue);
              await _saveLockToStorage();
              _startLockTimer();

              if (kDebugMode) {
                debugPrint('🔒 Account locked until: $_lockUntil');
                debugPrint('🔒 Remaining: $_remainingSeconds seconds');
              }
            }
          } catch (e) {
            if (kDebugMode) debugPrint('❌ Lock time parsing error: $e');
          }
        }

        _error = result['message'] ?? 'Account is locked';
        _setLoading(false);
        return false;
      }

      if (result['success'] == true) {
        // Clear lock info on successful login
        _isLocked = false;
        _remainingSeconds = 0;
        _lockUntil = null;
        _lockTimer?.cancel();
        _lockTimer = null;
        await _clearLockFromStorage();

        await _persistAuthState(result['token'], result['user']);
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

  /// 🔥 FIXED: Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      if (kDebugMode) debugPrint('📥 Register result: $result');

      if (result['success'] == true) {
        // ✅ FIX: Directly persist auth state like login does
        await _persistAuthState(result['token'], result['user']);

        if (kDebugMode) {
          debugPrint('✅ Registration successful');
          debugPrint('   Username: ${result['user']['username']}');
          debugPrint('   Email: ${result['user']['email']}');
        }

        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      if (kDebugMode) debugPrint('Register error: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await ApiService.logout();

    // Clear lock info on logout
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

  /// Update profile
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
        _user = result['user'];
        await _authBox.put('user', _user);

        if (kDebugMode) {
          debugPrint('✅ Profile updated successfully');
          debugPrint('   New username: ${_user!['username']}');
          debugPrint('   New email: ${_user!['email']}');
          debugPrint('   New phone: ${_user!['phone']}');
        }

        notifyListeners();
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

  /// Refresh profile from backend
  Future<void> refreshProfile() async {
    try {
      final result = await ApiService.getProfile();

      if (result['success'] == true) {
        final userData = {
          'username': result['username'],
          'email': result['email'],
          'phone': result['phone'],
          'profileImage': result['profileImage'],
          'id': result['id'],
          'role': result['role'],
          'isActive': result['isActive'],
          'createdAt': result['createdAt'],
        };

        _user = userData;
        await _authBox.put('user', userData);

        if (kDebugMode) {
          debugPrint('✅ Profile refreshed');
          debugPrint('   Username: ${_user!['username']}');
        }

        notifyListeners();
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
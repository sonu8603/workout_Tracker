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

  // 🆕 Lock-related properties
  bool _isLocked = false;
  int _remainingSeconds = 0;
  DateTime? _lockUntil;
  Timer? _lockTimer; // 🔥 Timer instance

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

  // 🆕 Lock getters
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
    _lockTimer?.cancel(); // 🔥 Cancel timer on dispose
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

      // 🆕 Restore lock info
      final lockUntilMs = _authBox.get('lockUntil');
      if (lockUntilMs != null) {
        _lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilMs);
        _updateLockStatus();
        if (_isLocked) {
          _startLockTimer(); // 🔥 Restart timer if still locked
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

  // 🔥 FIXED: Update lock status
  void _updateLockStatus() {
    if (_lockUntil == null) {
      _isLocked = false;
      _remainingSeconds = 0;
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(_lockUntil!) || now.isAtSameMomentAs(_lockUntil!)) {
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
      // Still locked - calculate remaining time
      _isLocked = true;
      _remainingSeconds = _lockUntil!.difference(now).inSeconds;

      if (kDebugMode) debugPrint('🔒 Lock remaining: $_remainingSeconds seconds');

      // Don't call notifyListeners here, let the timer handle it
    }
  }

  // 🔥 FIXED: Start lock countdown timer
  void _startLockTimer() {
    // Cancel existing timer if any
    _lockTimer?.cancel();

    if (_lockUntil == null) return;

    if (kDebugMode) debugPrint('⏰ Starting lock timer');

    // 🔥 Use periodic timer to update every second
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockUntil == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();

      if (now.isAfter(_lockUntil!) || now.isAtSameMomentAs(_lockUntil!)) {
        // Lock expired
        if (kDebugMode) debugPrint('🔓 Timer: Lock expired');
        _isLocked = false;
        _remainingSeconds = 0;
        _lockUntil = null;
        _clearLockFromStorage();
        timer.cancel();
        _lockTimer = null;
        notifyListeners(); // 🔥 Notify when lock expires
      } else {
        // Update remaining time
        _remainingSeconds = _lockUntil!.difference(now).inSeconds;

        if (kDebugMode && _remainingSeconds % 10 == 0) {
          debugPrint('⏰ Timer update: $_remainingSeconds seconds remaining');
        }

        notifyListeners(); // 🔥 Notify every second to update UI
      }
    });
  }

  // 🆕 Save lock info to storage
  Future<void> _saveLockToStorage() async {
    if (_lockUntil != null) {
      await _authBox.put('lockUntil', _lockUntil!.millisecondsSinceEpoch);
      if (kDebugMode) debugPrint('💾 Saved lock until: $_lockUntil');
    }
  }

  // 🆕 Clear lock info from storage
  Future<void> _clearLockFromStorage() async {
    await _authBox.delete('lockUntil');
    if (kDebugMode) debugPrint('🗑️ Cleared lock from storage');
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
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.login(
        identifier: identifier,
        password: password,
      );

      if (kDebugMode) debugPrint('📥 Login result: $result');

      // 🔥 Handle account locked
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
        // 🔥 Clear lock info on successful login
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

    // 🔥 Clear lock info on logout
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_service.dart';
import '../main.dart';

/// AuthProvider - ONLY manages authentication
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
  String? get userId => _user?['id']; // 🔥 NEW: Provide userId to other providers

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
          debugPrint('🔐 Restored login: ${_user!['username']} (ID: ${_user!['id']})');
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

  Future<void> _reloadFromStorage() async {
    try {
      final storedToken = _authBox.get('auth_token');
      final storedUser = _authBox.get('user_data');

      if (kDebugMode) {
        debugPrint('🔄 Reloading from storage...');
        debugPrint('   Token exists: ${storedToken != null}');
        debugPrint('   User exists: ${storedUser != null}');
      }

      if (storedToken != null && storedUser != null) {
        _token = storedToken;
        _user = Map<String, dynamic>.from(storedUser);
        _isLoggedIn = true;

        if (kDebugMode) {
          debugPrint('✅ Reloaded: ${_user!['username']} (ID: ${_user!['id']})');
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

  // 🔥 CHANGED: Delete user-specific boxes from disk
  Future<void> _clearAllUserData() async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Deleting all user data...');
      }

      // Get user ID before clearing auth
      final uid = _user?['id'];

      // Reset memory variables
      _token = null;
      _user = null;
      _isLoggedIn = false;
      _error = null;

      // Clear auth box
      await _authBox.delete('auth_token');
      await _authBox.delete('user_data');

      // 🔥 NEW: Delete user-specific boxes from disk
      if (uid != null) {
        final boxNames = [
          HiveConfig.workoutDaysBox(uid),
          HiveConfig.extraExercisesBox(uid),
          HiveConfig.settingsBox(uid),
          HiveConfig.workoutLogsBox(uid),
          HiveConfig.metaBox(uid),
        ];

        for (String boxName in boxNames) {
          try {
            // Close if open
            if (Hive.isBoxOpen(boxName)) {
              await Hive.box(boxName).close();
            }

            // Delete from disk
            await Hive.deleteBoxFromDisk(boxName);

            if (kDebugMode) {
              debugPrint('   ✅ Deleted: $boxName');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('   ⚠️ Error deleting $boxName: $e');
            }
          }
        }

        if (kDebugMode) {
          debugPrint('🔥 All user boxes deleted from device');
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting user data: $e');
      }
      notifyListeners();
    }
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

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (kDebugMode) {
      debugPrint('🔷 REGISTER called');
      debugPrint('   Username: $username');
      debugPrint('   Email: $email');
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

        await Future.delayed(const Duration(milliseconds: 50));
        await _reloadFromStorage();

        if (kDebugMode) {
          debugPrint('✅ REGISTRATION COMPLETE');
          debugPrint('   isLoggedIn: $_isLoggedIn');
          debugPrint('   username: $username');
          debugPrint('   userId: ${_user!['id']}');
        }

        _setLoading(false);
        notifyListeners();
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

  // Logout - ONLY clears auth (ExerciseProvider will close its own boxes)
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
      debugPrint('🚪 User logged out (auth cleared)');
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
        await _reloadFromStorage();

        if (kDebugMode) {
          debugPrint('✅ Profile refreshed');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Refresh profile failed: $e');
    }
  }

  // Delete Account - Permanently remove all data
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (kDebugMode) {
        debugPrint('🗑️ Step 1: Calling backend to delete account...');
      }

      final result = await ApiService.deleteAccount(password: password);

      if (result['success'] == true) {
        if (kDebugMode) {
          debugPrint('✅ Step 2: Backend deleted account');
          debugPrint('🗑️ Step 3: Deleting local data...');
        }

        // Delete all user data
        await _clearAllUserData();

        if (kDebugMode) {
          debugPrint('✅ Step 4: Account deletion complete');
        }

        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Failed to delete account';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      if (kDebugMode) debugPrint('❌ Delete account error: $e');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../config/apiconfig.dart';

class ApiService {
  static const String authBoxName = 'auth_data';

  static Box get _authBox => Hive.box(authBoxName);

  static Future<void> saveToken(String token) async {
    await _authBox.put('auth_token', token);
    if (kDebugMode) debugPrint('✅ Token saved');
  }

  static String? getToken() {
    return _authBox.get('auth_token');
  }

  static Future<void> removeToken() async {
    await _authBox.delete('auth_token');
    if (kDebugMode) debugPrint('🔓 Token removed');
  }

  // ============== USER DATA MANAGEMENT ==============

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _authBox.put('user_data', userData);
    if (kDebugMode) debugPrint('✅ User data saved');
  }

  static Map<String, dynamic>? getUserData() {
    final data = _authBox.get('user_data');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static bool isLoggedIn() {
    return getToken() != null;
  }

  // ============== AUTHENTICATION APIs ==============

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Registering: $username, $email');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) debugPrint('📥 Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        await saveToken(data['token']);
        await saveUserData(data['user']);
        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } on TimeoutException {
      if (kDebugMode) debugPrint('⏱️ Request timeout');
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } on http.ClientException {
      if (kDebugMode) debugPrint('🌐 Network error - no connection');
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // 🔥 PRODUCTION-READY LOGIN METHOD
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Logging in: $identifier');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('📥 Status: ${response.statusCode}');
        debugPrint('📥 Response: ${response.body}');
      }

      final data = json.decode(response.body);

      // 🔥 PRODUCTION: Handle 423 Locked OR 429 Rate Limited
      if (response.statusCode == 423 || response.statusCode == 429) {
        if (data['lockUntil'] == null || data['remainingSeconds'] == null) {
          return {
            'success': false,
            'code': 'ACCOUNT_LOCKED',
            'message': data['message'] ?? 'Too many login attempts. Please try again later.',
          };
        }

        final int lockUntil = data['lockUntil'];
        final int remainingSeconds = data['remainingSeconds'];

        if (kDebugMode) {
          debugPrint('🔒 Using server lock info:');
          debugPrint('   - Until: ${DateTime.fromMillisecondsSinceEpoch(lockUntil)}');
          debugPrint('   - Remaining: $remainingSeconds sec');
        }

        return {
          'success': false,
          'code': 'ACCOUNT_LOCKED',
          'message': data['message'],
          'lockUntil': lockUntil,
          'remainingSeconds': remainingSeconds,
          'remainingMinutes': data['remainingMinutes'] ?? (remainingSeconds / 60).ceil(),
        };
      }


      // Handle successful login
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        await saveUserData(data['user']);
        if (kDebugMode) debugPrint('✅ Login successful');

        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      }

      // Handle other errors (401, 400, etc.)
      if (kDebugMode) {
        debugPrint('❌ Login failed: ${data['message']}');
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
        'code': data['code'],
        'attemptsLeft': data['attemptsLeft'],
      };

    } on TimeoutException {
      if (kDebugMode) debugPrint('⏱️ Request timeout');
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } on http.ClientException {
      if (kDebugMode) debugPrint('🌐 Network error - no connection');
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Forgot password request: $email');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) debugPrint('📥 Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send reset email',
        };
      }
    } on TimeoutException {
      if (kDebugMode) debugPrint('⏱️ Request timeout');
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } on http.ClientException {
      if (kDebugMode) debugPrint('🌐 Network error');
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }



  /// Verify OTP (before password reset)
  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Verifying OTP for: $email');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) debugPrint('📥 Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid or expired OTP',
          'code': data['code'],
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }



  ///  Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Resetting password');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) debugPrint('📥 Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to reset password',
          'code': data['code'],
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// 🆕 Resend OTP (just calls forgotPassword again)
  static Future<Map<String, dynamic>> resendOTP({
    required String email,
  }) async {
    return forgotPassword(email: email);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      if (kDebugMode) debugPrint('🔵 Fetching profile');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) debugPrint('📥 Profile Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final userProfile = {
          'success': true,
          'username': data['user']['username'],
          'email': data['user']['email'],
          'phone': data['user']['phone'],
          'profileImage': data['user']['profileImage'],
          'id': data['user']['id'],
          'role': data['user']['role'],
          'isActive': data['user']['isActive'],
          'createdAt': data['user']['createdAt'],
        };

        await saveUserData(data['user']);
        return userProfile;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Profile fetch error: $e');

      // Return cached data if available
      final cachedData = getUserData();
      if (cachedData != null) {
        if (kDebugMode) debugPrint('📦 Returning cached data');
        return {
          'success': true,
          ...cachedData,
        };
      }

      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
    required String phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final token = getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      Map<String, dynamic> updateData = {
        'username': username,
        'email': email,
        'phone': phone,
      };

      if (currentPassword != null && currentPassword.isNotEmpty) {
        updateData['currentPassword'] = currentPassword;
        updateData['newPassword'] = newPassword;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await saveUserData(data['user']);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfileImage(String imageUrl) async {
    try {
      final token = getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      if (kDebugMode) debugPrint('🔵 Updating profile image...');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/profile-image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'profileImage': imageUrl}),
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) debugPrint('✅ Profile image updated');
        return {
          'success': true,
          'message': data['message'],
          'profileImage': data['profileImage'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile image',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }

  static Future<void> logout() async {
    await _authBox.clear();
    if (kDebugMode) debugPrint('🚪 Logged out');
  }
}
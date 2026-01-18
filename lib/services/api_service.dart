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
    if (kDebugMode) debugPrint(' Token saved');
  }

  static String? getToken() {
    return _authBox.get('auth_token');
  }

  static Future<void> removeToken() async {
    await _authBox.delete('auth_token');
    if (kDebugMode) debugPrint('🔑 Token removed');
  }

  // ============== USER DATA MANAGEMENT ==============

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _authBox.put('user_data', userData);
    if (kDebugMode) debugPrint(' User data saved');
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
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint(' Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Logging in: $email');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) debugPrint('📥 Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await saveToken(data['token']);
        await saveUserData(data['user']);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
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

  // 🆕 FORGOT PASSWORD
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
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // 🆕 RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) debugPrint('🔵 Resetting password with token');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/auth/reset-password/$resetToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'newPassword': newPassword}),
      ).timeout(const Duration(seconds: 15));

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
        };
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
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

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'profile': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
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
    } catch (e) {
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
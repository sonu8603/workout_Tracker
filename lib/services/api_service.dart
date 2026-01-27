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
    if (kDebugMode) debugPrint('🔑 Token removed');
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
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your internet connection.',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

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

      if (kDebugMode) debugPrint('📥 Status: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
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

      if (kDebugMode) debugPrint('🔵 Fetching profile from: ${ApiConfig.baseUrl}/auth/me');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('🔥 Profile Status: ${response.statusCode}');
        debugPrint('🔥 Profile Body: ${response.body}');
      }

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

      final cachedData = getUserData();
      if (cachedData != null) {
        if (kDebugMode) debugPrint('📦 Returning cached user data');
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
    } catch (e) {
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
    } catch (e) {
      if (kDebugMode) debugPrint('🔴 Profile image error: $e');
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
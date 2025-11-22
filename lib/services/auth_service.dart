import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Change this to your actual backend URL
  static const String baseUrl = 'http://192.168.55.101:3000/api';

  static Future<Map<String, dynamic>> requestReset({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-reset'), // New backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      // Backend just needs to check if email exists for this demo
      // In a real app, it would generate a token and maybe send an email
      return json.decode(
        response.body,
      ); // Expect {'success': true/false, 'message': '...'}
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- NEW: Reset Password (Insecure Demo Version) ---
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'), // New backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
          // No token needed for this insecure demo version
        }),
      );
      return json.decode(
        response.body,
      ); // Expect {'success': true/false, 'message': '...'}
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // In lib/services/auth_service.dart
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Not logged in'};

    try {
      final response = await http.post(
        // Or http.put
        Uri.parse('$baseUrl/user/change-password'), // Define this route
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      final data = json.decode(response.body);
      return data; // Assuming backend returns {'success': true/false, 'message': '...'}
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Sign Up
  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'gender': gender,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Save token locally
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Save token locally
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get User Profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update User Profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    await _removeToken();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Private methods for token management
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_config.dart';
import 'api_service.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  // Login using email or username.
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final input = identifier.trim();

    final Map<String, dynamic> data = {
      if (input.contains('@')) 'email': input else 'username': input,
      'password': password,
    };

    final response = await ApiService.post(ApiConfig.login, data);

    final token = response['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Login response did not contain a valid token.');
    }

    await _storage.write(key: _tokenKey, value: token);

    ApiService.authToken = token;

    return Map<String, dynamic>.from(response['user']);
  }

  // Register a new CUSTOMER account.
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await ApiService.post(ApiConfig.register, {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password_confirm': passwordConfirm,
    });

    return Map<String, dynamic>.from(response);
  }

  // Restore an existing login session.
  static Future<Map<String, dynamic>?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    ApiService.authToken = token;

    final response = await ApiService.get(ApiConfig.profile);

    return Map<String, dynamic>.from(response);
  }

  // Get the currently authenticated user's profile.
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);

    return Map<String, dynamic>.from(response);
  }

  // Update the customer's phone number.
  static Future<void> updateCustomerPhone(String phone) async {
    await ApiService.patch(ApiConfig.customerProfile, {'phone': phone});
  }

  // Logout and clear the locally stored token.
  static Future<void> logout() async {
    try {
      if (ApiService.authToken != null) {
        await ApiService.post(ApiConfig.logout, {});
      }
    } finally {
      await _storage.delete(key: _tokenKey);
      ApiService.authToken = null;
    }
  }
}

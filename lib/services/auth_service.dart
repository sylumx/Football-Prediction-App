import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://footballprediction.site/api';

  Future<Map<String, String>> getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['token'] != null) {
          await _setToken(responseBody['token']);
          return {'success': true, 'data': responseBody};
        } else {
          return {'success': false, 'message': 'No token received in response'};
        }
      } else {
        return {'success': false, 'message': 'Login failed: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String phoneNumber,
      String countryCode,
      String countryName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phoneNumber': phoneNumber,
          'countryCode': countryCode,
          'countryName': countryName,
          'terms': true,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['token'] != null) {
          await _setToken(responseBody['token']);
          return {'success': true, 'data': responseBody};
        } else {
          return {'success': false, 'message': 'No token received'};
        }
      } else {
        return {
          'success': false,
          'message': 'Registration failed: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration error: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final result = await authenticatedRequest(() async {
      final headers = await getHeaders();
      return http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
    });

    if (result['success']) {
      await _removeToken();
    }

    return result;
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    return authenticatedRequest(() async {
      final headers = await getHeaders();
      return http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      );
    });
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final currentToken = await _getToken();
      if (currentToken == null) {
        return {'success': false, 'message': 'No token to refresh'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['token'] != null) {
          await _setToken(responseBody['token']);
          return {'success': true, 'data': responseBody};
        } else {
          return {'success': false, 'message': 'No new token received'};
        }
      } else {
        return {
          'success': false,
          'message': 'Token refresh failed: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Token refresh error: ${e.toString()}'
      };
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  Future<Map<String, dynamic>> authenticatedRequest(
      Future<http.Response> Function() requestFunction) async {
    try {
      final headers = await getHeaders();
      var response = await requestFunction();

      if (response.statusCode == 401) {
        // Token might be expired, try to refresh
        final refreshResult = await refreshToken();
        if (refreshResult['success']) {
          // Retry the request with the new token
          headers['Authorization'] = 'Bearer ${await _getToken()}';
          response = await requestFunction();
        } else {
          return {'success': false, 'message': 'Authentication failed'};
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Request failed: ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Request error: ${e.toString()}'};
    }
  }
}

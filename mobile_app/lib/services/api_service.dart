import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static String? authToken;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null) 'Authorization': 'Token $authToken',
  };

  static Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url), headers: _headers);
    return _handleResponse(response);
  }

  static Future<dynamic> post(String url, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String url, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String url) async {
    final response = await http.delete(Uri.parse(url), headers: _headers);
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw Exception(
      'Request failed (${response.statusCode}): ${body ?? response.body}',
    );
  }
}

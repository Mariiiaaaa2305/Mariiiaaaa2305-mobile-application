import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.0.110:5002/api';

  Future<List<dynamic>> getParking() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/locations'))
        .timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Error loading data');
  }

  Future<void> logUserAction(String action, String location) async {
    await http.post(
      Uri.parse('$_baseUrl/action'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': action,
        'location': location,
      }),
    );
  }
}
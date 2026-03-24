import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "http://192.168.0.110:5002/api";

  static Future<List<dynamic>> getParking() async {
    final response = await http.get(Uri.parse("$baseUrl/locations"));


    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error loading data");
    }
  }
}
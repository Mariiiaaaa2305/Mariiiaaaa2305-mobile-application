import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalAuthRepository {
  final String baseUrl = 'http://192.168.0.110:5002/api';

  static const String _userKey = 'user_data';
  static const String _historyKey = 'booking_history';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, status);
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    try {
      await http.put(
        Uri.parse('$baseUrl/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
    } catch (e) {
      log('Сервер недоступний: $e');
    }
  }

  Future<void> removeBooking(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await prefs.setStringList(_historyKey, history);

      try {
        await http.delete(Uri.parse('$baseUrl/bookings/$index'));
      } catch (_) {}
    }
  }

  Future<void> addBookingToHistory(String location, int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    history.insert(0, '$location|Місце №$slotId|$timeStr');
    await prefs.setStringList(_historyKey, history);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData == null) {
      return null;
    }

    return UserModel.fromJson(jsonDecode(userData));
  }

  Future<List<String>> getBookingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final user = await getCurrentUser();

    if (user != null && user.email == email && user.password == password) {
      await setLoggedIn(true);
      return user;
    }

    return null;
  }

  Future<void> logout() async {
    await setLoggedIn(false);
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
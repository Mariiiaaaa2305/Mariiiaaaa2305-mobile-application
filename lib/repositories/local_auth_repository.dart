import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const String _userKey = 'user_data';
  static const String _historyKey = 'booking_history';

  @override
  Future<void> registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> addBookingToHistory(String location, int slotId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    history.insert(0, "$location|Місце №$slotId|$timeStr");
    await prefs.setStringList(_historyKey, history);
  }

  Future<List<String>> getBookingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> removeBooking(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await prefs.setStringList(_historyKey, history);
    }
  }

  @override
  Future<UserModel?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_userKey);
    if (userData != null) {
      final user = UserModel.fromJson(jsonDecode(userData));
      if (user.email == email && user.password == password) return user;
    }
    return null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_userKey);
    return userData != null ? UserModel.fromJson(jsonDecode(userData)) : null;
  }

  @override
  Future<void> updateUser(UserModel user) async => registerUser(user);

  @override
  Future<void> logout() async {}

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserModel user);
  Future<UserModel?> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> updateUser(UserModel user);
  Future<void> logout();
}
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/validators.dart';
import '../../models/user_model.dart';
import '../../repositories/local_auth_repository.dart';
import '../../services/connectivity_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());

    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final hasNet = await ConnectivityService.hasConnection();

      if (!hasNet) {
        emit(AuthError('Помилка: Відсутнє підключення до інтернету!'));
        return;
      }

      final user = await authRepository.loginUser(email, password);

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Невірний email або пароль'));
      }
    } catch (_) {
      emit(AuthError('Помилка входу'));
    }
  }

  Future<void> register(UserModel user) async {
    emit(AuthLoading());

    try {
      final hasNet = await ConnectivityService.hasConnection();

      if (!hasNet) {
        emit(AuthError('Помилка: Відсутнє підключення до інтернету!'));
        return;
      }

      final emailError = AppValidators.validateEmail(user.email);
      final passwordError = AppValidators.validatePassword(user.password);
      final nameError = AppValidators.validateName(user.fullName);

      if (nameError != null) {
        emit(AuthError(nameError));
        return;
      }

      if (emailError != null) {
        emit(AuthError(emailError));
        return;
      }

      if (passwordError != null) {
        emit(AuthError(passwordError));
        return;
      }

      await authRepository.registerUser(user);
      emit(AuthSuccess('Акаунт створено!'));
    } catch (_) {
      emit(AuthError('Помилка реєстрації'));
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> loadUser() async {
    try {
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(AuthError('Не вдалося завантажити користувача'));
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await authRepository.updateUser(user);
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(AuthError('Не вдалося оновити користувача'));
    }
  }
}
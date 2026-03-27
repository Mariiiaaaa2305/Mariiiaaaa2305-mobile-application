import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/local_auth_repository.dart';
import '../../models/user_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final LocalAuthRepository repository;

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = await repository.getCurrentUser();
      final history = await repository.getBookingHistory();
      emit(ProfileLoaded(user: user, history: history));
    } catch (e) {
      emit(ProfileError("Помилка завантаження профілю"));
    }
  }

  Future<void> deleteBooking(int index) async {
    if (state is ProfileLoaded) {
      await repository.removeBooking(index);
      await loadProfile();
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await repository.updateUser(user);
      await loadProfile(); 
    } catch (e) {
      emit(ProfileError("Помилка оновлення профілю"));
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(ProfileLoggedOut());
  }

  Future<void> deleteAccount() async {
    await repository.deleteAccount();
    emit(ProfileLoggedOut());
  }
}
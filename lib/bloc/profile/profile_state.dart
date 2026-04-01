part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel? user;
  final List<String> history;

  ProfileLoaded({required this.user, required this.history});
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileLoggedOut extends ProfileState {}
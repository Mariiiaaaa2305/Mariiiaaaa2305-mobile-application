part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel? user;
  final Map<String, String> parkingData;
  final String mqttStatus;
  final String? selectedLocation;
  final List<String> bookingHistory;

  HomeLoaded({
    required this.user,
    required this.parkingData,
    required this.mqttStatus,
    required this.selectedLocation,
    required this.bookingHistory,
  });

  HomeLoaded copyWith({
    UserModel? user,
    Map<String, String>? parkingData,
    String? mqttStatus,
    String? selectedLocation,
    List<String>? bookingHistory,
    bool clearSelectedLocation = false,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      parkingData: parkingData ?? this.parkingData,
      mqttStatus: mqttStatus ?? this.mqttStatus,
      selectedLocation:
          clearSelectedLocation ? null : selectedLocation ?? this.selectedLocation,
      bookingHistory: bookingHistory ?? this.bookingHistory,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
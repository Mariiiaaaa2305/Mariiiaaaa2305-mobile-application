import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import '../../repositories/local_auth_repository.dart';
import '../../services/api_service.dart';
import '../../services/mqtt_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final LocalAuthRepository authRepository;
  final ApiService apiService;
  final MqttService mqttService;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Map<String, String>>? _mqttSubscription;

  HomeCubit({
    required this.authRepository,
    required this.apiService,
    required this.mqttService,
  }) : super(HomeInitial());

  final Map<String, String> _parkingData = {
    'ТЦ Форум Львів': '...',
    'ТРЦ Victoria Gardens': '...',
    'Аеропорт "Львів"': '...',
    'Паркінг на Валовій': '...',
  };

  String _mqttStatus = 'MQTT: DISCONNECTED';
  String? _selectedLocation;
  UserModel? _currentUser;
  List<String> _bookingHistory = [];

  Future<void> init({required bool offlineMode}) async {
    emit(HomeLoading());

    try {
      _currentUser = await authRepository.getCurrentUser();
      _bookingHistory = await authRepository.getBookingHistory();

      await _refreshFromApi();

      if (!offlineMode) {
        await _initMqtt();
      }

      _listenConnectivity(offlineMode);
      _emitLoaded();
    } catch (e) {
      emit(HomeError('Помилка завантаження домашнього екрана'));
    }
  }

  Future<void> refresh() async {
    await _refreshFromApi();
    _bookingHistory = await authRepository.getBookingHistory();
    _emitLoaded();
  }

  void selectLocation(String title) {
    _selectedLocation = title;
    _emitLoaded();
    unawaited(apiService.logUserAction('Вибір локації', title));
  }

  void clearSelectedLocation() {
    _selectedLocation = null;
    _emitLoaded();
  }

  Future<void> buildRoute() async {
    if (_selectedLocation == null) return;
    await apiService.logUserAction('Побудова маршруту', _selectedLocation!);
  }

  bool isBookedByMe(String locationName, int slotId) {
    return _bookingHistory.any(
      (b) => b.contains(locationName) && b.contains('№$slotId'),
    );
  }

  Future<void> bookSlot(String locationName, int slotId) async {
    await authRepository.addBookingToHistory(locationName, slotId);
    _bookingHistory = await authRepository.getBookingHistory();
    _emitLoaded();
  }

  Future<void> _refreshFromApi() async {
    try {
      final data = await apiService.getParking();
      for (final loc in data) {
        _updateParkingValue(
          loc['name'].toString(),
          loc['spots'].toString(),
        );
      }
    } catch (_) {}
  }

  Future<void> _initMqtt() async {
    final isConnected = await mqttService.connect();

    if (isConnected) {
      _mqttStatus = 'MQTT: CONNECTED';
      mqttService.subscribe('parking/+/status');

      await _mqttSubscription?.cancel();
      _mqttSubscription = mqttService.messages.listen((data) {
        _updateParkingValue(data['name']!, data['value']!);
        _mqttStatus = 'MQTT: CONNECTED';
        _emitLoaded();
      });
    } else {
      _mqttStatus = 'MQTT: ERROR';
    }
  }

  void _listenConnectivity(bool offlineMode) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      if (results.contains(ConnectivityResult.none)) {
        _mqttStatus = 'MQTT: NO INTERNET';
        _emitLoaded();
      } else if (!offlineMode) {
        await _initMqtt();
        await _refreshFromApi();
        _emitLoaded();
      }
    });
  }

  void _updateParkingValue(String incomingName, String value) {
    final searchName = incomingName.replaceAll('"', '').toLowerCase().trim();

    for (final key in _parkingData.keys.toList()) {
      final cleanKey = key.replaceAll('"', '').toLowerCase().trim();
      if (cleanKey.contains(searchName) || searchName.contains(cleanKey)) {
        _parkingData[key] = value;
      }
    }
  }

  void _emitLoaded() {
    emit(
      HomeLoaded(
        user: _currentUser,
        parkingData: Map<String, String>.from(_parkingData),
        mqttStatus: _mqttStatus,
        selectedLocation: _selectedLocation,
        bookingHistory: List<String>.from(_bookingHistory),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    await _mqttSubscription?.cancel();
    mqttService.disconnect();
    return super.close();
  }
}
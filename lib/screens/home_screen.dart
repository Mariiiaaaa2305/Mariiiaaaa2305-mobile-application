import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/glass_widgets.dart';
import '../repositories/local_auth_repository.dart';
import '../models/user_model.dart';
import '../services/mqtt_service.dart';



class HomeScreen extends StatefulWidget {
  final bool offlineMode;
  const HomeScreen({super.key, this.offlineMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedLocation;
  final _authRepository = LocalAuthRepository();
  UserModel? _currentUser;
  late MqttService mqtt;
  
  String mqttStatus = "MQTT: DISCONNECTED";
  StreamSubscription? _connectivitySubscription;

  Map<String, String> parkingData = {
    "ТЦ Форум Львів": "12 / 150",
    "ТРЦ Victoria Gardens": "3 / 300",
    "Аеропорт \"Львів\"": "0 / 50",
    "Паркінг на Валовій": "45 / 80",
  };

  @override
  void initState() {
    super.initState();
    _loadUser();

    if (!widget.offlineMode) {
      _initMqtt();
    } else {
      mqttStatus = "MQTT: OFFLINE";
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineSnackBar("Автологін виконано офлайн. Дані можуть бути застарілі.");
      });
    }

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        _showOfflineSnackBar("Зв’язок втрачено! Перевірте інтернет.");
        if (mounted) setState(() => mqttStatus = "MQTT: NO INTERNET");
      } else {
        if (mqttStatus != "MQTT: CONNECTED" && !widget.offlineMode) {
          _initMqtt();
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _showOfflineSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _loadUser() async {
    final user = await _authRepository.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _initMqtt() async {
    mqtt = MqttService();
    
    bool isConnected = await mqtt.connect();

    if (isConnected) {
      if (mounted) setState(() => mqttStatus = "MQTT: CONNECTED");

      mqtt.client?.onDisconnected = () {
        if (mounted) setState(() => mqttStatus = "MQTT: DISCONNECTED");
      };

      mqtt.subscribe("parking/+/status");
      
      mqtt.messages.listen((data) {
        if (mounted) {
          setState(() {
            parkingData[data["name"]!] = data["value"]!;
          });
        }
      });
    } else {
      if (mounted) setState(() => mqttStatus = "MQTT: ERROR");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DASHBOARD', style: TextStyle(letterSpacing: 2, fontSize: 14)),
            if (_currentUser != null)
              Text(
                _currentUser!.email,
                style: const TextStyle(fontSize: 10, color: Colors.cyanAccent),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mqttStatus == "MQTT: CONNECTED" 
                      ? Colors.greenAccent.withOpacity(0.1) 
                      : Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: mqttStatus == "MQTT: CONNECTED" ? Colors.greenAccent : Colors.redAccent,
                    width: 0.5
                  ),
                ),
                child: Text(
                  mqttStatus,
                  style: TextStyle(
                    fontSize: 9, 
                    fontWeight: FontWeight.bold,
                    color: mqttStatus == "MQTT: CONNECTED" ? Colors.greenAccent : Colors.redAccent
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
              _loadUser();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'УВАГА: В ТЦ "Форум" залишилось менше 10% вільних місць!',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text('ОБРАНІ', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFavCard('Дім', 'вул. Валова'),
                      _buildFavCard('Робота', 'Victoria G.'),
                      _buildFavCard('Центр', 'Пл. Ринок'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text('УСІ ЛОКАЦІЇ', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildLocationTile('ТЦ Форум Львів', parkingData['ТЦ Форум Львів']!, Colors.green),
                _buildLocationTile('ТРЦ Victoria Gardens', parkingData['ТРЦ Victoria Gardens']!, Colors.orange),
                _buildLocationTile('Аеропорт "Львів"', parkingData['Аеропорт "Львів"']!, Colors.red),
                _buildLocationTile('Паркінг на Валовій', parkingData['Паркінг на Валовій']!, Colors.green),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (selectedLocation != null)
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161B28),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('LIVE MAP: $selectedLocation', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent, letterSpacing: 1))),
                          IconButton(icon: const Icon(Icons.close, color: Colors.white24, size: 20), onPressed: () => setState(() => selectedLocation = null)),
                        ],
                      ),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 10, crossAxisSpacing: 10),
                          itemCount: 30,
                          itemBuilder: (context, index) => ParkingSlot(id: index + 1, locationName: selectedLocation!),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: ElevatedButton.icon(
                          onPressed: () => showRouteDialog(context, selectedLocation!),
                          icon: const Icon(Icons.near_me_outlined),
                          label: const Text('ПОБУДУВАТИ МАРШРУТ', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                            foregroundColor: Colors.cyanAccent,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.cyanAccent, width: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(String title, String spots, Color statusColor) {
    bool isSelected = selectedLocation == title;
    return GestureDetector(
      onTap: () => setState(() => selectedLocation = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: statusColor.withOpacity(0.2), child: Text('P', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Вільних місць: $spots', style: const TextStyle(color: Colors.white38, fontSize: 12))
                ])),
            Icon(isSelected ? Icons.keyboard_arrow_up : Icons.chevron_right, color: isSelected ? Colors.cyanAccent : Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildFavCard(String label, String sub) => Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: GlassCard(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star, color: Colors.cyanAccent, size: 16),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.white38), textAlign: TextAlign.center)
          ]),
        ),
      );
}
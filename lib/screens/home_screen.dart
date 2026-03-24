import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  static const String serverIp = "192.168.0.110"; 

  String? selectedLocation;
  final _authRepository = LocalAuthRepository();
  UserModel? _currentUser;
  late MqttService mqtt;
  
  String mqttStatus = "MQTT: DISCONNECTED";
  StreamSubscription? _connectivitySubscription;

  Map<String, String> parkingData = {
    "ТЦ Форум Львів": "...",
    "ТРЦ Victoria Gardens": "...",
    "Аеропорт \"Львів\"": "...",
    "Паркінг на Валовій": "...",
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
    _refreshFromApi();

    if (!widget.offlineMode) {
      _initMqtt();
    }

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (mounted) setState(() => mqttStatus = "MQTT: NO INTERNET");
      } else if (!widget.offlineMode) {
        _initMqtt();
        _refreshFromApi();
      }
    });
  }

  void _updateParkingValue(String incomingName, String value) {
    if (!mounted) return;
    setState(() {
      String searchName = incomingName.replaceAll('"', '').toLowerCase().trim();
      
      parkingData.forEach((key, oldVal) {
        String cleanKey = key.replaceAll('"', '').toLowerCase().trim();
        if (cleanKey.contains(searchName) || searchName.contains(cleanKey)) {
          parkingData[key] = value;
          print("✅ Сінк назви: $key отримав $value");
        }
      });
    });
  }

  Future<void> _refreshFromApi() async {
    const String apiUrl = "http://$serverIp:5002/api/locations";
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        for (var loc in data) {
          _updateParkingValue(loc['name'].toString(), loc['spots'].toString());
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
  }

  Future<void> logUserAction(String action, String location) async {
    try {
      await http.post(
        Uri.parse("http://$serverIp:5002/api/action"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": action, "location": location}),
      );
    } catch (e) {
      debugPrint("Log error: $e");
    }
  }

  Future<void> _launchGoogleMaps(String location) async {
    final String cleanLocation = location.replaceAll('"', '');
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanLocation)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _initMqtt() async {
    mqtt = MqttService();
    bool isConnected = await mqtt.connect();
    if (isConnected && mounted) {
      setState(() => mqttStatus = "MQTT: CONNECTED");
      mqtt.subscribe("parking/+/status");
      mqtt.messages.listen((data) {
        _updateParkingValue(data["name"]!, data["value"]!);
      });
    } else if (mounted) {
      setState(() => mqttStatus = "MQTT: ERROR");
    }
  }

  Future<void> _loadUser() async {
    final user = await _authRepository.getCurrentUser();
    setState(() => _currentUser = user);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DASHBOARD', style: TextStyle(letterSpacing: 2, fontSize: 14, color: Colors.white)),
            if (_currentUser != null)
              Text(_currentUser!.email, style: const TextStyle(fontSize: 10, color: Colors.cyanAccent)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildMqttBadge(),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshFromApi,
            color: Colors.cyanAccent,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlassCard(
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                        SizedBox(width: 15),
                        Expanded(child: Text('УВАГА: Оновлення даних в реальному часі активовано.', style: TextStyle(fontSize: 12, color: Colors.white70))),
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
                  ...parkingData.keys.map((name) => _buildLocationTile(
                    name, 
                    parkingData[name]!, 
                    (parkingData[name]!.contains('0 /')) ? Colors.redAccent : Colors.greenAccent
                  )).toList(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          if (selectedLocation != null) _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
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
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 15), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('LIVE MAP: $selectedLocation', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white24), onPressed: () => setState(() => selectedLocation = null)),
                ],
              ),
              const Divider(color: Colors.white10),
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
                  onPressed: () {
                    logUserAction("Побудова маршруту", selectedLocation!);
                    _launchGoogleMaps(selectedLocation!);
                  },
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
    );
  }

  Widget _buildLocationTile(String title, String spots, Color statusColor) {
    bool isSelected = selectedLocation == title;
    return GestureDetector(
      onTap: () {
        setState(() => selectedLocation = title);
        logUserAction("Вибір локації", title);
      },
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Вільних місць: $spots', style: const TextStyle(color: Colors.white38, fontSize: 12))
                ])),
            Icon(isSelected ? Icons.keyboard_arrow_up : Icons.chevron_right, color: isSelected ? Colors.cyanAccent : Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildFavCard(String label, String sub) => Container(
    width: 130, margin: const EdgeInsets.only(right: 12),
    child: GlassCard(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.star, color: Colors.cyanAccent, size: 16),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(sub, style: const TextStyle(fontSize: 10, color: Colors.white38))
      ]),
    ),
  );

  Widget _buildMqttBadge() => Center(child: Padding(padding: const EdgeInsets.only(right: 10), child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: mqttStatus.contains("CONNECTED") ? Colors.greenAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1), 
      borderRadius: BorderRadius.circular(5), 
      border: Border.all(color: mqttStatus.contains("CONNECTED") ? Colors.greenAccent : Colors.redAccent, width: 0.5)
    ),
    child: Text(mqttStatus, style: TextStyle(fontSize: 8, color: mqttStatus.contains("CONNECTED") ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
  )));
}
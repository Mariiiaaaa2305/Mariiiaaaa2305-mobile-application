import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../repositories/local_auth_repository.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepository = LocalAuthRepository();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authRepository.getCurrentUser();
    setState(() { _user = user; });
  }

  void _goToEdit() async {
    await Navigator.pushNamed(context, '/edit_profile');
    _loadUser(); 
  }

  void _deleteBooking(int index) async {
    await _authRepository.removeBooking(index);
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text('МІЙ ПРОФІЛЬ', style: TextStyle(fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.cyanAccent,
                        child: Icon(Icons.person, size: 50, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(child: Text(_user?.fullName ?? 'Maria', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    Center(child: Text(_user?.email ?? 'tsiupka2305@gmail.com', style: const TextStyle(color: Colors.white38))),
                    const SizedBox(height: 20),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        side: const BorderSide(color: Colors.white10),
                        foregroundColor: Colors.white70,
                      ),
                      onPressed: _goToEdit,
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: const Text('РЕДАГУВАТИ ПРОФІЛЬ'),
                    ),

                    const SizedBox(height: 30),
                    const Text('МІЙ АВТОМОБІЛЬ', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                    const SizedBox(height: 10),
                    
                    GlassCard(
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, color: Colors.white),
                        title: Text('${_user?.carBrand ?? "Tesla"} ${_user?.carModel ?? "Model 3"}'),
                        subtitle: Text(_user?.carPlate ?? 'BC 0001 AA'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.white38),
                          onPressed: _goToEdit,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text('ІСТОРІЯ БРОНЮВАНЬ', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                    const SizedBox(height: 10),
                    
                    FutureBuilder<List<String>>(
                      future: _authRepository.getBookingHistory(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Історія порожня', style: TextStyle(color: Colors.white24));
                        }
                        return Column(
                          children: snapshot.data!.asMap().entries.map((entry) {
                            int idx = entry.key;
                            final parts = entry.value.split('|'); 
                            int slotNum = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                            return _detailedHistoryItem(parts[0], parts[1], parts[2], "25 грн/год", slotNum % 2 == 0, idx);
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    const Text('ОСТАННІ СЕСІЇ', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                    const SizedBox(height: 10),
                    _sessionItem('ТЦ Форум', '2 год 15 хв', '45 UAH', Colors.greenAccent),
                    _sessionItem('Паркінг Валова', '45 хв', '15 UAH', Colors.white70),
                  ],
                ),
              ),
            ),
            
            // НИЖНЯ ЧАСТИНА: Кнопки, зафіксовані внизу (не скроляться)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    icon: const Icon(Icons.logout, color: Colors.blueAccent),
                    label: const Text('ВИЙТИ З ПРОФІЛЮ'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _authRepository.deleteAccount();
                      if (mounted) Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    label: const Text('ВИДАЛИТИ АККАУНТ', style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailedHistoryItem(String loc, String slot, String time, String price, bool hasBolt, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Text(slot, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _deleteBooking(index),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniInfo(Icons.access_time, time),
                _miniInfo(Icons.payments_outlined, price),
                _miniInfo(Icons.bolt, hasBolt ? "Є зарядка" : "Немає"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.white38),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ],
  );

  Widget _sessionItem(String loc, String duration, String price, Color priceColor) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(duration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          Text(price, style: TextStyle(color: priceColor, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
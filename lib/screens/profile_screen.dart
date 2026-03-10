import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text('МІЙ ПРОФІЛЬ'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.cyanAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                    const Center(
                      child: Text(
                        'Цюпка Марія',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Center(child: Text('ID: 778899', style: TextStyle(color: Colors.white38))),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('РЕДАГУВАТИ ПРОФІЛЬ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text('МІЙ АВТОМОБІЛЬ', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                    const SizedBox(height: 10),
                    const GlassCard(
                      child: ListTile(
                        leading: Icon(Icons.directions_car, color: Colors.white),
                        title: Text('Tesla Model 3'),
                        subtitle: Text('BC 0001 AA'),
                        trailing: Icon(Icons.edit, size: 18, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text('ОСТАННІ СЕСІЇ', style: TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                    const SizedBox(height: 10),
                    _historyItem('ТЦ Форум', '2 год 15 хв', '45 UAH', Colors.greenAccent),
                    _historyItem('Паркінг Валова', '45 хв', '15 UAH', Colors.white24),
                    _historyItem('Victoria G.', '5 год 10 хв', '120 UAH', Colors.white24),
                    const SizedBox(height: 80), // Місце для кнопки внизу
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('ВИЙТИ З АКАУНТУ', style: TextStyle(color: Colors.redAccent)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(String loc, String time, String price, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          Text(price, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
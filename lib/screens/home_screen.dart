import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: const Text('DASHBOARD', style: TextStyle(letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                      SizedBox(width: 15),
                      Expanded(
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
                _buildLocationTile('ТЦ Форум Львів', '12 / 150', Colors.green),
                _buildLocationTile('ТРЦ Victoria Gardens', '3 / 300', Colors.orange),
                _buildLocationTile('Аеропорт "Львів"', '0 / 50', Colors.red),
                _buildLocationTile('Паркінг на Валовій', '45 / 80', Colors.green),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (selectedLocation != null)
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A2332),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('LIVE MAP: $selectedLocation', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white24),
                            onPressed: () => setState(() => selectedLocation = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: 24,
                          itemBuilder: (context, index) => ParkingSlot(id: index + 1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('ПОБУДУВАТИ МАРШРУТ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Text('P', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Вільних місць: $spots', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.cyanAccent),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildFavCard(String label, String sub) => Container(
    width: 130,
    margin: const EdgeInsets.only(right: 12),
    child: GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Colors.cyanAccent, size: 16),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.white38), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
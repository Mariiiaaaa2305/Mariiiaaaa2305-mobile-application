import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ParkingSlot extends StatelessWidget {
  final int id;
  const ParkingSlot({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    bool isFree = id % 3 != 0;
    Color color = isFree ? Colors.greenAccent : Colors.redAccent;

    return GestureDetector(
      onTap: () => _showDetails(context, id, isFree),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(child: Text('$id', style: TextStyle(color: color, fontSize: 12))),
      ),
    );
  }

  void _showDetails(BuildContext context, int id, bool free) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ДЕТАЛІ МІСЦЯ №$id', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white10, height: 30),
            _infoRow(Icons.info_outline, 'Статус: ${free ? "Вільно" : "Зайнято"}'),
            _infoRow(Icons.payments_outlined, 'Ціна: 25 грн/год'),
            _infoRow(Icons.bolt, 'Електрозарядка: ${id % 2 == 0 ? "Є" : "Немає"}'),
            const SizedBox(height: 20),
            if (free) ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => Navigator.pop(context),
              child: const Text('ЗАБРОНЮВАТИ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [Icon(icon, color: Colors.cyanAccent, size: 20), const SizedBox(width: 15), Text(text)]),
  );
}
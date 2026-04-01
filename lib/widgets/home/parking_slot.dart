import 'package:flutter/material.dart';

class ParkingSlot extends StatelessWidget {
  final int id;
  final String locationName;
  final bool isBookedByMe;
  final VoidCallback onBook;

  const ParkingSlot({
    super.key,
    required this.id,
    required this.locationName,
    required this.isBookedByMe,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final isPermanentlyOccupied = id % 3 == 0;
    final isOccupied = isPermanentlyOccupied || isBookedByMe;
    final color = isOccupied ? Colors.redAccent : Colors.greenAccent;

    return GestureDetector(
      onTap: () {
        if (isPermanentlyOccupied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Це місце вже зайняте'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        _showDetails(context, id, !isBookedByMe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            '$id',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, int id, bool free) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'ДЕТАЛІ МІСЦЯ №$id',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              locationName,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Divider(color: Colors.white10, height: 30),
            _infoRow(
              Icons.info_outline,
              'Статус: ${free ? "Вільно" : "Заброньовано вами"}',
            ),
            _infoRow(Icons.payments_outlined, 'Ціна: 25 грн/год'),
            _infoRow(
              Icons.bolt,
              'Електрозарядка: ${id % 2 == 0 ? "Є" : "Немає"}',
            ),
            const SizedBox(height: 25),
            if (free)
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'ЗАБРОНЮВАТИ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 22),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
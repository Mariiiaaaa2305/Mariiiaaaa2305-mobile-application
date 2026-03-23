import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/local_auth_repository.dart';

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ParkingSlot extends StatefulWidget {
  final int id;
  final String locationName;

  const ParkingSlot({super.key, required this.id, required this.locationName});

  @override
  State<ParkingSlot> createState() => _ParkingSlotState();
}

class _ParkingSlotState extends State<ParkingSlot> {
  bool isBookedByMe = false;
  late bool isPermanentlyOccupied;

  @override
  void initState() {
    super.initState();
    isPermanentlyOccupied = widget.id % 3 == 0;
    _checkMyBooking();
  }

  Future<void> _checkMyBooking() async {
    final history = await LocalAuthRepository().getBookingHistory();
    bool found = history.any(
        (b) => b.contains(widget.locationName) && b.contains('№${widget.id}'));
    if (mounted)
      setState(() {
        isBookedByMe = found;
      });
  }

  void _bookSlot() async {
    await LocalAuthRepository()
        .addBookingToHistory(widget.locationName, widget.id);
    _checkMyBooking();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Місце №${widget.id} заброньовано!'),
          backgroundColor: Colors.cyanAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOccupied = isPermanentlyOccupied || isBookedByMe;
    Color color = isOccupied ? Colors.redAccent : Colors.greenAccent;

    return GestureDetector(
      onTap: () {
        if (!isPermanentlyOccupied) {
          _showDetails(context, widget.id, !isBookedByMe);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Це місце вже зайняте'),
              behavior: SnackBarBehavior.floating));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
            child: Text('${widget.id}',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold))),
      ),
    );
  }

  void _showDetails(BuildContext context, int id, bool free) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B28),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
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
                    borderRadius: BorderRadius.circular(10))),
            Text('ДЕТАЛІ МІСЦЯ №$id',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.locationName,
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const Divider(color: Colors.white10, height: 30),
            _infoRow(Icons.info_outline,
                'Статус: ${free ? "Вільно" : "Заброньовано вами"}'),
            _infoRow(Icons.payments_outlined, 'Ціна: 25 грн/год'),
            _infoRow(
                Icons.bolt, 'Електрозарядка: ${id % 2 == 0 ? "Є" : "Немає"}'),
            const SizedBox(height: 25),
            if (free)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _bookSlot,
                child: const Text('ЗАБРОНЮВАТИ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 22),
            const SizedBox(width: 15),
            Text(text,
                style: const TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
      );
}

Future<void> showRouteDialog(BuildContext context, String location) async {
  final Map<String, String> coordsMap = {
    'ТЦ Форум Львів': '49.8499,24.0224',
    'ТРЦ Victoria Gardens': '49.8071,23.9782',
    'Аеропорт "Львів"': '49.8163,23.9553',
    'Паркінг на Валовій': '49.8407,24.0326',
  };

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 20),
          Text('Побудова маршруту до:\n$location', textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 1));
  if (context.mounted) Navigator.pop(context);

  final String googleMapsUrl =
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
  if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
    await launchUrl(Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication);
  }
}

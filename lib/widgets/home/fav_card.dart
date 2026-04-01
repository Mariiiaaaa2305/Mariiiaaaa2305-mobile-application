import 'package:flutter/material.dart';
import 'package:parking_app/widgets/common/glass_card.dart';

class FavCard extends StatelessWidget {
  final String label;
  final String sub;

  const FavCard({
    super.key,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: GlassCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.cyanAccent, size: 16),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/bloc/profile/profile_cubit.dart';
import 'package:parking_app/widgets/common/glass_card.dart';

class ProfileHistoryItem extends StatelessWidget {
  final String location;
  final String slot;
  final String time;
  final String price;
  final bool hasBolt;
  final int index;

  const ProfileHistoryItem({
    super.key,
    required this.location,
    required this.slot,
    required this.time,
    required this.price,
    required this.hasBolt,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    Text(
                      slot,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        context.read<ProfileCubit>().deleteBooking(index);
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
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
                _miniInfo(Icons.bolt, hasBolt ? 'Є зарядка' : 'Немає'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class ProfileSessionItem extends StatelessWidget {
  final String location;
  final String duration;
  final String price;
  final Color priceColor;

  const ProfileSessionItem({
    super.key,
    required this.location,
    required this.duration,
    required this.price,
    required this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                color: priceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
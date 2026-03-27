import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/bloc/home/home_cubit.dart';

class LocationTile extends StatelessWidget {
  final String title;
  final String spots;
  final bool isSelected;

  const LocationTile({
    super.key,
    required this.title,
    required this.spots,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        spots.contains('0 /') ? Colors.redAccent : Colors.greenAccent;

    return GestureDetector(
      onTap: () => context.read<HomeCubit>().selectLocation(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyanAccent.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.cyanAccent : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Text(
                'P',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Вільних місць: $spots',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.keyboard_arrow_up : Icons.chevron_right,
              color: isSelected ? Colors.cyanAccent : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}
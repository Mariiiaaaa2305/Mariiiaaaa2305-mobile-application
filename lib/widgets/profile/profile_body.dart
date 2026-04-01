import 'package:flutter/material.dart';

import 'profile_bottom_actions.dart';
import 'profile_history_item.dart';
import 'profile_top_section.dart';

class ProfileBody extends StatelessWidget {
  final String fullName;
  final String email;
  final String carBrand;
  final String carModel;
  final String carPlate;
  final List<String> history;

  const ProfileBody({
    super.key,
    required this.fullName,
    required this.email,
    required this.carBrand,
    required this.carModel,
    required this.carPlate,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileTopSection(
                    fullName: fullName,
                    email: email,
                    carBrand: carBrand,
                    carModel: carModel,
                    carPlate: carPlate,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ІСТОРІЯ БРОНЮВАНЬ',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (history.isEmpty)
                    const Text(
                      'Історія порожня',
                      style: TextStyle(color: Colors.white24),
                    )
                  else
                    Column(
                      children: history.asMap().entries.map((entry) {
                        final index = entry.key;
                        final parts = entry.value.split('|');

                        if (parts.length < 3) {
                          return const SizedBox.shrink();
                        }

                        final slotNum = int.tryParse(
                              parts[1].replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;

                        return ProfileHistoryItem(
                          location: parts[0],
                          slot: parts[1],
                          time: parts[2],
                          price: '25 грн/год',
                          hasBolt: slotNum % 2 == 0,
                          index: index,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 30),
                  const Text(
                    'ОСТАННІ СЕСІЇ',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const ProfileSessionItem(
                    location: 'ТЦ Форум',
                    duration: '2 год 15 хв',
                    price: '45 UAH',
                    priceColor: Colors.greenAccent,
                  ),
                  const ProfileSessionItem(
                    location: 'Паркінг Валова',
                    duration: '45 хв',
                    price: '15 UAH',
                    priceColor: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          const ProfileBottomActions(),
        ],
      ),
    );
  }
}
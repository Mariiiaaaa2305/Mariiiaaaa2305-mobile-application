import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/bloc/profile/profile_cubit.dart';
import 'package:parking_app/widgets/common/glass_card.dart';

class ProfileTopSection extends StatelessWidget {
  final String fullName;
  final String email;
  final String carBrand;
  final String carModel;
  final String carPlate;

  const ProfileTopSection({
    super.key,
    required this.fullName,
    required this.email,
    required this.carBrand,
    required this.carModel,
    required this.carPlate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.cyanAccent,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Center(
          child: Text(
            fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            email,
            style: const TextStyle(color: Colors.white38),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            side: const BorderSide(color: Colors.white10),
            foregroundColor: Colors.white70,
          ),
          onPressed: () async {
            await Navigator.pushNamed(context, '/edit_profile');

            if (!context.mounted) {
              return;
            }

            context.read<ProfileCubit>().loadProfile();
          },
          icon: const Icon(Icons.settings_outlined, size: 18),
          label: const Text('РЕДАГУВАТИ ПРОФІЛЬ'),
        ),
        const SizedBox(height: 30),
        const Text(
          'МІЙ АВТОМОБІЛЬ',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          child: ListTile(
            leading: const Icon(
              Icons.directions_car,
              color: Colors.white,
            ),
            title: Text('$carBrand $carModel'),
            subtitle: Text(carPlate),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.white38,
              ),
              onPressed: () async {
                await Navigator.pushNamed(context, '/edit_profile');

                if (!context.mounted) {
                  return;
                }

                context.read<ProfileCubit>().loadProfile();
              },
            ),
          ),
        ),
      ],
    );
  }
}
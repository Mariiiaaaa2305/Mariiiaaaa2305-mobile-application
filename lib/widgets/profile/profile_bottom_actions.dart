import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/bloc/profile/profile_cubit.dart';

class ProfileBottomActions extends StatelessWidget {
  const ProfileBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LogoutDialog(),
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.blueAccent,
            ),
            label: const Text('ВИЙТИ З ПРОФІЛЮ'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              context.read<ProfileCubit>().deleteAccount();
            },
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.redAccent,
            ),
            label: const Text(
              'ВИДАЛИТИ АККАУНТ',
              style: TextStyle(color: Colors.redAccent),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161B28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'ВИХІД',
        style: TextStyle(
          color: Colors.cyanAccent,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Ви впевнені, що хочете вийти з профілю?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'СКАСУВАТИ',
            style: TextStyle(color: Colors.white38),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
          ),
          onPressed: () {
            Navigator.pop(context);
            context.read<ProfileCubit>().logout();
          },
          child: const Text('ВИЙТИ'),
        ),
      ],
    );
  }
}
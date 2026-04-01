import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile/profile_cubit.dart';
import '../widgets/profile/profile_body.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E17),
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        if (state is! ProfileLoaded) {
          return const Scaffold(body: SizedBox());
        }

        final user = state.user;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          appBar: AppBar(
            title: const Text(
              'МІЙ ПРОФІЛЬ',
              style: TextStyle(fontSize: 16, letterSpacing: 2),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ProfileBody(
            fullName: user?.fullName ?? 'Maria',
            email: user?.email ?? 'tsiupka2305@gmail.com',
            carBrand: user?.carBrand ?? 'Tesla',
            carModel: user?.carModel ?? 'Model 3',
            carPlate: user?.carPlate ?? '',
            history: state.history,
          ),
        );
      },
    );
  }
}
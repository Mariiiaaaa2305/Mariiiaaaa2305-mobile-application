import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/bloc/home/home_cubit.dart';
import '../widgets/home/fav_card.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/home/live_map_sheet.dart';
import '../widgets/home/location_tile.dart';
import '../widgets/common/mqtt_badge.dart';

class HomeScreen extends StatelessWidget {
  final bool offlineMode;

  const HomeScreen({super.key, this.offlineMode = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeError) {
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

        final loaded = state as HomeLoaded;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DASHBOARD',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                if (loaded.user != null)
                  Text(
                    loaded.user!.email,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.cyanAccent,
                    ),
                  ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              MqttBadge(mqttStatus: loaded.mqttStatus),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().refresh(),
                color: Colors.cyanAccent,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlassCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orangeAccent,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'УВАГА: Оновлення даних в реальному часі активовано.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'ОБРАНІ',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            FavCard(label: 'Дім', sub: 'вул. Валова'),
                            FavCard(label: 'Робота', sub: 'Victoria G.'),
                            FavCard(label: 'Центр', sub: 'Пл. Ринок'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'УСІ ЛОКАЦІЇ',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ...loaded.parkingData.keys.map(
                        (name) => LocationTile(
                          title: name,
                          spots: loaded.parkingData[name]!,
                          isSelected: loaded.selectedLocation == name,
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
              if (loaded.selectedLocation != null) LiveMapSheet(state: loaded),
            ],
          ),
        );
      },
    );
  }
}
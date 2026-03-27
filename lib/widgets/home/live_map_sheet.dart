import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app/bloc/home/home_cubit.dart';
import 'package:parking_app/widgets/home/parking_slot.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveMapSheet extends StatelessWidget {
  final HomeLoaded state;

  const LiveMapSheet({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF161B28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'LIVE MAP: ${state.selectedLocation}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white24),
                    onPressed: cubit.clearSelectedLocation,
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final slotId = index + 1;

                    return ParkingSlot(
                      id: slotId,
                      locationName: state.selectedLocation!,
                      isBookedByMe:
                          cubit.isBookedByMe(state.selectedLocation!, slotId),
                      onBook: () async {
                        await cubit.bookSlot(state.selectedLocation!, slotId);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Місце №$slotId заброньовано!'),
                            backgroundColor: Colors.cyanAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await cubit.buildRoute();
                    await _launchGoogleMaps(state.selectedLocation!);
                  },
                  icon: const Icon(Icons.near_me_outlined),
                  label: const Text(
                    'ПОБУДУВАТИ МАРШРУТ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.cyanAccent,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Colors.cyanAccent,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchGoogleMaps(String location) async {
    final cleanLocation = location.replaceAll('"', '');
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanLocation)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
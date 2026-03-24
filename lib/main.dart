import 'package:flutter/material.dart';
import 'services/connectivity_service.dart';
import 'repositories/local_auth_repository.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = LocalAuthRepository();

  final bool isLoggedIn = await authRepo.isLoggedIn();

  final bool isOnline = await ConnectivityService.hasConnection();

  runApp(ParkingApp(
    initialRoute: isLoggedIn ? '/home' : '/login',
    isOnlineAtStart: isOnline,
  ));
}

class ParkingApp extends StatelessWidget {
  final String initialRoute;
  final bool isOnlineAtStart;

  const ParkingApp({
    super.key,
    required this.initialRoute,
    required this.isOnlineAtStart,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),

      initialRoute: initialRoute,

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        '/home': (context) => HomeScreen(
              offlineMode: !isOnlineAtStart,
            ),

        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
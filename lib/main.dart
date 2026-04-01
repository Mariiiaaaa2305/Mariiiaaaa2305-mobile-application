import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'services/connectivity_service.dart';
import 'services/api_service.dart';
import 'services/mqtt_service.dart';
import 'repositories/local_auth_repository.dart';

import 'bloc/auth/auth_cubit.dart';
import 'bloc/profile/profile_cubit.dart';
import 'bloc/home/home_cubit.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = LocalAuthRepository();
  final apiService = ApiService();
  final mqttService = MqttService();

  final isLoggedIn = await authRepo.isLoggedIn();
  final isOnline = await ConnectivityService.hasConnection();

  runApp(
    MyApp(
      authRepository: authRepo,
      apiService: apiService,
      mqttService: mqttService,
      initialRoute: isLoggedIn ? '/home' : '/login',
      isOnlineAtStart: isOnline,
    ),
  );
}

class MyApp extends StatelessWidget {
  final LocalAuthRepository authRepository;
  final ApiService apiService;
  final MqttService mqttService;
  final String initialRoute;
  final bool isOnlineAtStart;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.apiService,
    required this.mqttService,
    required this.initialRoute,
    required this.isOnlineAtStart,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(authRepository),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            authRepository: authRepository,
            apiService: apiService,
            mqttService: mqttService,
          )..init(offlineMode: !isOnlineAtStart),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
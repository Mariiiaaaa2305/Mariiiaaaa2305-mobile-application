import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_flash_plugin/smart_flash_plugin.dart';

import '../bloc/auth/auth_cubit.dart';
import '../widgets/auth/auth_input_field.dart';
import '../widgets/common/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  int _secretTapCount = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  Future<void> _handleSecretFlash() async {
    _secretTapCount++;

    if (_secretTapCount < 5) return;

    _secretTapCount = 0;

    try {
      final isSupported = await SmartFlashPlugin.isFlashSupported();

      if (!isSupported) {
        _showUnsupportedDialog();
        return;
      }

      await SmartFlashPlugin.toggleFlash();

      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Секретний режим активовано'),
        ),
      );
    } on PlatformException {
      _showUnsupportedDialog();
    }
  }

  void _showUnsupportedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Недоступно'),
        content: const Text('Ліхтарик не підтримується на цьому пристрої'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            colors: [Color(0xFF1A2332), Color(0xFF0A0E17)],
            radius: 1.5,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: GlassCard(
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }

                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Column(
                    children: [
                      /// ⚡ КНОПКА ЛІХТАРИКА
                      GestureDetector(
                        onTap: _handleSecretFlash,
                        child: const Icon(
                          Icons.bolt,
                          size: 60,
                          color: Colors.cyanAccent,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔥 ІНДИКАТОР
                      Text(
                        _isFlashOn
                            ? 'Ліхтарик: УВІМКНЕНО'
                            : 'Ліхтарик: ВИМКНЕНО',
                        style: TextStyle(
                          color: _isFlashOn
                              ? Colors.cyanAccent
                              : Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'SMART PARKING',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 30),

                      AuthInputField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 15),

                      AuthInputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 30),

                      /// LOGIN
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('LOGIN'),
                      ),

                      const SizedBox(height: 15),

                      /// 🔥 CREATE ACCOUNT ПОВЕРНУЛИ
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            color: Colors.white38,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../repositories/local_auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = LocalAuthRepository();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final user = await _authRepository.loginUser(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Помилка: Невірний email або пароль!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
              child: Column(
                children: [
                  const Icon(Icons.bolt, size: 60, color: Colors.cyanAccent),
                  const SizedBox(height: 20),
                  const Text('SMART PARKING', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Create an account', style: TextStyle(color: Colors.white38)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
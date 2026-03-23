import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../core/validators.dart';
import '../models/user_model.dart';
import '../repositories/local_auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = LocalAuthRepository();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        fullName: _nameController.text,
        carPlate: _plateController.text,
        carBrand: 'Tesla',
        carModel: 'Model 3',
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _authRepository.registerUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Акаунт створено! Тепер увійдіть.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add_outlined,
                      size: 50, color: Colors.cyanAccent),
                  const SizedBox(height: 20),
                  const Text('REGISTER',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(height: 30),
                  TextFormField(
                      controller: _nameController,
                      validator: AppValidators.validateName,
                      decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 15),
                  TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                          labelText: 'Car Plate',
                          prefixIcon: Icon(Icons.directions_car_outlined))),
                  const SizedBox(height: 15),
                  TextFormField(
                      controller: _emailController,
                      validator: AppValidators.validateEmail,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 15),
                  TextFormField(
                      controller: _passwordController,
                      validator: AppValidators.validatePassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline))),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: _handleRegister,
                    child: const Text('CREATE ACCOUNT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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

import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: GlassCard(
            child: Column(
              children: [
                const Icon(Icons.person_add_outlined, size: 50, color: Colors.cyanAccent),
                const SizedBox(height: 20),
                const Text('REGISTER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 30),
                const TextField(decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 15),
                const TextField(decoration: InputDecoration(labelText: 'Car Plate', prefixIcon: Icon(Icons.directions_car_outlined))),
                const SizedBox(height: 15),
                const TextField(decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 15),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CREATE ACCOUNT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
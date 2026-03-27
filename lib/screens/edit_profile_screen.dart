import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../bloc/profile/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _plateController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _emailController;

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();

    final state = context.read<ProfileCubit>().state;

    if (state is ProfileLoaded && state.user != null) {
      final user = state.user!;

      _currentUser = user;
      _nameController = TextEditingController(text: user.fullName);
      _plateController = TextEditingController(text: user.carPlate);
      _brandController = TextEditingController(text: user.carBrand);
      _modelController = TextEditingController(text: user.carModel);
      _emailController = TextEditingController(text: user.email);
    } else {
      _nameController = TextEditingController();
      _plateController = TextEditingController();
      _brandController = TextEditingController();
      _modelController = TextEditingController();
      _emailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && _currentUser != null) {
      final updatedUser = UserModel(
        fullName: _nameController.text,
        carPlate: _plateController.text,
        carBrand: _brandController.text,
        carModel: _modelController.text,
        email: _emailController.text,
        password: _currentUser!.password,
      );

      await context.read<ProfileCubit>().updateProfile(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дані успішно оновлено!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(title: const Text('РЕДАГУВАТИ ПРОФІЛЬ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                _nameController,
                'Повне ім\'я',
                Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email_outlined,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _brandController,
                      'Марка',
                      Icons.directions_car,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      _modelController,
                      'Модель',
                      Icons.edit_note,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _plateController,
                'Номер авто',
                Icons.numbers,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveChanges,
                child: const Text('ЗБЕРЕГТИ ЗМІНИ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
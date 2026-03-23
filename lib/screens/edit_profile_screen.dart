import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/local_auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authRepository = LocalAuthRepository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _plateController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _emailController;

  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      _nameController = TextEditingController(text: user.fullName);
      _plateController = TextEditingController(text: user.carPlate);
      _brandController = TextEditingController(text: user.carBrand);
      _modelController = TextEditingController(text: user.carModel);
      _emailController = TextEditingController(text: user.email);
    }
    setState(() => _isLoading = false);
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

      await _authRepository.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дані успішно оновлено!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                  _nameController, 'Повне ім\'я', Icons.person_outline),
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'Email', Icons.email_outlined),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _brandController, 'Марка', Icons.directions_car)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField(
                          _modelController, 'Модель', Icons.edit_note)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(_plateController, 'Номер авто', Icons.numbers),
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
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

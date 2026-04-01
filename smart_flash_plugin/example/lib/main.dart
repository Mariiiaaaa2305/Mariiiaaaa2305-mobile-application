import 'package:flutter/material.dart';
import 'package:smart_flash_plugin/smart_flash_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Натисніть кнопку';

  Future<void> _toggleFlash() async {
    try {
      final isSupported = await SmartFlashPlugin.isFlashSupported();

      if (!mounted) {
        return;
      }

      if (!isSupported) {
        setState(() {
          _status = 'Ліхтарик недоступний';
        });
        return;
      }

      await SmartFlashPlugin.toggleFlash();

      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Команду відправлено';
      });
    } catch (e) {
      setState(() {
        _status = 'Помилка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Flash Plugin Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleFlash,
                child: const Text('Toggle Flash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
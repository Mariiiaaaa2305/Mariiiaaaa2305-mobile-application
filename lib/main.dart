import 'package:flutter/material.dart';

void main() => runApp(ParkingMonitorApp());

class ParkingMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Monitor',
      theme: ThemeData.dark(),
      home: ParkingHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParkingHomePage extends StatefulWidget {
  @override
  _ParkingHomePageState createState() => _ParkingHomePageState();
}

class _ParkingHomePageState extends State<ParkingHomePage> {
  final TextEditingController _controller = TextEditingController();
  String statusText = '';
  Color statusColor = Colors.blueGrey;

  void checkParking() {
    final input = _controller.text;
    int? spots = int.tryParse(input);

    if (spots == null) {
      setState(() {
        statusText = 'Enter a valid number!';
        statusColor = Colors.blueGrey;
      });
      return;
    }

    setState(() {
      if (spots <= 0) {
        
        statusText = 'Parking Full ❌🚗';
        statusColor = Colors.red;
      } else if (spots <= 3) {
        
        statusText = 'Almost Full ⚠️🚗';
        statusColor = Colors.yellow;
      } else if (spots <= 9) {
        
        statusText = 'Available ✅🚗';
        statusColor = Colors.green;
      } else {
        
        statusText = 'VIP Mode 😎👑';
        statusColor = const Color(0xFFFFD700); 
      }
    });
  }

  void resetParking() {
    setState(() {
      _controller.clear();
      statusText = '';
      statusColor = Colors.blueGrey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Parking Monitor Lab1'),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Number of free spots',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.directions_car, color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: checkParking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor == Colors.blueGrey ? Colors.blue : statusColor,
                  foregroundColor: statusColor == Colors.yellow ? Colors.black : Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: resetParking,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.white38),
                ),
                child: const Text('Reset', style: TextStyle(fontSize: 18, color: Colors.white70)),
              ),
              const SizedBox(height: 40),
             
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: statusText.isEmpty ? null : Border.all(color: statusColor, width: 2),
                ),
                child: Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    shadows: [
                      if (statusColor == const Color(0xFFFFD700))
                        const Shadow(blurRadius: 10, color: Colors.orange, offset: Offset(0, 0))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
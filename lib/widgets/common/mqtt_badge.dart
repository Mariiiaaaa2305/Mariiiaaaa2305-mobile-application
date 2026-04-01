import 'package:flutter/material.dart';

class MqttBadge extends StatelessWidget {
  final String mqttStatus;

  const MqttBadge({
    super.key,
    required this.mqttStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = mqttStatus == 'MQTT: CONNECTED';

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected
                ? Colors.greenAccent.withValues(alpha: 0.1)
                : Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isConnected ? Colors.greenAccent : Colors.redAccent,
              width: 0.5,
            ),
          ),
          child: Text(
            mqttStatus,
            style: TextStyle(
              fontSize: 8,
              color: isConnected ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
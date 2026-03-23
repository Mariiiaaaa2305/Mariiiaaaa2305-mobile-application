import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:flutter/foundation.dart';

class MqttService {
  // Тепер без "_" (публічний) і з "?" (може бути null спочатку)
  MqttBrowserClient? client; 
  final _messageController = StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get messages => _messageController.stream;

  Future<bool> connect() async {
    client = MqttBrowserClient(
      'ws://broker.emqx.io/mqtt',
      'maria_${DateTime.now().millisecondsSinceEpoch}',
    );

    client!.port = 8083;
    client!.keepAlivePeriod = 20;
    client!.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client!.clientIdentifier)
        .startClean();

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();

      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        client!.updates?.listen((messages) {
          final recMess = messages[0].payload as MqttPublishMessage;
          final topic = messages[0].topic;
          final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          String name = "";
          if (topic.contains("forum")) name = "ТЦ Форум Львів";
          else if (topic.contains("victoria")) name = "ТРЦ Victoria Gardens";
          else if (topic.contains("airport")) name = "Аеропорт \"Львів\"";
          else if (topic.contains("valova")) name = "Паркінг на Валовій";

          if (name.isNotEmpty) {
            _messageController.add({"name": name, "value": payload.trim()});
          }
        });
        return true;
      }
      return false;
    } catch (e) {
      client?.disconnect();
      return false;
    }
  }

  void subscribe(String topic) {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client!.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  void disconnect() => client?.disconnect();
}
import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient? client;

  final StreamController<Map<String, String>> _messageController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get messages => _messageController.stream;

  Future<bool> connect() async {
    final String clientId = 'maria_${DateTime.now().millisecondsSinceEpoch}';

    final mqttClient = MqttServerClient('broker.emqx.io', clientId);
    mqttClient.port = 1883;
    mqttClient.keepAlivePeriod = 20;
    mqttClient.logging(on: false);
    mqttClient.autoReconnect = true;

    mqttClient.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    try {
      await mqttClient.connect();
    } catch (_) {
      mqttClient.disconnect();
      return false;
    }

    if (mqttClient.connectionStatus?.state != MqttConnectionState.connected) {
      mqttClient.disconnect();
      return false;
    }

    client = mqttClient;

    client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMess = messages.first.payload as MqttPublishMessage;
      final topic = messages.first.topic.toLowerCase();
      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      ).trim();

      String officialName = '';

      if (topic.contains('forum')) {
        officialName = 'ТЦ Форум Львів';
      } else if (topic.contains('victoria')) {
        officialName = 'ТРЦ Victoria Gardens';
      } else if (topic.contains('airport')) {
        officialName = 'Аеропорт Львів';
      } else if (topic.contains('valova')) {
        officialName = 'Паркінг на Валовій';
      }

      if (officialName.isNotEmpty) {
        _messageController.add({
          'name': officialName,
          'value': payload,
        });
      }
    });

    return true;
  }

  void subscribe(String topic) {
    client?.subscribe(topic, MqttQos.atMostOnce);
  }

  void disconnect() {
    client?.disconnect();
  }

  void dispose() {
    _messageController.close();
  }
}
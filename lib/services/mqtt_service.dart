import 'dart:async';

import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
  MqttBrowserClient? client;
  final StreamController<Map<String, String>> _messageController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get messages => _messageController.stream;

  Future<bool> connect() async {
    final String clientId = 'maria_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttBrowserClient('ws://broker.emqx.io/mqtt', clientId);

    client!.port = 8083;
    client!.keepAlivePeriod = 20;

    final connMessage =
        MqttConnectMessage().withClientIdentifier(clientId).startClean();
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();

      if (client!.connectionStatus?.state ==
          MqttConnectionState.connected) {
        client!.updates?.listen(
          (List<MqttReceivedMessage<MqttMessage>> messages) {
            final recMess = messages[0].payload as MqttPublishMessage;
            final topic = messages[0].topic.toLowerCase();
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
          },
        );
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
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
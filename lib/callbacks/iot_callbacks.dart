import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_test/constants/constants.dart';
import 'package:iot_test/cubits/cubit_iot_cubit_handler.dart';
import 'package:logger/logger.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class IOTCallbacks {
  static final Logger _logger = Logger();

  static MqttServerClient? client;

  /// Conectar al broker MQTT en Raspberry Pi
  static Future<void> connect(BuildContext context) async {

    try {
      // Crear cliente MQTT
      client = MqttServerClient(
        brokerIp,
        'flutter_app_${DateTime.now().millisecondsSinceEpoch}',
        maxConnectionAttempts: 10,
      );
      client!.port = 1883;
      client!.logging(on: false);
      client!.keepAlivePeriod = 20;
      client!.onConnected = onConnected;
      client!.onDisconnected = () => onDisconnected(context);

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(client!.clientIdentifier)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      client!.connectionMessage = connMessage;

      await client!.connect();

      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        // Suscribirse al topic de estado
        client!.subscribe('led/status', MqttQos.atLeastOnce);

        // Escuchar mensajes
        client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
          if (!context.mounted) return;
          onMessage(messages, context);
        });

        if (!context.mounted) return;

        context.read<CubitIotCubitHandler>().update(isConnected: true);

        _logger.i('✅ Conectado a Raspberry Pi');
      }
    } catch (e) {
      _logger.e('❌ Error: $e');
      disconnect();

      if (!context.mounted) return;

      context.read<CubitIotCubitHandler>().update(isConnected: false);
    }
  }

  /// Desconectar del broker
  static void disconnect() {
    client?.disconnect();
  }

  /// Callback: conectado
  static void onConnected() {
    _logger.i('✅ Conectado al broker');
  }

  /// Callback: desconectado
  static void onDisconnected(BuildContext context) {
    context.read<CubitIotCubitHandler>().update(
      isConnected: false,
      ledState: false,
    );
    _logger.w("Desconectado");

  }

  /// Callback: mensaje recibido
  static void onMessage(List<MqttReceivedMessage<MqttMessage>> messages, BuildContext context) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );

    try {
      final data = jsonDecode(payload);

      context.read<CubitIotCubitHandler>().update(
        ledState: data['state'] == 'ON',
        lastUpdate: formatTime(data['timestamp'])
      );
      
    } catch (e) {
      _logger.e('Error parseando: $e');
    }
  }

  /// Enviar comando para encender/apagar LED
  static void sendCommand(String command, BuildContext context,) {
    final isConnected = context.read<CubitIotCubitHandler>().state.isConnected;
    if (client == null || !isConnected) {
      _logger.w('No conectado');
      return;
    }

    final message = jsonEncode({
      'state': command,
      'timestamp': DateTime.now().toIso8601String(),
      'source': 'flutter_app',
    });

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client!.publishMessage(
      'led/control',
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    _logger.i('📤 Comando enviado: $command');
  }

  /// Formatear timestamp
  static String formatTime(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}

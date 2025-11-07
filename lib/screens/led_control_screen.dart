import 'package:flutter/material.dart';
import 'package:iot_test/constants/raspberry_pi_ip.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class LEDControlScreen extends StatefulWidget {
  const LEDControlScreen({super.key});

  @override
  State<LEDControlScreen> createState() => _LEDControlScreenState();
}

class _LEDControlScreenState extends State<LEDControlScreen> {
  MqttServerClient? client;
  final Logger _logger = Logger();
  
  // Estado de la UI
  bool isConnected = false;
  bool ledState = false;
  String lastUpdate = 'N/A';
  
  // Configuración (cambiar por la IP de tu Raspberry Pi)
  final TextEditingController _ipController = TextEditingController(
    text: raspberryPiIP
  );
  
  @override
  void dispose() {
    client?.disconnect();
    _ipController.dispose();
    super.dispose();
  }
  
  /// Conectar al broker MQTT en Raspberry Pi
  Future<void> _connect() async {
    final broker = _ipController.text.trim();
    
    try {
      // Crear cliente MQTT
      client = MqttServerClient(broker, 'flutter_app_${DateTime.now().millisecondsSinceEpoch}');
      client!.port = 1883;
      client!.logging(on: false);
      client!.keepAlivePeriod = 20;
      client!.onConnected = _onConnected;
      client!.onDisconnected = _onDisconnected;
      
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
        client!.updates!.listen(_onMessage);
        
        setState(() => isConnected = true);
        
        _showSnackBar('✅ Conectado a Raspberry Pi', Colors.green);
      }
    } catch (e) {
      _showSnackBar('❌ Error: $e', Colors.red);
      client?.disconnect();
      setState(() => isConnected = false);
    }
  }
  
  /// Desconectar del broker
  void _disconnect() {
    client?.disconnect();
  }
  
  /// Callback: conectado
  void _onConnected() {
    _logger.i('✅ Conectado al broker');
  }
  
  /// Callback: desconectado
  void _onDisconnected() {
    setState(() {
      isConnected = false;
      ledState = false;
    });
    _showSnackBar('🔴 Desconectado', Colors.orange);
  }
  
  /// Callback: mensaje recibido
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    
    try {
      final data = jsonDecode(payload);
      setState(() {
        ledState = data['state'] == 'ON';
        lastUpdate = _formatTime(data['timestamp']);
      });
    } catch (e) {
      _logger.e('Error parseando: $e');
    }
  }
  
  /// Enviar comando para encender/apagar LED
  void _sendCommand(String command) {
    if (client == null || !isConnected) {
      _showSnackBar('⚠️ No conectado', Colors.orange);
      return;
    }
    
    final message = jsonEncode({
      'state': command,
      'timestamp': DateTime.now().toIso8601String(),
      'source': 'flutter_app'
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
  String _formatTime(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
  
  /// Mostrar SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('🍓 Control LED - Raspberry Pi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador de conexión
            _buildConnectionIndicator(),
            const SizedBox(height: 30),
            
            // Campo de IP
            if (!isConnected) _buildIpField(),
            if (!isConnected) const SizedBox(height: 20),
            
            // Botón conectar/desconectar
            _buildConnectionButton(),
            
            if (isConnected) ...[
              const SizedBox(height: 40),
              
              // Indicador visual del LED
              _buildLedIndicator(),
              const SizedBox(height: 40),
              
              // Controles
              _buildControlButtons(),
              const SizedBox(height: 30),
              
              // Info
              _buildStatusInfo(),
            ],
            
            const Spacer(),
            _buildInstructions(),
          ],
        ),
      ),
    );
  
  Widget _buildConnectionIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? 'Conectado' : 'Desconectado',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIpField() {
    return TextField(
      controller: _ipController,
      decoration: InputDecoration(
        labelText: 'IP del Raspberry Pi',
        hintText: '192.168.1.100',
        prefixIcon: const Icon(Icons.router),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
  
  Widget _buildConnectionButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isConnected ? _disconnect : _connect,
        icon: Icon(isConnected ? Icons.link_off : Icons.link),
        label: Text(
          isConnected ? 'Desconectar' : 'Conectar',
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected ? Colors.red : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLedIndicator() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ledState ? Colors.yellow : Colors.grey.shade800,
        boxShadow: ledState
            ? [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.8),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ]
            : [],
      ),
      child: Icon(
        Icons.lightbulb,
        size: 80,
        color: ledState ? Colors.white : Colors.grey.shade600,
      ),
    );
  }
  
  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sendCommand('ON'),
                icon: const Icon(Icons.power_settings_new),
                label: const Text('ENCENDER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sendCommand('OFF'),
                icon: const Icon(Icons.power_off),
                label: const Text('APAGAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _sendCommand('TOGGLE'),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('ALTERNAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildInfoRow('Estado', ledState ? 'ENCENDIDO' : 'APAGADO'),
            const Divider(),
            _buildInfoRow('Última actualización', lastUpdate),
            const Divider(),
            _buildInfoRow('Topic control', 'led/control'),
            const Divider(),
            _buildInfoRow('Topic status', 'led/status'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildInstructions() {
    return Card(
      color: Colors.blue.shade900,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💡 Instrucciones:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Asegúrate que Mosquitto esté corriendo en el RPi'),
            Text('2. Ejecuta el script Python en el Raspberry Pi'),
            Text('3. Ingresa la IP de tu Raspberry Pi'),
            Text('4. Presiona Conectar'),
            Text('5. ¡Controla el LED físico! 🎉'),
          ],
        ),
      ),
    );
  }
}

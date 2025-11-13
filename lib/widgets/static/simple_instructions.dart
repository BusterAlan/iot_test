import 'package:flutter/material.dart';

class SimpleInstructions extends StatelessWidget {
  const SimpleInstructions({super.key});

  @override
  Widget build(BuildContext context) => Card(
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
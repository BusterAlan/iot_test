import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_test/cubits/cubit_iot_cubit_handler.dart';
import 'package:iot_test/cubits/state/iot_mqtt_state_entity.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CubitIotCubitHandler, IOTMqttStateEntity>(
    builder: (context, state) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: state.isConnected ? Colors.green.shade800 : Colors.red.shade800,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.isConnected ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              state.isConnected ? 'Conectado' : 'Desconectado',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    },
  );
}

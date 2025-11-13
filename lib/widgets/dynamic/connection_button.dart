import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_test/cubits/cubit_iot_cubit_handler.dart';
import 'package:iot_test/cubits/state/iot_mqtt_state_entity.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({super.key, this.onDisconnect, this.onConnect});

  final VoidCallback? onDisconnect;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) => BlocBuilder<CubitIotCubitHandler, IOTMqttStateEntity>(
    builder: (context, state) {
      return ElevatedButton.icon(
        onPressed: state.isConnected ? onDisconnect : onConnect,
        icon: Icon(state.isConnected ? Icons.link_off : Icons.link),
        label: Text(
          state.isConnected ? 'Desconectar' : 'Conectar',
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          maximumSize: Size.fromHeight(55),
          backgroundColor: state.isConnected ? Colors.red : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    },
  );
}

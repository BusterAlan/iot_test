import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_test/cubits/state/iot_mqtt_state_entity.dart';

class CubitIotCubitHandler extends Cubit<IOTMqttStateEntity> {
  CubitIotCubitHandler() : super(IOTMqttStateEntity());

  void update({bool? isConnected, bool? ledState, String? lastUpdate}) {
    final String now = DateTime.now().toIso8601String();
    emit(
      state.copyWith(
        isConnected: isConnected,
        ledState: ledState,
        lastUpdate: lastUpdate ?? now,
      ),
    );
  }
}

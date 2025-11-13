import 'package:equatable/equatable.dart';

class IOTMqttStateEntity extends Equatable {
  final bool isConnected;
  final bool ledState;
  final String lastUpdate;

  const IOTMqttStateEntity({
    this.isConnected = false,
    this.ledState = false,
    this.lastUpdate = 'N/A',
  });

  @override
  List<Object?> get props => [isConnected, ledState, lastUpdate];

  IOTMqttStateEntity copyWith({
    bool? isConnected,
    bool? ledState,
    String? lastUpdate,
  }) => IOTMqttStateEntity(
      isConnected: isConnected ?? this.isConnected,
      ledState: ledState ?? this.ledState,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
}

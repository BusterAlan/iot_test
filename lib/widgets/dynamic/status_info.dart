import 'package:flutter/material.dart';
import 'package:iot_test/widgets/static/info_row.dart';

class StatusInfo extends StatelessWidget {
  const StatusInfo({
    super.key,
    this.ledState = false,
    required this.lastUpdate,
  });

  final bool ledState;
  final String lastUpdate;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          InfoRow(label: 'Estado', value: ledState ? 'ENCENDIDO' : 'APAGADO'),
          const Divider(),
          InfoRow(label: 'Última actualización', value: lastUpdate),
          const Divider(),
          InfoRow(label: 'Topic control', value: 'led/control'),
          const Divider(),
          InfoRow(label: 'Topic status', value: 'led/status'),
        ],
      ),
    ),
  );
}

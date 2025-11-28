import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_test/callbacks/iot_callbacks.dart';
import 'package:iot_test/cubits/cubit_iot_cubit_handler.dart';
import 'package:iot_test/cubits/state/iot_mqtt_state_entity.dart';
import 'package:iot_test/widgets/widgets.dart';

class LEDControlScreen extends StatelessWidget {
  const LEDControlScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('🍓 Control LED - Raspberry Pi'),
      centerTitle: true,
    ),
    body: BlocProvider(
      create: (context) => CubitIotCubitHandler(),
      child: _LEDControlContent(),
    ),
  );
}

class _LEDControlContent extends StatefulWidget {
  const _LEDControlContent();

  @override
  State<_LEDControlContent> createState() => _LEDControlContentState();
}

class _LEDControlContentState extends State<_LEDControlContent> {
  @override
  void dispose() {
    IOTCallbacks.disconnect();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    IOTCallbacks.connect(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: ListView(
      children: [
        ConnectionIndicator(),
        const SizedBox(height: 30),

        ConnectionButton(),

        BlocBuilder<CubitIotCubitHandler, IOTMqttStateEntity>(
          builder: (context, state) => Column(
            children: [
              const SizedBox(height: 40),

              LedIndicator(ledState: state.ledState),

              const SizedBox(height: 40),

              ControlButtons(),
              const SizedBox(height: 30),

              StatusInfo(
                ledState: state.ledState,
                lastUpdate: state.lastUpdate,
              ),
            ],
          ),
        ),

        const Spacer(),
        SimpleInstructions(),
      ],
    ),
  );
}

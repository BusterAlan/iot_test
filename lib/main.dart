import 'package:flutter/material.dart';
import 'package:iot_test/screens/led_control_screen.dart';

void main() => runApp(const LEDControlApp());

class LEDControlApp extends StatelessWidget {
  const LEDControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Control - Raspberry Pi',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: "home",
      routes: {
        "home": (_) => const LEDControlScreen(),
      },
    );
  }
}

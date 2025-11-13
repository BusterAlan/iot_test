import 'package:flutter/material.dart';
import 'package:iot_test/controllers/ip_controller.dart';

class IpTextField extends StatelessWidget {
  const IpTextField({super.key});

  @override
  Widget build(BuildContext context) => TextField(
      controller: IpController.value,
      decoration: InputDecoration(
        hintText: 'IP del Raspberry Pi',
        prefixIcon: const Icon(Icons.router),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: TextInputType.number,
    );
}
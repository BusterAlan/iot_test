import 'package:flutter/material.dart';
import 'package:iot_test/constants/raspberry_pi_ip.dart';

class IpController {
  static TextEditingController value = TextEditingController(
    text: raspberryPiIP
  );
}

import 'package:flutter/material.dart' show IconData, Color, Icons, Colors;

enum ButtonActionsEnum { on, off, toggle }

extension IconDataValue on ButtonActionsEnum {
  IconData iconData() => switch (this) {
    ButtonActionsEnum.on => Icons.power_settings_new,
    ButtonActionsEnum.off => Icons.power_off,
    ButtonActionsEnum.toggle => Icons.swap_horiz,
  };
}

extension RepresentativeColorValue on ButtonActionsEnum {
  Color color() => switch (this) {
    ButtonActionsEnum.on => Colors.green,
    ButtonActionsEnum.off => Colors.red,
    ButtonActionsEnum.toggle => Colors.orange,
  };
}

class IOTActionEntity {
  final String label;
  final IconData iconData;
  final Color representativeColor;

  IOTActionEntity({
    required this.label,
    required this.iconData,
    required this.representativeColor,
  });
}

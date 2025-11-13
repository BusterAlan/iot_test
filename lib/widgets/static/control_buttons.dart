import 'package:flutter/material.dart';
import 'package:iot_test/callbacks/iot_callbacks.dart';
import 'package:iot_test/constants/helpers/button_actions_enum.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    ButtonStyle getStyle(Color representativeColor) => ElevatedButton.styleFrom(
      backgroundColor: representativeColor,
      padding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => IOTCallbacks.sendCommand(
                  ButtonActionsEnum.on.name.toUpperCase(),
                  context,
                ),
                icon: Icon(ButtonActionsEnum.on.iconData()),
                style: getStyle(
                  ButtonActionsEnum.on.color(),
                ),
                label: Text(ButtonActionsEnum.on.name.toUpperCase()),
              ),
            ),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => IOTCallbacks.sendCommand(
                  ButtonActionsEnum.off.name.toUpperCase(),
                  context,
                ),
                icon: Icon(ButtonActionsEnum.off.iconData()),
                style: getStyle(
                  ButtonActionsEnum.off.color(),
                ),
                label: Text(ButtonActionsEnum.off.name.toUpperCase()),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => IOTCallbacks.sendCommand(
              ButtonActionsEnum.toggle.name.toUpperCase(),
              context,
            ),
            icon: Icon(ButtonActionsEnum.toggle.iconData()),
            style: getStyle(
              ButtonActionsEnum.toggle.color(),
            ),
            label: Text(ButtonActionsEnum.toggle.name.toUpperCase()),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class LedIndicator extends StatelessWidget {
  const LedIndicator({super.key, this.ledState = false});

  final bool ledState;

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    height: 150,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: ledState ? Colors.yellow : Colors.grey.shade800,
      boxShadow: ledState
          ? [
              BoxShadow(
                color: Colors.yellow.withValues(alpha: 0.8),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ]
          : [],
    ),
    child: Icon(
      Icons.lightbulb,
      size: 80,
      color: ledState ? Colors.white : Colors.grey.shade600,
    ),
  );
}

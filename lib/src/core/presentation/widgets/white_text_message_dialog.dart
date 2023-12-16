import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';

class WhiteTextMessageDialog extends StatelessWidget {
  const WhiteTextMessageDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            message,
            style: context.textTheme.displaySmall?.copyWith(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

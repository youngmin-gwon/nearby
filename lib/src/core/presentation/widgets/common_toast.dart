import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';

class CommonToast extends StatelessWidget {
  const CommonToast({
    super.key,
    required this.controller,
    required this.message,
  });

  final FlashController controller;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FlashBar(
      controller: controller,
      position: FlashPosition.top,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: context.theme.colorScheme.primaryContainer,
      contentTextStyle: context.textTheme.bodyMedium
          ?.copyWith(color: context.theme.colorScheme.onPrimaryContainer),
      content: Text(message),
    );
  }
}

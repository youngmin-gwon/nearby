import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: context.sizeOf.height / 3,
          width: context.sizeOf.width * (3 / 4),
          child: Material(
            elevation: 10,
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 12.0,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

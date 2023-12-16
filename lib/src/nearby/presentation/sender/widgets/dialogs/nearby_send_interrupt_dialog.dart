import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbySendInterruptDialog extends StatelessWidget {
  const NearbySendInterruptDialog({super.key, required this.deviceName});

  final String deviceName;
  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '에러',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('전송하려던 기기가 목록에서 사라졌습니다.'),
          const SizedBox(height: 12),
          Text('기기: $deviceName'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: context.navigator.pop,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.onPrimaryContainer,
                foregroundColor: context.theme.colorScheme.onPrimary,
              ),
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }
}

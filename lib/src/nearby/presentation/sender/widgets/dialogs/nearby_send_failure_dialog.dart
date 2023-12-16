import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbySendFailureDialog extends StatelessWidget {
  const NearbySendFailureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '전송 실패',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('전송 시도 하였으나 실패하였습니다.'),
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

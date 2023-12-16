import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbySendRejectionDialog extends StatelessWidget {
  const NearbySendRejectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '전송 거절',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('상대방이 전송을 거절하였습니다.'),
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

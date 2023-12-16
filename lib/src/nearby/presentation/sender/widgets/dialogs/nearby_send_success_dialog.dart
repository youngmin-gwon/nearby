import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbySendSuccessDialog extends StatelessWidget {
  const NearbySendSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '전송 성공',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('데이터 전송에 성공하였습니다.'),
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

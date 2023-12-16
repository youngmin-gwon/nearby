import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbyReceiveSuccessDialog extends StatelessWidget {
  const NearbyReceiveSuccessDialog({super.key, required this.dataName});

  final String dataName;

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
          const Text('데이터를 성공적으로 받았습니다!'),
          const SizedBox(height: 12),
          Text('데이터: $dataName'),
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

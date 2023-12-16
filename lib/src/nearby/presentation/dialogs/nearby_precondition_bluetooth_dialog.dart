import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbyPreconditionBluetoothDialog extends StatelessWidget {
  const NearbyPreconditionBluetoothDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '블루투스 설정 오류',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('이 기능은 블루투스가 켜져있어야 사용 가능한 기능입니다. 블루투스를 켜주세요.'),
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

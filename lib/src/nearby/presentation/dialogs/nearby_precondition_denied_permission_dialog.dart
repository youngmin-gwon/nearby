import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbyPreconditionDeniedPermissionDialog extends StatelessWidget {
  const NearbyPreconditionDeniedPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '권한 오류',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
              '앱을 사용하기 위한 기능에 대한 권한부여를 거부하였습니다. 기능을 사용하기 위하여 설정에서 앱에 대한 권한을 부여해주세요.'),
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

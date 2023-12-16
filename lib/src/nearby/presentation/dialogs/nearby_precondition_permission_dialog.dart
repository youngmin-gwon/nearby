import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_dialog.dart';

class NearbyPreconditionPermissionDialog extends StatelessWidget {
  const NearbyPreconditionPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Column(
        children: [
          Text(
            '권한 부여',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('애플리케이션이 사용하기 위한 기능에 대한 권한을 부여하지 않았습니다. 권한을 부여하시겠습니까?'),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.navigator.pop(false),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.navigator.pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        context.theme.colorScheme.onPrimaryContainer,
                    foregroundColor: context.theme.colorScheme.onPrimary,
                  ),
                  child: const Text('부여'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

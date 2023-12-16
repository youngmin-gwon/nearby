import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_bottom_sheet.dart';

class NearbyReceiveConfirmBottomSheet extends StatelessWidget {
  const NearbyReceiveConfirmBottomSheet(
      {super.key, required this.userName, required this.dataName});

  final String userName;
  final String dataName;

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'From',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text(
            'Data',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            dataName,
            style: context.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.navigator.pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        context.theme.colorScheme.onPrimaryContainer,
                    foregroundColor: context.theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.navigator.pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.colorScheme.primaryContainer,
                    foregroundColor: context.theme.colorScheme.primary,
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('확인'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

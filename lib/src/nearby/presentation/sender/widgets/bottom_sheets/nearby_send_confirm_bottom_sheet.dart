import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_bottom_sheet.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_event.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/sender/ui_state/ui_send_property.dart';

class NearbySendConfirmBottomSheet extends ConsumerWidget {
  const NearbySendConfirmBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonBottomSheet(
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              ref.watch(uiSendPropertyProvider).selectedDevice?.name ??
                  'something went wrong',
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Data',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              ref.watch(uiSendPropertyProvider).selectedAsset?.name ??
                  'something went wrong',
              style: context.textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: context.navigator.pop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.theme.colorScheme.primaryContainer,
                      foregroundColor: context.theme.colorScheme.primary,
                    ),
                    icon: const Icon(Icons.cancel),
                    label: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.navigator.pop();
                      ref
                          .read(nearbySenderBlocProvider.notifier)
                          .mapEventToState(
                            NearbySenderEvent.requestConnection(
                              ref
                                  .watch(uiSendPropertyProvider)
                                  .selectedDevice!
                                  .id,
                              ref
                                  .watch(uiSendPropertyProvider)
                                  .selectedAsset!
                                  .name,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.theme.colorScheme.onPrimaryContainer,
                      foregroundColor: context.theme.colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('보내기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

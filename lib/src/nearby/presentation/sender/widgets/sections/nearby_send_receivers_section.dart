import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/sender/ui_state/ui_send_property.dart';

class NearbySendReceiversSection extends ConsumerWidget {
  const NearbySendReceiversSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _resetUiStateWhenEndpointLost(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '유저 목록',
          style: context.textTheme.headlineSmall,
        ),
        const Divider(height: 8),
        Expanded(
          child: _receiverListOnDiscovering(ref),
        ),
        const Divider(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: ref.watch(uiSendPropertyProvider).selectedDevice != null
                ? () => ref.read(uiSendPropertyProvider).setDevice(null)
                : null,
            child: const Text('선택 취소'),
          ),
        ),
      ],
    );
  }

  /// [Nearby]의 onEndpointLost 를 통해 이전에 클릭했던 UI 요소가 없어지는 경우가 있음.
  /// 그런 경우, UI 상태도 업데이트 해줘야하기 때문에 만든 메소드
  void _resetUiStateWhenEndpointLost(WidgetRef ref) {
    ref.listen(
      nearbySenderBlocProvider,
      (previous, current) {
        if (current is NearbySenderStateDiscovering) {
          if (!current.devices
              .contains(ref.read(uiSendPropertyProvider).selectedDevice)) {
            ref.read(uiSendPropertyProvider).setDevice(null);
          }
        }
      },
    );
  }

  Widget _receiverListOnDiscovering(WidgetRef ref) {
    final nearbyState = ref.watch(nearbySenderBlocProvider);

    // discovering 상태일때만, devices 목록을 보여주게 됨.
    //
    // REF: default 구문에 다른 모든 case 가 포함되니 주의
    return switch (nearbyState) {
      NearbySenderStateDiscovering() => NearbyReceiversList(
          devices: nearbyState.devices,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class NearbyReceiversList extends ConsumerWidget {
  const NearbyReceiversList({
    super.key,
    required this.devices,
  });

  final List<NearbyDevice> devices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final bool isSelected =
            ref.watch(uiSendPropertyProvider).selectedDevice == devices[index];
        return GestureDetector(
          onTap: () =>
              ref.read(uiSendPropertyProvider).setDevice(devices[index]),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? context.theme.colorScheme.primary
                    : context.theme.colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
              color: context.theme.colorScheme.surfaceVariant.withOpacity(.4),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              devices[index].name,
              style: context.textTheme.labelLarge?.copyWith(
                fontSize: 20,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
      itemCount: devices.length,
    );
  }
}

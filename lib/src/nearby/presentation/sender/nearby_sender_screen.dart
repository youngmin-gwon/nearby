import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_event.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';

import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/sender/ui_state/ui_send_property.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/sections/nearby_send_data_section.dart';
import 'package:poc/src/nearby/presentation/sender/widgets/sections/nearby_send_receivers_section.dart';

class NearbySenderScreen extends ConsumerStatefulWidget {
  const NearbySenderScreen({super.key});

  @override
  ConsumerState<NearbySenderScreen> createState() => _NearbySenderScreenState();
}

class _NearbySenderScreenState extends ConsumerState<NearbySenderScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ref
        .read(nearbySenderBlocProvider.notifier)
        .mapEventToState(const NearbySenderEvent.search());
  }

  @override
  Widget build(BuildContext context) {
    _reserveRouteForEachNearbyState(context, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 전송 하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: _BorderDecorationWidget(
                child: NearbySendReceiversSection(),
              ),
            ),
            const SizedBox(height: 4),
            const Expanded(
              child: _BorderDecorationWidget(
                child: NearbySendDataSection(),
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton.icon(
              onPressed: ref.watch(uiSendPropertyProvider).isReadySubmit
                  ? () => context.navigator.pushNamed('/nearby/send/confirm')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.onPrimaryContainer,
                foregroundColor: context.theme.colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.send),
              label: const Text('전송'),
            ),
          ],
        ),
      ),
    );
  }

  void _reserveRouteForEachNearbyState(BuildContext context, WidgetRef ref) {
    ref.listen(
      nearbySenderBlocProvider,
      (previous, current) {
        switch (current) {
          case NearbySenderStateNone():
            break;
          case NearbySenderStateDiscovering():

            /// 이 case 는 전송하기 위해서 target을 설정 하였는데 advertising 목록에서
            /// 졌을 때 UI 처리를 위한 로직임
            if (current.devices
                .contains(ref.watch(uiSendPropertyProvider).selectedDevice)) {
              bool didPop = false;
              context.navigator.popUntil(
                (routes) {
                  final canPop = routes.settings.name != '/nearby/send';
                  if (canPop) {
                    didPop = true;
                  }
                  return !canPop;
                },
              );

              if (didPop) {
                context.navigator.pushNamed(
                  '/nearby/send/interrupt',
                  arguments: {
                    'deviceName':
                        ref.watch(uiSendPropertyProvider).selectedDevice!.name,
                  },
                );
              }

              ref.read(uiSendPropertyProvider).setDevice(null);
            }

          case NearbySenderStateRequesting():
            context.navigator.popUntil(
              (routes) => routes.settings.name == '/nearby/send',
            );
            context.navigator.pushNamed(
              '/nearby/send/process',
              arguments: {'message': '응답 대기중...'},
            );

          case NearbySenderStateRejected():
            context.navigator
                .popUntil((routes) => routes.settings.name == '/nearby/send');
            context.navigator
                .pushNamed('/nearby/send/reject') //
                .then(
                  (_) => ref
                      .read(nearbySenderBlocProvider.notifier)
                      .mapEventToState(
                        const NearbySenderEvent.recoverFromRejection(),
                      ),
                );

          case NearbySenderStateConnected():
            context.navigator
                .popUntil((routes) => routes.settings.name == '/nearby/send');

            context.navigator.pushNamed(
              '/nearby/send/process',
              arguments: {'message': '데이터 전송중...'},
            );

            ref.read(nearbySenderBlocProvider.notifier).mapEventToState(
                  NearbySenderEvent.sendPayload(
                    ref.read(uiSendPropertyProvider).selectedAsset!.toDomain(),
                  ),
                );

          case NearbySenderStateFailed():
            context.navigator.pushNamed('/nearby/send/fail').then(
                  (_) => context.navigator
                      .popUntil((routes) => routes.settings.name == '/nearby'),
                );

          case NearbySenderStateSuccess():
            context.navigator.pushNamed('/nearby/send/success').then(
                  (_) => context.navigator
                      .popUntil((routes) => routes.settings.name == '/nearby'),
                );
        }
      },
    );
  }
}

/// 테두리 두르고 Padding 넣어주는 위젯
///
/// **private class로 만든 이유**
///
/// - (얼마 차이 나겠냐만은) Widget Method 보다 Widget class 로 생성했을 때 성능상 이점이
/// 있다고 함
/// - private 으로 만든 이유는 여기서만 사용되고 사용되지 않을거 같아서임
class _BorderDecorationWidget extends StatelessWidget {
  const _BorderDecorationWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2.0,
          color: context.theme.dividerColor,
        ),
      ),
      child: child,
    );
  }
}

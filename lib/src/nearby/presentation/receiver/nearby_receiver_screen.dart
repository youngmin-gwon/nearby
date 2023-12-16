import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_event.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/di.dart';

/// 데이터 전송 받기 화면
class NearbyReceiverScreen extends ConsumerStatefulWidget {
  const NearbyReceiverScreen({super.key});

  @override
  ConsumerState<NearbyReceiverScreen> createState() =>
      _NearbyReceiverScreenState();
}

class _NearbyReceiverScreenState extends ConsumerState<NearbyReceiverScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(nearbyReceiverBlocProvider.notifier)
        .mapEventToState(const NearbyReceiverEvent.advertise());
  }

  @override
  Widget build(BuildContext context) {
    _reserveRouteInEachNearbyState(context, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 전송 받기'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(),
            SizedBox(height: 18),
            Text('상대방의 신호를 탐색 중입니다.')
          ],
        ),
      ),
    );
  }

  /// [NearbyReceiverState.responding] 즉, 송신자 에서 전송 지정할 때
  /// 상태가 되었을 때만, ModalBottomSheet 을 보여주도록 되어있음에 주의.
  void _reserveRouteInEachNearbyState(
    BuildContext context,
    WidgetRef ref,
  ) {
    ref.listen(
      nearbyReceiverBlocProvider,
      (previous, current) {
        switch (current) {
          case NearbyReceiverStateResponding():

            /// REF: 화면에 보여주기 위해 endpointName 이 userName|dataName 형태로 들어온다고 가정하고 있음
            final concatenatedName =
                current.connectionInfo.endpointName.split('|');
            final userName = concatenatedName.first;
            final dataName = concatenatedName.last;

            context.navigator.pushNamed<bool>(
              '/nearby/receive/confirm',
              arguments: {
                'userName': userName,
                'dataName': dataName,
              },
            ).then(
              (isAccepted) {
                /// 거절 버튼을 누른 것이 아니라, 창을 닫은 경우에도 거절로 처리하는 것 주의
                if (isAccepted == null || !isAccepted) {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.rejectRequest(current.endpointId),
                      );
                  return;
                } else {
                  ref.read(nearbyReceiverBlocProvider.notifier).mapEventToState(
                        NearbyReceiverEvent.acceptRequest(current.endpointId),
                      );
                }
              },
            );
          case NearbyReceiverStateConnected():
            context.navigator
                .popUntil((route) => route.settings.name == '/nearby/receive');
            context.navigator.pushNamed(
              '/nearby/receive/process',
              arguments: {'message': '연결중...'},
            );
          case NearbyReceiverStateSuccess():
            context.navigator
                .popUntil((route) => route.settings.name == '/nearby/receive');
            context.navigator.pushNamed(
              '/nearby/receive/success',
              arguments: {
                'dataName': current.dataName,
              },
            ).then(
              (_) => context.navigator.popUntil(
                (route) => route.settings.name == '/nearby',
              ),
            );
          case NearbyReceiverStateFailed():
            context.navigator
                .popUntil((route) => route.settings.name == '/nearby/receive');
            context.navigator
                .pushNamed(
                  '/nearby/receive/failure',
                )
                .then(
                  (_) => context.navigator
                      .popUntil((route) => route.settings.name == '/nearby'),
                );
          default:
            break;
        }
      },
    );
  }
}

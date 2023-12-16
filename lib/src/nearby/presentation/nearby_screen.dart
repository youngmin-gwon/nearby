import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';
import 'package:poc/src/nearby/di.dart';

/// 코드 작성자는 가장 큰 화면 단위(e.g. 전체를 차지하는 화면)을 부를 때, Screen 이라 명명함
///
/// 화면의 의미 요소가 작아짐에 따라, Screen -> Section -> Widget 으로 명명함
///
/// 혼자 작업할 때는 위와 같이 작업을 하나, 팀 작업에서는 팀에 맞춰 달라질 수 있음.
///
/// c.f.) Page 라는 명명을 안쓰는 이유?
/// - Navigator 2.0 에 Page 라는 클래스가 이미 이름을 선점하고 있기 때문
class NearbyScreen extends ConsumerWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: context.focus.unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Connections Example'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _checkPreconditionsForSend(
                ref,
                onPassed: () => context.navigator.pushNamed('/nearby/send'),
                onError: (issue) => _showIssuePopup(context, ref, issue),
              ),
              icon: const Icon(Icons.upload),
              label: const Text('데이터 전송하기'),
            ),
            ElevatedButton.icon(
              onPressed: () => _checkPreconditionsForSend(
                ref,
                onPassed: () => context.navigator.pushNamed('/nearby/receive'),
                onError: (issue) => _showIssuePopup(context, ref, issue),
              ),
              icon: const Icon(Icons.download),
              label: const Text('데이터 전송받기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPreconditionsForSend(
    WidgetRef ref, {
    required VoidCallback onPassed,
    required ValueChanged<PreconditionIssueType> onError,
  }) async {
    final issue =
        await ref.read(nearbyPreconditionResolverProvider).checkAnyIssue();
    if (issue == null) {
      return onPassed.call();
    }

    return onError.call(issue);
  }

  void _showIssuePopup(
      BuildContext context, WidgetRef ref, PreconditionIssueType issue) {
    switch (issue) {
      case PreconditionIssueType.permissionsNotGranted:
        context.navigator
            .pushNamed<bool>('/nearby/precondition/permission')
            .then((isAgreed) {
          if (isAgreed ?? false) {
            ref.read(nearbyPreconditionResolverProvider).resolve();
          }
        });
      case PreconditionIssueType.permissionsPermanentlyDenied:
        context.navigator.pushNamed('/nearby/precondition/no-permission');
      case PreconditionIssueType.bluetoothOff:
        context.navigator.pushNamed('/nearby/precondition/bluetooth');
    }
  }
}

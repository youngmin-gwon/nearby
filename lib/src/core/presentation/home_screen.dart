import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';

/// 코드 작성자는 가장 큰 화면 단위(e.g. 전체를 차지하는 화면)을 부를 때, Screen 이라 명명함
///
/// 화면의 의미 요소가 작아짐에 따라, Screen -> Section -> Widget 으로 명명함
///
/// 혼자 작업할 때는 위와 같이 작업을 하나, 팀 작업에서는 팅에 맞춰 달라질 수 있음.
///
/// c.f.) Page 라는 명명을 안쓰는 이유?
/// - Navigator 2.0 에 Page 라는 클래스가 이미 이름을 선점하고 있기 때문
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.navigator.pushNamed('/nearby'),
              child: const Text('Nearby Example Screen'),
            )
          ],
        ),
      ),
    );
  }
}

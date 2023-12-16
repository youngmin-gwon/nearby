import 'dart:async';

/// User 정보를 가져오는 인터페이스
abstract interface class UserInfoFetcher {
  /// [FutureOr] 로 선언한 이유는,
  ///
  /// 1. OS에 device 정보 요청하여 가져오는 비동기 방법
  /// 2. 어떠한 값을 바로 가져올 수 있는 동기 방법
  ///
  /// 이 있을거라 생각했기 때문. 즉, 수정해도 무관.
  FutureOr<String> get info;
}

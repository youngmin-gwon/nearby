import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';

/// [UserInfoFetcher] 구현 클래스.
///
/// 설명은 [UserInfoFetcher] 를 참고.
///
/// Device 정보 받아와서 Model명(iPhone/Galaxy) 등을 받아와서 반환하도록 구현함
///
/// BLoC 클래스에 InMemory Caching 을 적용할까, 여기 적용할까 하다 여기 적용함.
///
/// 즉, 언제든 위치를 바꿔도 무관하다는 의미.
final class UserInfoFetcherImpl implements UserInfoFetcher {
  UserInfoFetcherImpl(this._infoFetcher) {
    info;
  }

  /// 외부 의존성
  final DeviceInfoPlugin _infoFetcher;

  // cached 될 정보
  String? _info;

  /// 이 구현은 비동기 방법을 채택한 것에 유의.
  @override
  Future<String> get info async {
    if (_info != null) {
      return _info!;
    }

    final info = (await _infoFetcher.deviceInfo).data;
    if (Platform.isAndroid) {
      return _info = info['model'] ?? 'unidentified';
    } else if (Platform.isIOS) {
      return _info = info['utsname']['machine'] ?? 'unidentified';
    } else {
      throw UnimplementedError();
    }
  }
}

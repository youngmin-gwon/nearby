import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poc/src/nearby/application/service/nearby_precondition_resolver.dart';

/// [NearbyPreconditionResolver] 의 구현 클래스
///
/// - 설명은 [NearbyPreconditionResolver] 을 참고.
/// - Layering Architecture 의 원칙에 따라, 애플리케이션의 로직(e.g. 데이터를 가져와라)은
///   application layer 에 정의하고, 실제 구현을 infrastructure layer 에서 정의.
/// - 개발자에 따라 이 layer를 `data layer` 라고 하는 경우도 있으니 참고.
///
/// ref) Android/iOS 에 관련된 기능이 기본 구조는 같으나 세부사항이 달라
///      `Template Method` 패턴을 이용하여 코드 분리하였음.
///      각각, [NearbyPreconditionResolverConcreteImplIos],
///      [NearbyPreconditionResolverConcreteImplAndroid] 을 참고.
///
abstract base class NearbyPreconditionResolverTemplateMethodImpl
    implements NearbyPreconditionResolver {
  const NearbyPreconditionResolverTemplateMethodImpl();

  // 공통으로 필요한 권한
  List<Permission> get permissions => <Permission>[
        // bluetooth 관련
        Permission.bluetooth,
        // 위치 관련
        Permission.location,
      ];

  /// 공통적으로 권한을 승인했는지 확인해줘야함
  @override
  Future<PreconditionIssueType?> checkAnyIssue() async {
    for (final permission in permissions) {
      final status = await permission.status;
      switch (status) {
        case PermissionStatus.denied:
          return PreconditionIssueType.permissionsNotGranted;
        case PermissionStatus.granted ||
              PermissionStatus.provisional ||
              PermissionStatus.limited:
          continue;
        case PermissionStatus.permanentlyDenied || PermissionStatus.restricted:
          return PreconditionIssueType.permissionsPermanentlyDenied;
      }
    }

    return null;
  }

  /// 앱에 권한을 부여하지 않았을 때, 권한을 부여할 수 있도록 처리해줘야함
  @override
  Future<void> resolve() async {
    for (final permission in permissions) {
      await permission.request();
    }
  }
}

/// [NearbyPreconditionResolverTemplateMethodImpl] 의 iOS 버전
///
/// 권한은 base 와 동일하나, bluetooth/wifi 켜져있어야 조건을 만족함
///
/// wifi 는 ios 에서 확인할 수 없으므로 방법을 찾아야할 것으로 보임
final class NearbyPreconditionResolverConcreteImplIos
    extends NearbyPreconditionResolverTemplateMethodImpl {
  const NearbyPreconditionResolverConcreteImplIos();

  @override
  Future<PreconditionIssueType?> checkAnyIssue() async {
    // step 1. 권한 확인(template class 확인)
    final anyIssue = await super.checkAnyIssue();
    if (anyIssue != null) {
      return anyIssue;
    }

    // step 2. bluetooth on/off 확인
    if (!(await _isBluetoothEnabled())) {
      return PreconditionIssueType.bluetoothOff;
    }

    return null;
  }

  /// bluetooth 켜져있는지 확인
  ///
  /// - `permission_handler` 패키지에서 확인할 수 있음.
  ///   이 [issue](https://github.com/Baseflow/flutter-permission-handler/issues/773) 참고
  Future<bool> _isBluetoothEnabled() async {
    final bluetoothStatus = await Permission.bluetooth.serviceStatus;
    return switch (bluetoothStatus) {
      ServiceStatus.enabled => true,
      ServiceStatus.disabled || ServiceStatus.notApplicable => false,
    };
  }
}

/// [NearbyPreconditionResolverTemplateMethodImpl] 의 Android 버전
///
/// 권한이 Android SDK 별로 다르기 때문에 이를 처리해줘야함
final class NearbyPreconditionResolverConcreteImplAndroid
    extends NearbyPreconditionResolverTemplateMethodImpl {
  NearbyPreconditionResolverConcreteImplAndroid(this._deviceInfo) {
    _initializePermissions();
  }

  static const kAndroid12MinVersion = 31;
  static const kAndroid13Version = 33;

  final DeviceInfoPlugin _deviceInfo;

  // Android 기기 정보 caching 을 위한 객체
  AndroidDeviceInfo? _androidDeviceInfo;

  /// Nearby Connections를 사용하기 위해 필요한 권한들
  List<Permission>? _androidPermissions;

  /// Android12 버전 부터 필요한 권한들
  final _androidFrom12Permissions = <Permission>[
    /// bluetooth 관련
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ];

  /// Android13 버전 부터 필요한 권한들
  final _androidFrom13Permissions = <Permission>[
    /// Nearby Wifi 관련 (Android에만 해당하는 것으로 추론)
    Permission.nearbyWifiDevices,
  ];

  @override
  List<Permission> get permissions => _androidPermissions ?? super.permissions;

  @override
  Future<PreconditionIssueType?> checkAnyIssue() async {
    _androidPermissions ??= await _initializePermissions();
    return super.checkAnyIssue();
  }

  @override
  Future<void> resolve() async {
    _androidPermissions ??= await _initializePermissions();
    return super.resolve();
  }

  Future<List<Permission>> _initializePermissions() async {
    _androidDeviceInfo ??= await _deviceInfo.androidInfo;

    final permissions = <Permission>[
      ...super.permissions,
    ];

    if (_androidDeviceInfo!.version.sdkInt >= kAndroid12MinVersion) {
      permissions.addAll(_androidFrom12Permissions);
    }

    if (_androidDeviceInfo!.version.sdkInt >= kAndroid13Version) {
      permissions.addAll(_androidFrom13Permissions);
    }

    return permissions;
  }
}

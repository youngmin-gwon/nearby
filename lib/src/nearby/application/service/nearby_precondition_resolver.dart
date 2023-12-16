/// Nearby Connections 를 사용하기 위한 필수조건이 만족되어 있는지 확인하고,
/// 만족 시키도록 만드는 클래스를 위한 인터페이스
///
/// c.f.) Checker 이상의 기능(e.g. 필수조건 만족시키기) 을 하기 때문에 이름을 변경할 필요가
/// 있음. 생각나는대로 수정할 예정.
abstract interface class NearbyPreconditionResolver {
  Future<PreconditionIssueType?> checkAnyIssue();
  Future<void> resolve();
}

enum PreconditionIssueType {
  permissionsNotGranted,
  permissionsPermanentlyDenied,
  bluetoothOff,
}

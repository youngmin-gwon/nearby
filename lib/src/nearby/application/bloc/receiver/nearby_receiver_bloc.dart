import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_event.dart';
import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_state.dart';
import 'package:poc/src/nearby/application/service/asset_facade_service.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/domain/entity/asset.dart';

// REF: StateNotifier -> Notifier 로 migration 하면서
//      `WidgetRef`를 이용한 의존성 주입을 사용할 수 없게 되었음.
//      이로 인해 의존성 사슬이 application-bloc 으로 모이게 되는 듯한 그림이 만들어짐.
//      하지만, bloc 에서도 Provider를 이용하여 의존성을 가져오기 때문에,
//      언제든 의존성 주입이 가능함. 그로 인해, testable 한 구조는 계속 가져가기 때문에 문제 없음.
class NearbyReceiverBloc extends AutoDisposeNotifier<NearbyReceiverState> {
  late final Nearby _nearby;
  late final UserInfoFetcher _infoFetcher;
  late final AssetFacadeService _assetService;

  /// [advertise] 할 때, 상대에게 누군지 알려주기 위한 값.
  ///
  /// 이 BLoC 클래스 생성하며, initializer 에서 이름을 업데이트하게 되어있음.
  String? _userName;

  /// REF: 임시 저장을 위한 변수
  /// 추후 API 수정되며 사라질 것임
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  String? _transferredData;

  @override
  NearbyReceiverState build() {
    _nearby = ref.watch(nearbyProvider);
    _infoFetcher = ref.watch(infoFetcherProvider);
    _assetService = ref.watch(assetFacadeServiceProvider);
    _loadUserName();
    ref.onDispose(() {
      stopAll();
    });
    return const NearbyReceiverState.none();
  }

  /// Event를 받으면 State 로 전환하는 함수
  ///
  /// 여러가지 Event를 가질 때, switch 문이 길어져, 거대한 함수가 되기 때문에
  /// 이를 줄이고자, event 에서 bloc 에 있는 public method 들을 호출하는 방식으로
  /// 구현함.
  ///
  /// 각 Event sealed class의 [handle] method 참고.
  void mapEventToState(NearbyReceiverEvent event) {
    event.handle(this);
  }

  /// `수신자(receiver)` 가
  /// `전송자(sender)` 에게 자신을 찾을 수 있도록 알리는 함수
  Future<void> advertise(Strategy strategy) async {
    _userName ??= await _infoFetcher.info;

    try {
      // step 2: advertising
      await _nearby.startAdvertising(
        _userName!,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      // result 2: 홍보 중으로 상태 변경
      state = NearbyReceiverState.advertising(_userName!);
    } on AlreadyInUseException {
      // 에러 발생시 failed 상태로 만들기
      state = const NearbyReceiverState.failed('already advertising');
    }
  }

  void stopAdvertising() {
    _nearby.stopAdvertising();
    state = NearbyReceiverState.none(_userName!);
  }

  Future<void> acceptConnection(String endpointId) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayloadReceived: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );

    state = const NearbyReceiverState.connected();
  }

  Future<void> rejectConnection(String endpointId) async {
    await _nearby.rejectConnection(endpointId);
    state = NearbyReceiverState.advertising(_userName!);
  }

  void stopAll() {
    _nearby.stopAllEndpoints();
    _nearby.stopAdvertising();

    state = NearbyReceiverState.none(_userName!);
  }

  /// [_userName] 을 이후에 사용할 수 있도록 적제해놓고, 상태 초기에 부족했던 사용자 이름을
  /// state 에 반영함
  Future<void> _loadUserName() async {
    _userName = await _infoFetcher.info;
    state = NearbyReceiverState.none(_userName!);
  }

  /// 연결 요청을 받은 기기에서 연결 시작 로직
  ///
  /// callback parameter 중 [ConnectionInfo] 의 `endpointName` 은
  /// `사용자이름|데이터이름` 형태로 되어있고, 이를 사용할 때, presentation layer 에서
  /// 풀어서 사용해야함을 주의.
  ///
  /// 추가 내용은 [NearbySenderBloc] 의 `requestConnection` 을 참고
  void _onConnectionInitiated(
    String endpointId,
    ConnectionInfo connectionInfo,
  ) {
    // step 1: 화면에서 상태를 처리할 수 있도록 응답 중으로 변경
    state = NearbyReceiverState.responding(endpointId, connectionInfo);
  }

  void _onConnectionResult(
    String endpointId,
    ConnectionStatus status,
  ) {
    switch (status) {
      case ConnectionStatus.connected:
        _nearby.stopAdvertising();
        state = const NearbyReceiverState.connected();
      case ConnectionStatus.error:
        state = const NearbyReceiverState.failed('connection error');
      case ConnectionStatus.rejected:
        break;
    }
  }

  void _onDisconnected(
    String endpointId,
  ) {
    _transferredData = null;
    state = NearbyReceiverState.none(_userName!);
  }

  /// 현재는 bytes 만 보내는 것을 상정하고 있음에 주의
  ///
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  void _onPayloadReceived(String endpointId, Payload payload) {
    _transferredData = String.fromCharCodes(payload.bytes!);

    _nearby.sendBytes(
      Uint8List.fromList(json.encode({'isSuccess': true}).codeUnits),
      [endpointId],
    );

    _assetService.saveAssetByReceiver(
        _userName!, TextAsset.fromText(_transferredData!));

    state = NearbyReceiverState.success(_transferredData!);
  }

  /// [PayloadTransferUpdate.status] 는 inProgress -> success 로
  /// 횟수 n >= 2 로 들어오게 되니 주의
  ///
  /// TODO: 현재는 bytes 단위만 확인했으므로 file 도 확인해보고 이 TODO 삭제하기
  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate payloadTransferUpdate,
  ) {
    switch (payloadTransferUpdate.status) {
      case PayloadStatus.none:
        break;
      case PayloadStatus.success:
        break;
      case PayloadStatus.failure:
        // TODO: 다음 프로토콜 리팩토링 하기
        _nearby.sendBytes(
          Uint8List.fromList(json.encode({'isSuccess': false}).codeUnits),
          [endpointId],
        );

        state = const NearbyReceiverState.failed(
            'something went wrong while receiving data');
      case PayloadStatus.inProgress:
        break;
      case PayloadStatus.canceled:
        state = const NearbyReceiverState.failed('canceled');
    }
  }
}

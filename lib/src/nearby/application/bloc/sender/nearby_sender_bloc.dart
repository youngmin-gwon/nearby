import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_event.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/application/service/asset_facade_service.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';
import 'package:poc/src/nearby/application/service/user_info_fetcher.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/domain/entity/asset.dart';

// REF: StateNotifier -> Notifier 로 migration 하면서
//      `WidgetRef`를 이용한 의존성 주입을 사용할 수 없게 되었음.
//      이로 인해 의존성 사슬이 application-bloc 으로 모이게 되는 듯한 그림이 만들어짐.
//      하지만, bloc 에서도 Provider를 이용하여 의존성을 가져오기 때문에,
//      언제든 의존성 주입이 가능함. 그로 인해, testable 한 구조는 계속 가져가기 때문에 문제 없음.
class NearbySenderBloc extends AutoDisposeNotifier<NearbySenderState> {
  late final Nearby _nearby;
  late final UserInfoFetcher _infoFetcher;
  late final AssetFacadeService _assetService;

  /// 데이터 보낼 endpoint id
  ///
  /// 다른 상태를 가지고 싶게 하지 않았으나,
  /// 전송을 위한 event 의 발현 시점이 다르기 때문에
  /// 상태를 가질 수 밖에 없었음
  ///
  /// connected 될 때, 값이 할당되고, disconnected 될 때, 값이 초기화 되어야하니
  /// 이것이 잘 구현되어 있는지 확인 필요
  String? _targetEndpointId;

  /// 데이터가 문제없이 전송 되었을 때, 삭제하기 위해 state를 가지고 있음
  Asset? _asset;

  @override
  NearbySenderState build() {
    _nearby = ref.watch(nearbyProvider);
    _infoFetcher = ref.watch(infoFetcherProvider);
    _assetService = ref.watch(assetFacadeServiceProvider);
    _loadUserName();
    ref.onDispose(() {
      stopAll();
    });
    return const NearbySenderState.none();
  }

  /// [advertise] / [discover] 할 때, 상대에게 누군지 알려주기 위한 값.
  ///
  /// 이 BLoC 클래스 생성하며, initializer 에서 이름을 업데이트하게 되어있음.
  String? _userName;

  /// Event를 받으면 State 로 전환하는 함수
  ///
  /// 여러가지 Event를 가질 때, switch 문이 길어져, 거대한 함수가 되기 때문에
  /// 이를 줄이고자, event 에서 bloc 에 있는 public method 들을 호출하는 방식으로
  /// 구현함.
  ///
  /// 각 Event sealed class의 [handle] method 참고.
  void mapEventToState(NearbySenderEvent event) {
    event.handle(this);
  }

  /// `송신자(sender)` 가
  /// `수신자(receiver)` 를 찾기 위한 함수
  Future<void> discover(Strategy strategy) async {
    _userName ??= await _infoFetcher.info;

    try {
      await _nearby.startDiscovery(
        _userName!,
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
      );
      // result 2: 찾고 있는 것으로 상태 변경
      state = NearbySenderState.discovering(_userName!, []);
    } on AlreadyInUseException {
      state = const NearbySenderState.failed('already discovering');
    }
  }

  void stopDiscovery() {
    _nearby.stopDiscovery();
    state = NearbySenderState.none(_userName!);
  }

  /// 연결 요청 보내기
  ///
  /// 애플리케이션 요구사항이 연결을 시도할 때, 연결 후 보낼 데이터가 무엇인지 확인하는 것이기 때문에
  /// 이를 위해 우회방법을 사용함.
  /// - [userName]과 [dataName] 을 '|'(pipe) 로 합친 후 보냄.
  ///
  /// 수신자에서도 [onConnectionInitiated] 에서 이를 처리해줘야하는 것 잊지 않아야 함
  Future<void> requestConnection(
    String endpointId,
    String dataName,
  ) async {
    final concatenatedName = "$_userName|$dataName";

    _nearby.requestConnection(
      concatenatedName,
      endpointId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
    state = const NearbySenderState.requesting();
  }

  // TODO: 현재는 bytes 보내는 것만 가정하고 있으므로, 수정후 이 TODO 지우기
  Future<void> send(Asset asset) async {
    if (_targetEndpointId == null) {
      state = const NearbySenderState.failed('endpoint is null!');
      return;
    }

    _asset = asset;

    _nearby.sendBytes(
      Uint8List.fromList(asset.name.codeUnits),
      [_targetEndpointId!],
    );
  }

  void stopAll() {
    _nearby.stopAllEndpoints();
    _nearby.stopDiscovery();

    state = NearbySenderState.none(_userName!);
  }

  /// [_userName] 을 이후에 사용할 수 있도록 적제해놓고, 상태 초기에 부족했던 사용자 이름을
  /// state 에 반영함
  Future<void> _loadUserName() async {
    _userName ??= await _infoFetcher.info;
    state = NearbySenderState.none(_userName!);
  }

  /// 연결 요청을 보낸 기기(=discoverer) 에서 연결 시작 로직
  ///
  /// 연결 요청을 보낸 입장에서 두 번 확인하게 할 필요 없으므로 따로 처리함
  ///
  /// 여기서는 상태를 처리하지 않고 [_onConnectionResult] 에서 상태를 처리함
  Future<void> _onConnectionInitiated(
      String endpointId, ConnectionInfo connectionInfo) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayloadReceived: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  void _onConnectionResult(
    String endpointId,
    ConnectionStatus status,
  ) {
    switch (status) {
      case ConnectionStatus.connected:
        _targetEndpointId = endpointId;
        _nearby.stopDiscovery();
        state = const NearbySenderState.connected();
      case ConnectionStatus.rejected:
        state = const NearbySenderState.rejected();
      case ConnectionStatus.error:
        state = const NearbySenderState.failed('connection error');
    }
  }

  void _onDisconnected(
    String endpointId,
  ) {
    _targetEndpointId = null;
    _asset = null;
    state = NearbySenderState.none(_userName!);
  }

  void _onEndpointFound(
    String endpointId,
    String endpointName,
  ) {
    switch (state) {
      case NearbySenderStateDiscovering(devices: var devices):
        final newDevice = NearbyDevice(id: endpointId, name: endpointName);
        if (!devices.contains(newDevice)) {
          state = NearbySenderState.discovering(_userName!,
              [...devices, NearbyDevice(id: endpointId, name: endpointName)]);
        }
      default:
        break;
    }
  }

  void _onEndpointLost(
    String? endpointId,
  ) {
    switch (state) {
      case NearbySenderStateDiscovering(devices: var devices):
        state = NearbySenderState.discovering(
          _userName!,
          devices.where((element) => element.id != endpointId).toList(),
        );
      default:
        break;
    }
  }

  /// sender은 검증 데이터가 맞는지 확인해야 하므로 receiver 로 부터 응답을 받아서 확인함
  ///
  /// 현재 byte 만 생각하고 코드가 짜여져 있음
  void _onPayloadReceived(String endpointId, Payload payload) {
    final result = json.decode(String.fromCharCodes(payload.bytes!));
    final isSuccess = result['isSuccess'] ?? false;
    if (isSuccess) {
      _assetService.saveAssetBySender(_userName!, _asset!);
      state = const NearbySenderState.success();
    } else {
      state = const NearbySenderState.failed('failed data');
    }
  }

  /// sender은 검증 데이터가 맞는지 확인해야 하므로 receiver 로 부터 응답을 받아서 확인함
  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate payloadTransferUpdate,
  ) {
    switch (payloadTransferUpdate.status) {
      case PayloadStatus.none:
        break;
      case PayloadStatus.inProgress:
        break;
      case PayloadStatus.success:
        break;
      case PayloadStatus.failure:
        state = const NearbySenderState.failed('failed');
      case PayloadStatus.canceled:
        state = const NearbySenderState.failed('canceled');
    }
  }
}

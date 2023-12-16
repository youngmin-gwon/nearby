import 'dart:async';

import 'package:poc/src/nearby/application/bloc/receiver/nearby_receiver_bloc.dart';
import 'package:poc/src/nearby/application/service/nearby.dart';

sealed class NearbyReceiverEvent {
  /// 송신자에게 자신을 찾을 수 있도록 광고하는 이벤트
  const factory NearbyReceiverEvent.advertise([Strategy strategy]) =
      NearbyReceiverEventAdvertise;

  /// 송신자에게 광고를 멈추는 이벤트
  const factory NearbyReceiverEvent.stopAdvertising() =
      NearbyReceiverEventAdvertiseStop;

  /// 송신자가 데이터를 보내려 요청할 때, 승락하는 이벤트
  const factory NearbyReceiverEvent.acceptRequest(String endpointId) =
      NearbyReceiverEventAccept;

  /// 송신자가 데이터를 보내려 요청할 때, 거절하는 이벤트
  const factory NearbyReceiverEvent.rejectRequest(String endpointId) =
      NearbyReceiverEventReject;

  /// 모든 연결을 취소하는 이벤트
  const factory NearbyReceiverEvent.stopAll() = NearbyAdvertiserEventStopAll;

  const NearbyReceiverEvent();

  FutureOr<void> handle(NearbyReceiverBloc bloc);
}

class NearbyReceiverEventAdvertise extends NearbyReceiverEvent {
  const NearbyReceiverEventAdvertise([this.strategy]);

  final Strategy? strategy;

  @override
  FutureOr<void> handle(NearbyReceiverBloc bloc) {
    bloc.advertise(strategy ?? Strategy.pointToPoint);
  }
}

class NearbyReceiverEventAdvertiseStop extends NearbyReceiverEvent {
  const NearbyReceiverEventAdvertiseStop();

  @override
  FutureOr<void> handle(NearbyReceiverBloc bloc) {
    bloc.stopAdvertising();
  }
}

class NearbyReceiverEventAccept extends NearbyReceiverEvent {
  const NearbyReceiverEventAccept(this.endpointId);

  final String endpointId;

  @override
  FutureOr<void> handle(NearbyReceiverBloc bloc) {
    bloc.acceptConnection(endpointId);
  }
}

class NearbyReceiverEventReject extends NearbyReceiverEvent {
  const NearbyReceiverEventReject(this.endpointId);

  final String endpointId;

  @override
  FutureOr<void> handle(NearbyReceiverBloc bloc) {
    bloc.rejectConnection(endpointId);
  }
}

class NearbyAdvertiserEventStopAll extends NearbyReceiverEvent {
  const NearbyAdvertiserEventStopAll();

  @override
  FutureOr<void> handle(NearbyReceiverBloc bloc) {
    bloc.stopAll();
  }
}

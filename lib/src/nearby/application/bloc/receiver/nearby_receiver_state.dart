import 'package:poc/src/nearby/application/service/nearby.dart';

sealed class NearbyReceiverState {
  const NearbyReceiverState();

  const factory NearbyReceiverState.none([String userName]) =
      NearbyReceiverStateNone;
  const factory NearbyReceiverState.advertising(String userName) =
      NearbyReceiverStateAdvertising;
  const factory NearbyReceiverState.responding(
          String endpointId, ConnectionInfo connectionInfo) =
      NearbyReceiverStateResponding;
  const factory NearbyReceiverState.connected() = NearbyReceiverStateConnected;
  const factory NearbyReceiverState.success(String dataName) =
      NearbyReceiverStateSuccess;
  const factory NearbyReceiverState.failed(String message) =
      NearbyReceiverStateFailed;
}

class NearbyReceiverStateNone extends NearbyReceiverState {
  const NearbyReceiverStateNone([this.userName]);

  final String? userName;
}

class NearbyReceiverStateAdvertising extends NearbyReceiverState {
  const NearbyReceiverStateAdvertising(this.userName);

  final String userName;
}

class NearbyReceiverStateResponding extends NearbyReceiverState {
  const NearbyReceiverStateResponding(this.endpointId, this.connectionInfo);

  final String endpointId;
  final ConnectionInfo connectionInfo;
}

class NearbyReceiverStateConnected extends NearbyReceiverState {
  const NearbyReceiverStateConnected();
}

class NearbyReceiverStateSuccess extends NearbyReceiverState {
  const NearbyReceiverStateSuccess(this.dataName);

  final String dataName;
}

class NearbyReceiverStateFailed extends NearbyReceiverState {
  const NearbyReceiverStateFailed(this.message);

  final String message;
}

sealed class NearbySenderState {
  const NearbySenderState();

  const factory NearbySenderState.none([String userName]) =
      NearbySenderStateNone;
  const factory NearbySenderState.discovering(
          String userName, List<NearbyDevice> devices) =
      NearbySenderStateDiscovering;
  const factory NearbySenderState.requesting() = NearbySenderStateRequesting;
  const factory NearbySenderState.rejected() = NearbySenderStateRejected;
  const factory NearbySenderState.connected() = NearbySenderStateConnected;
  const factory NearbySenderState.success() = NearbySenderStateSuccess;
  const factory NearbySenderState.failed(String message) =
      NearbySenderStateFailed;
}

class NearbySenderStateNone extends NearbySenderState {
  const NearbySenderStateNone([this.userName]);

  final String? userName;
}

class NearbySenderStateDiscovering extends NearbySenderState {
  const NearbySenderStateDiscovering(this.userName, this.devices);

  final String userName;
  final List<NearbyDevice> devices;
}

class NearbySenderStateRequesting extends NearbySenderState {
  const NearbySenderStateRequesting();
}

class NearbySenderStateConnected extends NearbySenderState {
  const NearbySenderStateConnected();
}

class NearbySenderStateRejected extends NearbySenderState {
  const NearbySenderStateRejected();
}

class NearbySenderStateSuccess extends NearbySenderState {
  const NearbySenderStateSuccess();
}

class NearbySenderStateFailed extends NearbySenderState {
  const NearbySenderStateFailed(this.message);

  final String message;
}

class NearbyDevice {
  const NearbyDevice({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  bool operator ==(covariant NearbyDevice other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

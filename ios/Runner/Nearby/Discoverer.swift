import Flutter
import NearbyConnections

extension NearbyMethodCallHandler: DiscovererDelegate {
    func discoverer(
        _: Discoverer, didFind endpointId: EndpointID, with context: Data
    ) {
        // An endpoint was found.
        print("onEndpointFound")
        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }
        let args: [String: Any] = [
            "endpointId": endpointId,
            "endpointName": endpointName,
        ]
        methodChannel.invokeMethod("onEndpointFound", arguments: args)
    }

    func discoverer(_: Discoverer, didLose endpointId: EndpointID) {
        // A previously discovered endpoint has gone away.
        print("onEndpointLost")
        let args: [String: Any] = [
            "endpointId": endpointId,
        ]
        methodChannel.invokeMethod("onEndpointLost", arguments: args)
    }
}

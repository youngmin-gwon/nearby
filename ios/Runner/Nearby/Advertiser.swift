import NearbyConnections

extension NearbyMethodCallHandler: AdvertiserDelegate {
    // callback
    func advertiser(
        _: Advertiser, didReceiveConnectionRequestFrom endpointId: EndpointID,
        with context: Data, connectionRequestHandler: @escaping (Bool) -> Void
    ) {
        // Accept or reject any incoming connection requests. The connection will still need to
        // be verified in the connection manager delegate.

        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }

        let endpoint = Endpoint(
            id: endpointId,
            name: endpointName
        )

        self.endpoints.append(endpoint)
        connectionRequestHandler(true)
    }
}

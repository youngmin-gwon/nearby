import NearbyConnections

extension NearbyMethodCallHandler: ConnectionManagerDelegate {
    func connectionManager(
        _: ConnectionManager,
        didReceive verificationCode: String,
        from endpointId: EndpointID,
        verificationHandler: @escaping (Bool) -> Void
    ) {
        guard let index = self.endpoints.firstIndex(where: { $0.id == endpointId }) else {
            return
        }
        let endpoint = self.endpoints.remove(at: index)
        let request = ConnectionRequest(
            endpointId: endpoint.id,
            endpointName: endpoint.name,
            shouldAccept: { accept in
                verificationHandler(accept)
            }
        )
        requests.append(request)

        let args: [String: Any] = [
            "endpointId": endpoint.id,
            "endpointName": endpoint.name,
            "verificationCode": verificationCode,
        ]
        methodChannel.invokeMethod("onConnectionInitiated", arguments: args)
    }

    func connectionManager(
        _: ConnectionManager, didReceive data: Data,
        withID payloadId: PayloadID, from endpointId: EndpointID
    ) {
        // A simple byte payload has been received. This will always include the full data.
        let args: [String: Any] = [
            "endpointId": endpointId,
            "type": "bytes",
            "bytes": data,
            "payloadId": payloadId,
        ]
        methodChannel.invokeMethod("onPayloadReceived", arguments: args)
    }

    func connectionManager(
        _: ConnectionManager, didReceive _: InputStream,
        withID _: PayloadID, from _: EndpointID,
        cancellationToken _: CancellationToken
    ) {
        // We have received a readable stream.
    }

    func connectionManager(
        _: ConnectionManager,
        didStartReceivingResourceWithID payloadId: PayloadID,
        from endpointId: EndpointID,
        at uri: URL,
        withName name: String, cancellationToken _: CancellationToken
    ) {
        // We have started receiving a file. We will receive a separate transfer update
        // event when complete.
        let args: [String: Any] = [
            "endpointId": endpointId,
            "type": "file",
            "uri": uri.absoluteString,
            "name": name,
            "payloadId": payloadId,
        ]
        methodChannel.invokeMethod("onPayloadReceived", arguments: args)
    }

    func connectionManager(
        _: ConnectionManager,
        didReceiveTransferUpdate transferUpdate: TransferUpdate,
        from endpointId: EndpointID, forPayload payloadId: PayloadID
    ) {
        // A success, failure, cancellation or progress update.
        var totalBytes: Int64 = -1
        var bytesTransferred: Int64 = -1

        var status: String
        switch transferUpdate {
        case .success:
            status = "success"
        case .canceled:
            status = "canceled"
        case .failure:
            status = "failure"
        case let .progress(progress):
            status = "inProgress"
            totalBytes = progress.totalUnitCount
            bytesTransferred = progress.completedUnitCount
        }

        let args: [String: Any] = [
            "endpointId": endpointId,
            "payloadId": payloadId,
            "status": status,
            "totalBytes": totalBytes,
            "bytesTransferred": bytesTransferred,
        ]

        methodChannel.invokeMethod("onPayloadTransferUpdate", arguments: args)
    }

    func connectionManager(
        _: ConnectionManager, didChangeTo state: ConnectionState,
        for endpointId: EndpointID
    ) {
        switch state {
        case .connecting:
            // A connection to the remote endpoint is currently being established.
            print("connecting")
        case .connected:
            // We're connected! Can now start sending and receiving data.
            print("onConnectionResult")
            let args: [String: Any] = [
                "endpointId": endpointId,
                "status": "connected",
            ]
            methodChannel.invokeMethod("onConnectionResult", arguments: args)

        case .disconnected: // We've been disconnected from this endpoint. No more data can be sent or received.
            print("onDisconnected")
            let args: [String: Any] = [
                "endpointId": endpointId,
            ]
            methodChannel.invokeMethod("onDisconnected", arguments: args)
        case .rejected:
            // The connection was rejected by one or both sides.
            print("onConnectionResult")
            let args: [String: Any] = [
                "endpointId": endpointId,
                "status": "rejected",
            ]
            methodChannel.invokeMethod("onConnectionResult", arguments: args)
        }
    }
}

import Flutter
import NearbyConnections

class NearbyMethodCallHandler: MethodCallHandler {
    private var connectionManager: ConnectionManager
    private var discoverer: Discoverer
    private var advertiser: Advertiser
    let methodChannel: FlutterMethodChannel

    private let serviceId: String = "com.youngmin.poc"
    private var strategy: Strategy = .pointToPoint

    private var connectedEndpoints: [String] = []
    var endpoints: [Endpoint] = []
    var requests: [ConnectionRequest] = []
    var tokens: [PayloadID: CancellationToken] = [:]

    init(viewController: FlutterViewController) {
        methodChannel = FlutterMethodChannel(
            name: "nearby_connections", binaryMessenger: viewController.binaryMessenger
        )
        connectionManager = ConnectionManager(serviceID: serviceId, strategy: strategy)
        discoverer = Discoverer(connectionManager: connectionManager)
        advertiser = Advertiser(connectionManager: connectionManager)
        discoverer.delegate = self
        advertiser.delegate = self
        connectionManager.delegate = self
    }

    public func setHandler() {
        methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in

            switch call.method {
            case "startAdvertising":
                print("startAdvertising")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let userName = args["userName"] as? String else {
                    result(FlutterInvalidArgumentError("userName"))
                    return
                }
                guard let strategyName = args["strategy"] as? String else {
                    result(FlutterInvalidArgumentError("strategy"))
                    return
                }

                let newStrategy = Strategy.byName(name: strategyName)
                if newStrategy != self.strategy {
                    self.configureConnection(strategy: newStrategy)
                }

                self.advertiser.stopAdvertising()
                self.advertiser.startAdvertising(using: Data(userName.utf8)) { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "START_ADVERTISING_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "startDiscovery":
                print("startDiscovery")
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let strategyName = args["strategy"] as? String else {
                    result(FlutterInvalidArgumentError("strategy"))
                    return
                }
                let newStrategy = Strategy.byName(name: strategyName)
                if newStrategy != self.strategy {
                    self.configureConnection(strategy: newStrategy)
                }

                self.discoverer.stopDiscovery()
                self.discoverer.startDiscovery { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "START_DISCOVERY_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "stopAdvertising":
                print("stopAdvertising")
                self.advertiser.stopAdvertising { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "STOP_ADVERTISING_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "stopDiscovery":
                print("stopDiscovery")
                self.discoverer.stopDiscovery { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "STOP_DISCOVERY_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "stopAllEndpoints":
                print("stopAllEndpoints")

                for endpointId in self.connectedEndpoints {
                    self.connectionManager.disconnect(from: endpointId) { (error: Error?) in
                        if error != nil {
                            result(
                                FlutterError(
                                    code: "DISCONNECT_FROM_ENDPOINT_FAILURE",
                                    message: error?.localizedDescription,
                                    details: nil
                                )
                            )
                        }
                    }
                }
                result(nil)

            case "disconnectFromEndpoint":
                print("disconnectFromEndpoint")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let endpointId = args["endpointId"] as? String else {
                    result(FlutterInvalidArgumentError("endpointId"))
                    return
                }
                self.connectionManager.disconnect(from: endpointId) { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "DISCONNECT_FROM_ENDPOINT_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }

                    self.connectedEndpoints.removeAll { $0 == endpointId }
                    result(nil)
                }

            case "requestConnection":
                print("requestConnection")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let endpointId = args["endpointId"] as? String else {
                    result(FlutterInvalidArgumentError("enpointId"))
                    return
                }

                guard let userName = args["userName"] as? String else {
                    result(FlutterInvalidArgumentError("userName"))
                    return
                }

                self.endpoints.append(Endpoint(id: endpointId, name: userName))
                self.discoverer.requestConnection(
                    to: endpointId,
                    using: userName.data(using: .utf8)!
                ) { (error: Error?) in
                    if error != nil {
                        let index = self.endpoints.firstIndex(where: { $0.id == endpointId })
                        if index != nil {
                            self.endpoints.remove(at: index!)
                        }
                        result(
                            FlutterError(
                                code: "REQUEST_CONNECTION_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "acceptConnection":
                print("acceptConnection")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let endpointId = args["endpointId"] as? String else {
                    result(FlutterInvalidArgumentError("endpointId"))
                    return
                }

                guard let index = self.requests.firstIndex(where: { $0.endpointId == endpointId }) else {
                    result(FlutterInvalidArgumentError("no such endpointId"))
                    return
                }

                let connectionRequest = self.requests.remove(at: index)
                connectionRequest.shouldAccept(true)
                result(nil)

            case "rejectConnection":
                print("rejectConnection")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let endpointId = args["endpointId"] as? String else {
                    result(FlutterInvalidArgumentError("endpointId"))
                    return
                }

                guard let index = self.requests.firstIndex(where: { $0.endpointId == endpointId }) else {
                    result(FlutterInvalidArgumentError("no such endpointId"))
                    return
                }

                let connectionRequest = self.requests.remove(at: index)
                connectionRequest.shouldAccept(false)
                result(nil)

            case "sendBytesPayload":
                print("sendBytesPayload")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let endpointIds = args["endpointIds"] as? [String] else {
                    result(FlutterInvalidArgumentError("endpointIds"))
                    return
                }

                guard let bytes = args["bytes"] as? FlutterStandardTypedData else {
                    result(FlutterInvalidArgumentError("bytes"))
                    return
                }

                let payloadId = Int64(UUID().hashValue)
                var token: CancellationToken? = nil
                token = self.connectionManager.send(
                    bytes.data,
                    to: endpointIds,
                    id: payloadId
                ) { (error: Error?) in
                    if let error = error {
                        result(
                            FlutterError(
                                code: "SEND_BYTES_PAYLOAD_FAILURE",
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                    } else {
                        self.tokens[payloadId] = token
                        result(nil)
                    }
                }

            case "sendFilePayload":
                print("sendFilePayload")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let endpointIds = args["endpointIds"] as? [String] else {
                    result(FlutterInvalidArgumentError("endpointIds"))
                    return
                }

                guard let filePath = args["uri"] as? String else {
                    result(FlutterInvalidArgumentError("uri"))
                    return
                }

                guard let name = args["name"] as? String else {
                    result(FlutterInvalidArgumentError("name"))
                    return
                }

                let url = URL(fileURLWithPath: filePath)
                let payloadId = Int64(UUID().hashValue)

                var token: CancellationToken? = nil
                token = self.connectionManager.sendResource(
                    at: url,
                    withName: name,
                    to: endpointIds,
                    id: payloadId
                ) { (error: Error?) in
                    if let error = error {
                        result(
                            FlutterError(
                                code: "SEND_FILE_PAYLOAD_FAILURE",
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                    } else {
                        self.tokens[payloadId] = token
                        result(nil)
                    }
                }

            case "cancelPayload":
                print("cancelPayload")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError("args"))
                    return
                }

                guard let payloadId = args["payloadId"] as? NSNumber else {
                    result(FlutterInvalidArgumentError("payloadId"))
                    return
                }

                let payload = self.tokens.removeValue(forKey: payloadId.int64Value)
                payload?.cancel { (error: Error?) in
                    if let error = error {
                        result(
                            FlutterError(
                                code: "CANCEL_PAYLOAD",
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                    } else {
                        result(nil)
                    }
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func configureConnection(strategy newStrategy: Strategy) {
        strategy = newStrategy
        connectionManager = ConnectionManager(serviceID: serviceId, strategy: strategy)
        discoverer = Discoverer(connectionManager: connectionManager)
        advertiser = Advertiser(connectionManager: connectionManager)
        discoverer.delegate = self
        advertiser.delegate = self
        connectionManager.delegate = self
    }
}

class FlutterInvalidArgumentError: FlutterError {
    init(_ argument: String) {
        self.argument = argument
    }

    let argument: String

    override var code: String {
        "INVALID_ARGUMENTS_FORMAT: \(argument)"
    }

    override var description: String {
        "The arguments passed to native is not what you promised"
    }
}

extension Strategy {
    static func byName(name: String) -> Strategy {
        switch name {
        case "pointToPoint": return .pointToPoint
        case "cluster": return .cluster
        case "star": return .star
        default: fatalError("unknown name for strategy")
        }
    }
}

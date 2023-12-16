struct Endpoint  {
    let id: String
    let name: String
}

struct ConnectionRequest {
    let endpointId: String
    let endpointName: String
    let shouldAccept: (Bool) -> Void
}

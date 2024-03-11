struct Endpoint : Identifiable {
    let id: String
    let name: String
}

struct ConnectionRequest {
    let endpoint: Endpoint
    let verificationCode: String
    let shouldAccept: (Bool) -> Void
}

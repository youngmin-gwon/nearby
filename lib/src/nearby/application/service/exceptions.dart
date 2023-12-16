final class AlreadyInUseException implements Exception {
  const AlreadyInUseException();
}

class NetworkException implements Exception {
  const NetworkException();
}

class InvalidServerCallException implements Exception {
  const InvalidServerCallException(this.statusCode);

  final int statusCode;
}

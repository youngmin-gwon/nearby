import 'package:poc/src/nearby/domain/entity/asset.dart';

abstract interface class TransactionLocalDatastore {
  Future<void> save(String id, Asset asset);
}

// TODO: 추후에 구현하겠음.
class TransactionLocalDatastoreImpl implements TransactionLocalDatastore {
  @override
  Future<void> save(String id, Asset asset) {
    throw UnimplementedError();
  }
}

/// 테스트 이후 삭제될 것임
class TransactionLocalStorageFakeImpl implements TransactionLocalDatastore {
  @override
  Future<void> save(String id, Asset asset) {
    return Future.value();
  }
}

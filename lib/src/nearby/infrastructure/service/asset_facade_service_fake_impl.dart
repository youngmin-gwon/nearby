import 'dart:math' as math;
import 'package:poc/src/nearby/application/service/asset_facade_service.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';
import 'package:poc/src/nearby/domain/entity/asset.dart';
import 'package:poc/src/nearby/infrastructure/datastore/asset_local_datastore.dart';
import 'package:poc/src/nearby/infrastructure/datastore/asset_remote_datastore.dart';
import 'package:poc/src/nearby/infrastructure/datastore/transaction_local_datastore.dart';

// WARNING: 해당 기능은 의도적으로 Random을 사용하고 있음.
//          이는 서버 API 가 제대로 갖춰져있지 않기 때문에 데모 시연만을 위해 의도된 설계임.
//          이름이 Fake 인것도 그 이유.
final class AssetFacadeServiceFakeImpl implements AssetFacadeService {
  const AssetFacadeServiceFakeImpl(
    this._localAssetDatastore,
    this._remoteAssetDatastore,
    this._localTransactionStorage,
  );

  final AssetLocalDatastore _localAssetDatastore;
  final AssetRemoteDatastore _remoteAssetDatastore;
  final TransactionLocalDatastore _localTransactionStorage;

  static final _random = math.Random();

  @override
  Future<List<Asset>> getLocalAssets() {
    return _localAssetDatastore.getAssets();
  }

  @override
  Future<List<Asset>> getRemoteAssets() async {
    // REF: 이 구현은 class 이름처럼 Faking 하고 있음.
    //
    //      random 을 이용해서 80% 확률로 최신 데이터를 받아왔다고
    //      faking 하고 있는 것을 동작으로 구현하고 있음.
    if (_random.nextDouble() > 0.8) {
      try {
        final assets = await _remoteAssetDatastore.getAssets();
        for (final asset in assets) {
          _localAssetDatastore.save(asset);
        }
        return assets;
      } on NetworkException {
        rethrow;
      } on InvalidServerCallException {
        rethrow;
      }
    }

    return [];
  }

  @override
  Future<void> saveAssetByReceiver(String receiverId, Asset asset) async {
    // step 1: 원격 서버에 데이터 저장
    try {
      await _remoteAssetDatastore.saveReceiver(receiverId, asset);
    } on NetworkException {
      // step 1-1: 만약 에러가 발생한다면 local 에 저장
      _localTransactionStorage.save(receiverId, asset);
    } on InvalidServerCallException {
      // step 1-2: 만약 에러가 발생한다면 local 에 저장
      _localTransactionStorage.save(receiverId, asset);
    }

    // step 2: 로컬에 데이터 저장
    await _localAssetDatastore.save(asset);
  }

  @override
  Future<void> saveAssetBySender(String senderId, Asset asset) async {
    // step 1: 원격 서버에 데이터 저장
    try {
      await _remoteAssetDatastore.saveSender(senderId, asset);
    } on NetworkException {
      // step 1-1: 만약 에러가 발생한다면 local 에 저장
      _localTransactionStorage.save(senderId, asset);
    } on InvalidServerCallException {
      // step 1-2: 만약 에러가 발생한다면 local 에 저장
      _localTransactionStorage.save(senderId, asset);
    }

    // step 2: 로컬에서 Asset 데이터 삭제
    await _localAssetDatastore.delete(asset);
  }
}

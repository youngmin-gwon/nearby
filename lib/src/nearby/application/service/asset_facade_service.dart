import 'package:poc/src/nearby/domain/entity/asset.dart';

/// Asset을 서버나, 로컬 기기에서 불러오는 것을 추상화한 interface
/// REF:
///
/// 각 메소드는 CQRS 를 고려하면 분리하는 것이 좋지만, 현재는 같이 사용되는 경우가 많으니
/// 우선은 같이 넣어둠. 추후 각자의 메소드가 호출되는 타이밍이 완벽히 달라지고, 각자 따로 발전해야
/// 되는 경우가 생기면 분리하는 것이 좋을 것으로 보임.
abstract interface class AssetFacadeService {
  Future<List<Asset>> getLocalAssets();
  Future<List<Asset>> getRemoteAssets();
  Future<void> saveAssetByReceiver(String receiverId, Asset asset);
  Future<void> saveAssetBySender(String senderId, Asset asset);
}

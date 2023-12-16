import 'package:isar/isar.dart';
import 'package:poc/src/nearby/domain/entity/asset.dart';

part 'asset_dao.g.dart';

@collection
class AssetDao {
  AssetDao(this.encryptedData);

  factory AssetDao.fromEncryptedString(String encrypted) {
    return AssetDao(encrypted);
  }

  Id id = Isar.autoIncrement;
  final String encryptedData;

  /// REF: 현재 text 만 고려한 구현임
  /// TODO: 후에 type 이 늘어나면 factory 같은 것 도입해야할 것으로 보임
  Asset toDomain() {
    return TextAsset(id.toString(), encryptedData);
  }
}

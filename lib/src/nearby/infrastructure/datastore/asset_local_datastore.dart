import 'package:isar/isar.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:poc/src/nearby/domain/entity/asset.dart';
import 'package:poc/src/nearby/infrastructure/datastore/asset_dao.dart';

abstract interface class AssetLocalDatastore {
  Future<List<Asset>> getAssets();
  Future<void> save(Asset asset);
  Future<void> delete(Asset asset);
}

final class AssetLocalDatastoreImpl implements AssetLocalDatastore {
  const AssetLocalDatastoreImpl(this._database, this._encrypter, this._iv);

  final Isar _database;
  final encrypt.Encrypter _encrypter;
  final encrypt.IV _iv;

  @override
  Future<List<Asset>> getAssets() async {
    return (await _database.collection<AssetDao>().where().findAll())
        .map(
          // TODO: 현재는 오직 Text만 고려하고 있음. 추후 타입 늘어날시 변경.
          (e) => TextAsset.fromText(
            _encrypter.decrypt64(e.encryptedData, iv: _iv),
          ),
        )
        .toList();
  }

  @override
  Future<void> save(Asset asset) async {
    return _database.writeTxn(
      () async {
        final encrypted = _encrypter.encryptBytes(asset.bytes, iv: _iv);
        await _database
            .collection<AssetDao>()
            .put(AssetDao.fromEncryptedString(encrypted.base64));
      },
    );
  }

  @override
  Future<void> delete(Asset asset) {
    final encrypted = _encrypter.encryptBytes(asset.bytes, iv: _iv);
    return _database.writeTxn(
      () async {
        await _database
            .collection<AssetDao>()
            .filter()
            .encryptedDataEqualTo(encrypted.base64)
            .deleteAll();
      },
    );
  }
}

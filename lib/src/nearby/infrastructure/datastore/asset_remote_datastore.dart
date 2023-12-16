import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:faker/faker.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';
import 'package:poc/src/nearby/domain/entity/asset.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

abstract interface class AssetRemoteDatastore {
  Future<List<Asset>> getAssets();
  Future<void> saveSender(String id, Asset asset);
  Future<void> saveReceiver(String id, Asset asset);
}

final class AssetRemoteDatastoreFakeImpl implements AssetRemoteDatastore {
  const AssetRemoteDatastoreFakeImpl(this._encrypter, this._iv, this._faker);

  final encrypt.Encrypter _encrypter;
  final encrypt.IV _iv;
  final Faker _faker;

  @override
  Future<List<Asset>> getAssets() async {
    final word = _faker.internet.userName();
    final encryptedWord = _encrypter.encrypt(word, iv: _iv);
    final decryptedWord = _encrypter.decrypt(encryptedWord, iv: _iv);
    return [
      TextAsset.fromText(decryptedWord),
    ];
  }

  @override
  Future<void> saveSender(String id, Asset asset) {
    return Future.value();
  }

  @override
  Future<void> saveReceiver(String id, Asset asset) {
    return Future.value();
  }
}

final class AssetRemoteDatastoreImpl implements AssetRemoteDatastore {
  const AssetRemoteDatastoreImpl(
    this._serverUrl,
    this._httpClient,
    this._encrypter,
    this._faker,
  );

  final String _serverUrl;
  final http.Client _httpClient;
  final encrypt.Encrypter _encrypter;
  // 현재 API가 데이터 리스트를 가져오거나 하지 않기 때문에
  // 예시를 만들기 위해 주입한 객체임. 추후에는 필요하지 않음.
  final Faker _faker;

  @override
  Future<List<Asset>> getAssets() async {
    // step 1: 서버에서 데이터 받아오기
    try {
      final word = _faker.internet.userName();
      final response = await _httpClient
          .get(Uri.parse('$_serverUrl/download-test?fileName=$word'));

      if (response.statusCode != 200) {
        throw InvalidServerCallException(response.statusCode);
      }

      // step 2: 데이터 복호화 하기
      final encryptedData = (json.decode(response.body)
          as Map<String, dynamic>)['encryptText'] as String;
      final encryptedIvHexString = encryptedData.split(':')[0];
      final encryptedHexString = encryptedData.split(':')[1];

      final iv = <int>[];
      for (int i = 0; i < encryptedIvHexString.length; i += 2) {
        iv.add(int.parse(encryptedIvHexString.substring(i, i + 2), radix: 16));
      }

      final encryptedValue = <int>[];
      for (int j = 0; j < encryptedHexString.length; j += 2) {
        encryptedValue
            .add(int.parse(encryptedHexString.substring(j, j + 2), radix: 16));
      }

      final decryptedData = _encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(encryptedValue)),
        iv: encrypt.IV(Uint8List.fromList(iv)),
      );

      // step 3: 복호화 데이터 반환
      return [TextAsset.fromText(decryptedData)];
    } on SocketException {
      throw const NetworkException();
    }
  }

  @override
  Future<void> saveSender(String id, Asset asset) {
    return _save(asset);
  }

  @override
  Future<void> saveReceiver(String id, Asset asset) {
    return _save(asset);
  }

  Future<void> _save(Asset asset) async {
    // step 1: 암호화
    final encryptedData = _encrypter.encryptBytes(
      asset.bytes,
      // text 길이가 16 bytes 가 아니라 오류떠서 어쩔수 없이 16 무작위로 사용하고 있음
      // 나중에 포맷이 정해지면 바꾸는 걸로
      iv: encrypt.IV.fromLength(16),
    );

    // step 2: 서버 전송
    final response = await _httpClient.post(
      Uri.parse('$_serverUrl/upload'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'fileName': asset.name,
        'byte': encryptedData.bytes.toList(),
      }),
    );

    // step 3: 결과 확인
    if (response.statusCode != 200) {
      throw InvalidServerCallException(response.statusCode);
    }

    // TODO: 현재 API 에는 body에 받아서 다시 사용해야할만한 데이터가 있지 않은것으로 보임.
    //       추후, body에 파일 이름 등의 정보가 있으면 이를 저장하고 활용하는 방식으로 수정해야
    //       할 것으로 보임.
  }
}

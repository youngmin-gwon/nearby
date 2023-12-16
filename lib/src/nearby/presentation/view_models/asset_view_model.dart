import 'dart:typed_data';

import 'package:poc/src/nearby/domain/entity/asset.dart';

class AssetViewModel {
  AssetViewModel({
    required this.id,
    required this.name,
    required this.bytes,
    required this.isRemote,
  });

  factory AssetViewModel.fromRemoteDomain(Asset domain) {
    return AssetViewModel(
      id: domain.id,
      name: domain.name,
      bytes: domain.bytes,
      isRemote: true,
    );
  }

  factory AssetViewModel.fromLocalDomain(Asset domain) {
    return AssetViewModel(
      id: domain.id,
      name: domain.name,
      bytes: domain.bytes,
      isRemote: false,
    );
  }

  final String id;
  String name;
  Uint8List bytes;
  final bool isRemote;

  // TODO: Text 이외에 더 생기면 factory 형태로 변경
  Asset toDomain() {
    return TextAsset(id, name);
  }

  @override
  bool operator ==(covariant AssetViewModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.bytes == bytes &&
        other.isRemote == isRemote;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ bytes.hashCode ^ isRemote.hashCode;
  }
}

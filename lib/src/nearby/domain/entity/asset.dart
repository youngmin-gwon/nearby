import 'dart:typed_data';

/// TODO: 상속 타입을 알기 위해 Asset Factory 같은 것이 하나 더 필요할 것으로 보임
abstract base class Asset {
  const Asset();

  String get id;
  String get name;
  Uint8List get bytes;

  @override
  bool operator ==(covariant Asset other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

final class TextAsset extends Asset {
  const TextAsset(this._id, this._text);

  factory TextAsset.fromText(String text) => TextAsset((-1).toString(), text);

  final String _id;
  final String _text;

  @override
  String get id => _id;

  /// TextAsset은 [_text] 값으로 사용
  @override
  String get name => _text;

  @override
  Uint8List get bytes => Uint8List.fromList(_text.codeUnits);
}

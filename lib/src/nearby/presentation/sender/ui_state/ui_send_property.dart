import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/bloc/sender/nearby_sender_state.dart';
import 'package:poc/src/nearby/presentation/view_models/asset_view_model.dart';

/// Send 페이지 에서 UI 상태를 관리하는 클래스의 Provider
final uiSendPropertyProvider =
    ChangeNotifierProvider.autoDispose((_) => UiSendProperty());

/// Send Screen 에서 UI 상태를 관리하는 클래스
class UiSendProperty with ChangeNotifier {
  UiSendProperty();

  /// 임시 할당값. 이후 대체될 것
  AssetViewModel? _selectedAsset;
  AssetViewModel? get selectedAsset => _selectedAsset;

  void setData(AssetViewModel? newData) {
    _selectedAsset = newData;
    notifyListeners();
  }

  NearbyDevice? _selectedDevice;
  NearbyDevice? get selectedDevice => _selectedDevice;

  void setDevice(NearbyDevice? newDevice) {
    _selectedDevice = newDevice;
    notifyListeners();
  }

  bool get isReadySubmit {
    return _selectedAsset != null && _selectedDevice != null;
  }
}

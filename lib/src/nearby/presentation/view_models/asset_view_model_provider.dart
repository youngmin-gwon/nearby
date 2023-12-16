import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/nearby/application/service/asset_facade_service.dart';
import 'package:poc/src/nearby/application/service/exceptions.dart';
import 'package:poc/src/nearby/di.dart';
import 'package:poc/src/nearby/presentation/view_models/asset_view_model.dart';

final assetViewModelProvider = AsyncNotifierProvider.autoDispose<
    AssetViewModelProvider, List<AssetViewModel>>(
  () => AssetViewModelProvider(),
);

class AssetViewModelProvider
    extends AutoDisposeAsyncNotifier<List<AssetViewModel>> {
  late final AssetFacadeService _service;

  @override
  FutureOr<List<AssetViewModel>> build() async {
    state = const AsyncValue.loading();
    _service = ref.watch(assetFacadeServiceProvider);
    return (await _service.getLocalAssets())
        .map((domain) => AssetViewModel.fromLocalDomain(domain))
        .toList();
  }

  Future<void> getRemoteAssets() async {
    state = const AsyncValue.loading();
    try {
      final remoteAssets = (await _service.getRemoteAssets())
          .map((domain) => AssetViewModel.fromRemoteDomain(domain))
          .toList();
      state = AsyncValue.data([...state.value!, ...remoteAssets]);
    } on InvalidServerCallException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

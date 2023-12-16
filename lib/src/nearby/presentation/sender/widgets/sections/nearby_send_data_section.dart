import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';
import 'package:poc/src/core/presentation/widgets/common_toast.dart';
import 'package:poc/src/nearby/presentation/sender/ui_state/ui_send_property.dart';
import 'package:poc/src/nearby/presentation/view_models/asset_view_model.dart';
import 'package:poc/src/nearby/presentation/view_models/asset_view_model_provider.dart';

class NearbySendDataSection extends ConsumerWidget {
  const NearbySendDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '보내는 데이터',
          style: context.textTheme.headlineSmall,
        ),
        const Divider(height: 8),
        const Expanded(
          child: NearbyTextAssetsList(),
        ),
        const Divider(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () =>
                  ref.read(assetViewModelProvider.notifier).getRemoteAssets(),
              child: const Text('서버 데이터 업데이트'),
            ),
            TextButton(
              onPressed: ref.watch(uiSendPropertyProvider).selectedAsset != null
                  ? () => ref.read(uiSendPropertyProvider).setData(null)
                  : null,
              child: const Text('선택 취소'),
            ),
          ],
        ),
      ],
    );
  }
}

class NearbyTextAssetsList extends ConsumerStatefulWidget {
  const NearbyTextAssetsList({super.key});

  @override
  ConsumerState<NearbyTextAssetsList> createState() =>
      _NearbyTextAssetsListState();
}

class _NearbyTextAssetsListState extends ConsumerState<NearbyTextAssetsList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _showToastWhenAssetsAreUpdated();

    final state = ref.watch(assetViewModelProvider);

    return state.when(
      data: (assets) {
        if (assets.isNotEmpty) {
          return ListView.separated(
            controller: _scrollController,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              return _AssetItem(
                asset: assets[index],
              );
            },
            itemCount: assets.length,
          );
        } else {
          return const Center(
            child: Text('보낼 데이터가 없습니다.'),
          );
        }
      },
      error: (e, stackTrace) {
        return const Center(
          child: Text(
            '데이터를 불러오는 중 에러가 발생하였습니다.',
          ),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  void _showToastWhenAssetsAreUpdated() {
    ref.listen(
      assetViewModelProvider,
      (previous, current) {
        if (previous == null || current.isLoading || previous.value == null) {
          return;
        }

        if (previous.value?.length == current.value?.length) {
          context.showFlash(
            duration: const Duration(seconds: 2),
            builder: (context, controller) {
              return CommonToast(
                  controller: controller, message: '이미 최신 버전입니다.');
            },
          );
        } else {
          context.showFlash(
            duration: const Duration(seconds: 2),
            builder: (context, controller) {
              return CommonToast(
                  controller: controller, message: '서버로부터 아이템을 업데이트 하였습니다.');
            },
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          });
        }
      },
    );
  }
}

class _AssetItem extends ConsumerWidget {
  const _AssetItem({required this.asset});

  final AssetViewModel asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSelected =
        ref.watch(uiSendPropertyProvider).selectedAsset == asset;
    return GestureDetector(
      onTap: () => ref.read(uiSendPropertyProvider).setData(asset),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.outline,
            width: isSelected ? 4 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: asset.isRemote
              ? context.theme.colorScheme.surfaceTint.withOpacity(.4)
              : context.theme.colorScheme.surfaceVariant.withOpacity(.4),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              asset.name,
              style: context.textTheme.labelLarge?.copyWith(
                fontSize: 20,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Text('from'),
            const SizedBox(width: 4),
            Icon(
              asset.isRemote ? Icons.dns : Icons.phone_android,
            )
          ],
        ),
      ),
    );
  }
}

class SendTypeToggleWidget extends StatefulWidget {
  const SendTypeToggleWidget(
      {super.key, required this.onToggle, this.initialIndex = 0})
      : assert(0 <= initialIndex || initialIndex <= 1);

  final int initialIndex;
  final ValueChanged<int> onToggle;

  @override
  State<SendTypeToggleWidget> createState() => _SendTypeToggleWidgetState();
}

class _SendTypeToggleWidgetState extends State<SendTypeToggleWidget> {
  final icons = [Icons.text_format, Icons.file_present];
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            if (details.localPosition.dx > constraints.maxHeight * 1.3) {
              if (_index == 1) {
                return;
              }
              setState(() {
                _index = 1;
                widget.onToggle.call(_index);
              });
            } else {
              if (_index == 0) {
                return;
              }
              setState(() {
                _index = 0;
                widget.onToggle.call(_index);
              });
            }
          },
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight * 2.5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.theme.colorScheme.onInverseSurface,
                  ),
                  child: Row(
                    children:
                        icons.map((e) => Expanded(child: Icon(e))).toList(),
                  ),
                ),
                AnimatedAlign(
                  alignment: _index == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: constraints.maxHeight,
                    width: constraints.maxHeight * 1.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.theme.colorScheme.primary,
                    ),
                    child: Center(
                        child: Icon(
                      icons[_index],
                      color: Colors.white,
                    )),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:poc/src/core/presentation/extensions/extensions.dart';

/// 전체화면 1/3 크기를 차지하는 Widget
///
/// BottomSheet을 쓸때 공통으로 사용하기 위해 따로 생성
class CommonBottomSheet extends StatelessWidget {
  const CommonBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.sizeOf.height / 2.5,
      child: Material(
        color: context.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 8.0,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

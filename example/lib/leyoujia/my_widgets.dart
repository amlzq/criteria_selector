import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

class MyRadio extends StatelessWidget {
  final bool value;

  const MyRadio({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value) {
      return Icon(Icons.check,
          size: 14, color: Theme.of(context).colorScheme.primary);
    } else {
      return const SizedBox.shrink();
    }
  }
}

class MyCheckbox extends StatelessWidget {
  final bool value;

  const MyCheckbox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final effectiveCheckColor = Theme.of(context).colorScheme.primary;
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? effectiveCheckColor : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(3),
        color: value ? effectiveCheckColor : Colors.transparent,
      ),
      child:
          value ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }
}

class MyActionBar extends StatelessWidget {
  const MyActionBar({
    super.key,
    required this.applyTextVN,
    required this.onResetTap,
    required this.onApplyTap,
  });

  final ValueNotifier<String> applyTextVN;

  final VoidCallback onResetTap;
  final VoidCallback onApplyTap;

  @override
  Widget build(BuildContext context) {
    // final SelectorController? controller = SelectorController.of(context)!;
    return ValueListenableBuilder<String>(
      valueListenable: applyTextVN,
      builder: (context, applyText, _) {
        return SelectorActionBar(
          applyText: applyText,
          onResetTap: onResetTap,
          onApplyTap: onApplyTap,
        );
      },
    );
  }
}

/// 房源列表底部的分页状态提示：加载中 / "没有更多了" + 页码 / 仅页码。
class HouseListFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;
  final String pageInfo;
  final String? noMoreText;
  final String loadingText;

  const HouseListFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
    required this.pageInfo,
    this.noMoreText,
    this.loadingText = '加载中…',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('加载中…'),
            ],
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '${noMoreText ?? '没有更多了'} · $pageInfo',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          pageInfo,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}

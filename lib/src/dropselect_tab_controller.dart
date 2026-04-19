import 'package:flutter/material.dart';

import 'constants.dart';
import 'dropselect_result.dart';
import 'dropselect_tab_data.dart';
import 'selector.dart';
import 'selector_entry.dart';

/// Controller for [DropselectTabBar] and its selector overlay.
///
/// This controller stores per-tab label data ([DropselectTabData]) and manages
/// the overlay visibility. It also forwards selection events through
/// [onChanged], [onApplied], and [onReset].
class DropselectTabController extends ChangeNotifier {
  /// Fired whenever a selector reports a selection change.
  DropselectResultCallback? onChanged;

  /// Fired when a selector is applied.
  DropselectResultCallback? onApplied;

  /// Fired when reset is triggered.
  VoidCallback? onReset;

  /// Per-tab label and result data keyed by tab index.
  final Map<int, DropselectTabData> tabDataMap = {};
  bool _isDisposed = false;

  /// Returns the nearest controller provided by [DropselectTabControllerProvider]
  /// or null if none is found.
  static DropselectTabController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_DropselectTabControllerScope>()
        ?.controller;
  }

  /// Returns the nearest controller provided by [DropselectTabControllerProvider].
  static DropselectTabController of(BuildContext context) {
    final DropselectTabController? controller = maybeOf(context);
    assert(() {
      if (controller == null) {
        throw FlutterError(
          'DropselectTabController.of() was called with a context that does not '
          'contain a DropselectTabControllerProvider widget.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return controller!;
  }

  final OverlayPortalController portalCtrl = OverlayPortalController();
  final layerLink = LayerLink();

  // OverlayEntry? _entry;

  // BuildContext? get barContext => _barContext;
  // BuildContext? _barContext;

  // void attachBarContext(BuildContext context) {
  //   _barContext = context;
  // }

  // void detachBarContext() {
  //   _barContext = null;
  // }

  /// Currently selected tab index.
  int? currentIndex;

  /// Returns the current tab data for [currentIndex].
  DropselectTabData get currentTabData => tabDataMap[currentIndex]!;

  /// The selector previously used for the overlay.
  Selector? previousSelector;

  @override
  void dispose() {
    _isDisposed = true;
    tabDataMap.clear();
    // removeOverlay();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  /// Shows or hides the selector overlay.
  ///
  /// If [index] differs from [currentIndex], the overlay is shown and
  /// [currentIndex] is updated.
  void toggleSelector({int? index}) {
    if (_isDisposed) return;
    if (currentIndex != index || !isSelectorShowing) {
      portalCtrl.show();
      // _animCtrl.forward(from: 0);
    } else {
      portalCtrl.hide();
      // _animCtrl.reverse().then((_) => portalCtrl.hide());
    }
    currentIndex = index;
    notifyListeners();
  }

  bool get isSelectorShowing => portalCtrl.isShowing;

  /// Hides the selector overlay if it is showing.
  void hideSelector() {
    if (_isDisposed) return;
    // removeOverlay();
    if (isSelectorShowing) {
      portalCtrl.hide();
    }
  }

  /// Dispatches a selection change event.
  void handleChange(SelectorEntries selected) {
    if (_isDisposed) return;
    final result =
        DropselectResult(tabData: currentTabData, selected: selected);
    onChanged?.call(result);
  }

  /// Dispatches an apply event and updates the tab result label.
  void handleApply(SelectorEntries selected) {
    if (_isDisposed) return;
    final result =
        DropselectResult(tabData: currentTabData, selected: selected);
    hideSelector();
    onApplied?.call(result);
    final customLabel = result.tabData.labelGetter?.call(result);
    result.tabData.resultLabel =
        customLabel ?? getResultLabel(result.selected.flatten());
    notifyListeners();
  }

  /// Dispatches a reset event.
  void handleReset() {
    if (_isDisposed) return;
    // hideSelector();
    onReset?.call();
  }

  /// Computes a default label for a selection.
  String? getResultLabel(List<SelectorEntries>? flattenData) {
    String? resultLabel;
    if (flattenData == null) {
      return resultLabel;
    }
    for (var data in flattenData) {
      if (data.length > 1) {
        resultLabel = '多选';
        break;
      }
    }
    if (resultLabel == null) {
      for (var i = flattenData.length - 1; i >= 0; i--) {
        var item = flattenData[i].first;
        if ((item is SelectorChildEntry && item.isAny) ||
            item is SelectorCategoryEntry) {
          continue;
        } else {
          resultLabel = item.name;
          break;
        }
      }
    }
    return resultLabel;
  }
}

class _DropselectTabControllerScope extends InheritedWidget {
  final DropselectTabController? controller;

  const _DropselectTabControllerScope({
    this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _DropselectTabControllerScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Provides a [DropselectTabController] to descendants.
class DropselectTabControllerProvider extends StatelessWidget {
  final DropselectTabController? controller;
  final Widget child;

  const DropselectTabControllerProvider({
    super.key,
    this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _DropselectTabControllerScope(controller: controller, child: child);
  }
}

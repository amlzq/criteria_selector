import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';

/// Controller for a single [Selector] instance.
///
/// This controller exposes the selector configuration and forwards user actions
/// (change/apply/reset) to the callbacks provided by the owner widget.
class SelectorController extends ChangeNotifier {
  final Selector selector;

  final SelectorCallback? changeCallback;
  final SelectorCallback? applyCallback;
  final VoidCallback? resetCallback;

  SelectorController({
    required this.selector,
    this.changeCallback,
    this.applyCallback,
    this.resetCallback,
  });

  /// Selector selection mode; controls how category (level-1) entries are selected
  SelectionMode get selectionMode => selector.selectionMode;

  /// Previous selection
  SelectorEntries? get previousSelected => selector.selectedData;

  /// Reset selection
  SelectorEntries? get resetSelected => selector.resetData;

  /// Notifies listeners that the selection changed.
  void change(SelectorEntries selected) {
    changeCallback?.call(selected);
  }

  /// Notifies listeners that the selection was applied.
  void apply(SelectorEntries selected) {
    applyCallback?.call(selected);
  }

  /// Notifies listeners that reset was requested.
  void reset() {
    resetCallback?.call();
  }

  // void discard() {
  //   selecteSubdistricts?.clear();
  //   previousSubdistrict = null;
  //   selectedDistricts?.clear();
  //   previousDistrict = null;
  //   selectedCities?.clear();
  //   previousCity = null;
  // }

  @override
  void dispose() {
    super.dispose();
  }

  static SelectorController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSelectorControllerScope>()
        ?.controller;
  }
}

class _InheritedSelectorControllerScope extends InheritedWidget {
  final SelectorController controller;

  const _InheritedSelectorControllerScope(
      {required super.child, required this.controller});

  @override
  bool updateShouldNotify(
      covariant _InheritedSelectorControllerScope oldWidget) {
    return oldWidget.controller != controller;
  }
}

class SelectorControllerProvider extends StatelessWidget {
  final SelectorController controller;
  final Widget child;

  /// Provides a [SelectorController] to descendants.
  const SelectorControllerProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _InheritedSelectorControllerScope(
      controller: controller,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// Declares whether the reset/apply action bar should be hidden for the
/// selector widgets in [child]'s subtree.
///
/// [SelectorBox] wraps its panel with [hidden] set to `true` so that inline
/// selectors omit the action bar; modal hosts (dialogs and bottom sheets) do
/// not provide this widget, so the action bar remains visible there.
///
/// This keeps the action bar's "render or not" decision out of the delegate
/// (whose [SelectorDelegate.actionBarBuilder] only customizes the bar's UI),
/// avoiding a per-subclass wrapping delegate.
class SelectorActionBarVisibility extends InheritedWidget {
  const SelectorActionBarVisibility({
    super.key,
    this.hidden = false,
    required super.child,
  });

  /// Whether the action bar should be hidden for selectors in this subtree.
  final bool hidden;

  /// Whether the action bar is hidden for selectors at [context].
  ///
  /// Defaults to `false` (visible) when no [SelectorActionBarVisibility] is
  /// found above [context], so modal hosts that do not wrap their panel keep
  /// showing the action bar.
  static bool isHidden(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SelectorActionBarVisibility>();
    return scope?.hidden ?? false;
  }

  @override
  bool updateShouldNotify(SelectorActionBarVisibility oldWidget) =>
      hidden != oldWidget.hidden;
}

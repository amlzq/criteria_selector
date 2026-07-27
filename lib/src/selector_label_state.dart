/// Tab-agnostic label / selection state shared by [DropdownSelectorBar]
/// (via [DropdownTabData]) and [DropdownSelectorButton].
///
/// It carries only what both a single-trigger button and a multi-tab bar need:
/// an original (default) label, the currently displayed label, and whether a
/// result has been applied. Tab identity ([DropdownTabData.index] /
/// [DropdownTabData.tag]) lives exclusively in [DropdownTabData].
class SelectorLabelState {
  /// The default label shown before any result is applied.
  String? originalLabel;

  /// The label produced by the last applied result, if any.
  String? resultLabel;

  SelectorLabelState({this.originalLabel});

  /// The currently displayed label: the result label when one has been applied,
  /// otherwise the original label.
  String? get label => resultLabel ?? originalLabel;

  /// Whether the displayed label differs from the original (i.e. a result is active).
  bool get isResulted => originalLabel != label;

  @override
  String toString() =>
      'SelectorLabelState(originalLabel: $originalLabel, resultLabel: $resultLabel)';
}

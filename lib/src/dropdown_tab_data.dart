import 'selector/constants.dart';

/// Aggregates tab label data for easy passing between widgets.
class DropdownTabData {
  /// Tab index in the [DropdownSelectorBar].
  final int index;

  /// Original label provided by the tab (before any result is applied).
  String? originalLabel;

  /// Optional tag for identifying the tab.
  final String? tag;

  /// Optional custom label builder based on the current selection result.
  final DropdownTabLabelGetter? labelGetter;

  /// Applied result label, if any.
  String? resultLabel;

  DropdownTabData({
    required this.index,
    this.originalLabel,
    this.tag,
    this.labelGetter,
  });

  /// Effective label shown in the tab.
  String? get label => resultLabel ?? originalLabel;

  /// Whether there is a selector result
  bool get isResulted => originalLabel != label;

  @override
  String toString() =>
      'DropdownTabData(index: $index, originalLabel: $originalLabel)';
}

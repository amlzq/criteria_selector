import 'selector_label_state.dart';

/// Tab label data for [DropdownSelectorBar].
///
/// Extends [SelectorLabelState] (which carries the label / result state shared
/// with [DropdownSelectorButton]) by adding the tab identity ([index] / [tag]).
/// A standalone [DropdownSelectorButton] never creates a [DropdownTabData]; it
/// uses [SelectorLabelState] directly.
class DropdownTabData extends SelectorLabelState {
  /// Tab index in the [DropdownSelectorBar].
  final int index;

  /// Optional tag for identifying the tab.
  final String? tag;

  DropdownTabData({
    required this.index,
    super.originalLabel,
    this.tag,
    super.labelLoader,
  });

  @override
  String toString() =>
      'DropdownTabData(index: $index, originalLabel: $originalLabel)';
}

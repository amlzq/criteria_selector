import 'selector/constants.dart';
import 'selector/selector_entry.dart';
import 'selector_label_state.dart';

/// Tab label data for [DropdownSelectorBar].
///
/// Extends [SelectorLabelState] (which carries the label / result state shared
/// with [DropdownSelectorButton]) by adding the tab identity ([index] / [tag])
/// and an optional label loader. A standalone [DropdownSelectorButton] never
/// creates a [DropdownTabData]; it uses [SelectorLabelState] directly.
class DropdownTabData extends SelectorLabelState {
  /// Tab index in the [DropdownSelectorBar].
  final int index;

  /// Optional tag for identifying the tab.
  final String? tag;

  /// Optional custom label loader based on the current selection result.
  ///
  /// Use the canonical [SelectorLabelLoader] form, which receives only the
  /// selected entries.
  final SelectorLabelLoader? labelLoader;

  /// @Deprecated('Use [labelLoader]. This legacy loader additionally received '
  /// 'tab metadata; pass it to [labelLoader] via fromTabLabelGetter, or set it '
  /// 'here directly to keep receiving the live [DropdownTabData]. Will be '
  /// 'removed in a future major version.')
  final DropdownTabLabelGetter? legacyLabelGetter;

  /// The effective label loader applied to the current selection.
  ///
  /// Prefers [labelLoader]; falls back to [legacyLabelGetter], forwarding the
  /// live [DropdownTabData] as the tab metadata so legacy getters keep working.
  SelectorLabelLoader? get labelGetter =>
      labelLoader ??
      (legacyLabelGetter == null
          ? null
          : (SelectorEntries selected) => legacyLabelGetter!(this, selected));

  DropdownTabData({
    required this.index,
    super.originalLabel,
    this.tag,
    this.labelLoader,
    this.legacyLabelGetter,
  });

  @override
  String toString() =>
      'DropdownTabData(index: $index, originalLabel: $originalLabel)';
}

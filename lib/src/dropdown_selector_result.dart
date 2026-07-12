import 'selector/constants.dart';
import 'dropdown_tab_data.dart';
import 'selector/selector_entry.dart';
import 'selector/selector_utils.dart';

/// Selection result for a single tab in [DropdownSelectorBar].
///
/// This object bundles the tab metadata ([tabData]) and the selected entries
/// ([selected]) for callback consumption.
class DropdownSelectorResult {
  /// Selector
  final DropdownTabData tabData;

  /// Result value
  final SelectorEntries selected;

  const DropdownSelectorResult({required this.tabData, required this.selected});

  /// Convenience access to [DropdownTabData.index].
  get tabIndex => tabData.index;

  /// Convenience access to [DropdownTabData.tag].
  get tabTag => tabData.tag;

  /// Finds children at the given tree [level] under [entry].
  SelectorEntries findChildrenAtLevel(SelectorEntry entry, int level) =>
      SelectorUtils.findChildrenAtLevel(entry, level);

  /// Finds selected ids at the given tree [level] under [entry].
  Set<String> findIdsAtLevel(SelectorEntry entry, int level) =>
      SelectorUtils.findIdsAtLevel(entry, level);

  /// Finds extra payload values at the given tree [level] under [entry].
  List<E> findExtrasAtLevel<E>(SelectorEntry entry, int level) =>
      SelectorUtils.findExtrasAtLevel<E>(entry, level);

  @override
  String toString() =>
      'DropdownSelectorResult(tabData: $tabData, selected: ${selected.flatten()})';
}

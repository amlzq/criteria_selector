import 'constants.dart';
import 'dropselect_tab_data.dart';
import 'selector_entry.dart';
import 'selector_utils.dart';

/// Selection result for a single tab in [DropselectTabBar].
///
/// This object bundles the tab metadata ([tabData]) and the selected entries
/// ([selected]) for callback consumption.
class DropselectResult {
  /// Selector
  final DropselectTabData tabData;

  /// Result value
  final SelectorEntries selected;

  const DropselectResult({required this.tabData, required this.selected});

  /// Convenience access to [DropselectTabData.index].
  get tabIndex => tabData.index;

  /// Convenience access to [DropselectTabData.tag].
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
      'DropselectResult(tabData: $tabData, selected: ${selected.flatten()})';
}

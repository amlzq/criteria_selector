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

  /// Finds children at the given tree [level] under [option].
  SelectorEntries findChildrenAtLevel(SelectorEntry option, int level) =>
      SelectorUtils.findChildrenAtLevel(option, level);

  /// Finds selected ids at the given tree [level] under [option].
  Set<String> findIdsAtLevel(SelectorEntry option, int level) =>
      SelectorUtils.findIdsAtLevel(option, level);

  /// Finds extra payload values at the given tree [level] under [option].
  List<E> findExtrasAtLevel<E>(SelectorEntry option, int level) =>
      SelectorUtils.findExtrasAtLevel<E>(option, level);

  @override
  String toString() =>
      'DropselectResult(tabData: $tabData, selected: ${selected.flatten()})';
}

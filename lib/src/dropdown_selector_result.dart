import 'dropdown_tab_data.dart';
import 'selector/constants.dart';
import 'selector/selector_entry.dart';
import 'selector/selector_utils.dart';

/// Selection result for a single tab in [DropdownSelectorBar].
///
/// This object bundles the tab metadata ([tabData]) and the selected entries
/// ([selected]) for callback consumption.
///
/// @Deprecated('Callbacks now receive the tab metadata and the selected entries
/// directly as `(tabData, selected)` (see [DropdownSelectorResultCallback] and
/// [DropdownTabLabelGetter]). Construct a [DropdownSelectorResult] only to keep
/// an existing legacy `void Function(DropdownSelectorResult)` callback working;
/// this class will be removed in a future major version.')
@Deprecated(
    'Callbacks now receive (tabData, selected) directly; construct this only for legacy callbacks. '
    'It will be removed in a future major version.')
class DropdownSelectorResult {
  const DropdownSelectorResult({required this.tabData, required this.selected});

  /// Selector
  final DropdownTabData tabData;

  /// Result value
  final SelectorEntries selected;

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

  /// Finds the first selected top-level entry (category) whose [id] matches
  /// [categoryId], or `null` if no such category is selected.
  ///
  /// Delegates to `SelectorEntriesExtension.findCategory`, so the same query
  /// is available on a bare `SelectorEntries` (e.g. the return value of
  /// `showSelector` / `showModalBottomSelector`).
  SelectorEntry? findCategory(String categoryId) =>
      selected.findCategory(categoryId);

  /// Returns the ids of all direct children of the category with [categoryId].
  ///
  /// Returns an empty list when the category is not selected or has no
  /// children. Delegates to `SelectorEntriesExtension.childIdsOf`.
  List<String> childIdsOf(String categoryId) => selected.childIdsOf(categoryId);

  /// Returns all direct children of the category with [categoryId] that are
  /// [SelectorRangeEntry] values (e.g. price/area ranges carrying `min`/`max`).
  ///
  /// Returns an empty list when the category is not selected or has no range
  /// children. Delegates to `SelectorEntriesExtension.childRangesOf`.
  List<SelectorRangeEntry> childRangesOf(String categoryId) =>
      selected.childRangesOf(categoryId);

  /// Returns parent → child-id pairs for a cascading category
  /// (e.g. region/metro with districts and sub-districts).
  ///
  /// Each record carries the parent's [id] and a [childIds] list of the ids of
  /// its direct children. Returns an empty list when the category is not
  /// selected or has no children. Delegates to
  /// `SelectorEntriesExtension.cascadingPairsOf`.
  List<({String id, List<String> childIds})> cascadingPairsOf(
          String categoryId) =>
      selected.cascadingPairsOf(categoryId);

  /// Returns the id of the first selected entry, or `null` when nothing is
  /// selected. Convenience accessor for single-selection tabs such as sort
  /// order. Delegates to `SelectorEntriesExtension.firstSelectedId`.
  String? get firstSelectedId => selected.firstSelectedId;

  @override
  String toString() =>
      'DropdownSelectorResult(tabData: $tabData, selected: ${selected.flatten()})';
}

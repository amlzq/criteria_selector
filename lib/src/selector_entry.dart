import 'constants.dart';

/// Special entry id representing the "Any" option.
const kAnyEntryId = 'any';

/// Special entry id representing a user-provided/custom value.
const kCustomEntryId = 'custom';

/// Convenience alias for an integer range entry.
typedef SelectorIntEntry<E> = SelectorRangeEntry<int, E>;

// typedef SelectorDoubleOption<E> = SelectorRangeEntry<double, E>;

// typedef SelectorDateTimeOption<E> = SelectorRangeEntry<DateTime, E>;

/// A range-based entry (e.g. min/max).
///
/// This is commonly used for numeric ranges such as price or area.
class SelectorRangeEntry<N, E> extends SelectorChildEntry<E> {
  N? min;
  N? max;
  final String? inputLabel;
  final String? minHintText;
  final String? maxHintText;

  SelectorRangeEntry({
    this.min,
    this.max,
    this.inputLabel,
    this.minHintText,
    this.maxHintText,
    required super.parentId,
    required super.id,
    required super.name,
    super.children,
    super.enabled,
    super.immediate,
    super.extra,
  });

  /// Custom range entry
  /// This entry is usually rendered as an input field or a slider/progress bar in the UI.
  SelectorRangeEntry.custom({
    this.min,
    this.max,
    this.inputLabel,
    this.minHintText,
    this.maxHintText,
    required super.parentId,
    super.name,
    super.enabled,
    super.immediate,
  }) : super(
          id: kCustomEntryId,
        );

  /// "Any" entry
  SelectorRangeEntry.any({
    this.min,
    this.max,
    this.inputLabel,
    this.minHintText,
    this.maxHintText,
    required super.parentId,
    required super.name,
    super.enabled,
    super.immediate,
  }) : super.any();
}

extension SelectorRangeEntryExt on SelectorRangeEntry {
  /// Whether this entry represents a custom value input.
  bool get isCustom => id == kCustomEntryId;

  /// Whether the entry has any user-provided value.
  bool get hasCustomValue =>
      (min != null && min.toString().isNotEmpty) ||
      (max != null && max.toString().isNotEmpty);
}

/// A plain text entry.
class SelectorTextEntry<E> extends SelectorChildEntry<E> {
  SelectorTextEntry({
    required super.parentId,
    required super.id,
    required super.name,
    super.children,
    super.enabled,
    super.immediate,
  });

  SelectorTextEntry.id({required super.id}) : super(parentId: '', name: '');

  /// Creates a leaf entry without a parent id.
  SelectorTextEntry.name({
    required super.id,
    required super.name,
    super.enabled,
    super.immediate,
  }) : super(parentId: '');

  /// "Any" entry
  SelectorTextEntry.any({
    required super.parentId,
    required super.name,
    super.enabled,
    super.immediate,
  }) : super.any();
}

/// A child entry (i.e. a non-root node).
class SelectorChildEntry<E> extends SelectorEntry<E> {
  final String parentId;

  SelectorChildEntry({
    required this.parentId,
    required super.id,
    super.name,
    super.children,
    super.enabled,
    super.immediate,
    super.extra,
  });

  /// "Any" entry
  SelectorChildEntry.any({
    required this.parentId,
    required super.name,
    super.enabled,
    super.immediate,
    super.extra,
  }) : super(
          id: kAnyEntryId,
        );

  SelectorChildEntry.empty({this.parentId = ''})
      : super(
          id: '',
          name: null,
          children: null,
          enabled: true,
          immediate: false,
          extra: null,
        );
}

extension SelectorChildEntryExt on SelectorChildEntry {
  /// Whether this entry is the special "Any" entry.
  bool get isAny => id == kAnyEntryId;

  /// Whether this entry is a placeholder with an empty id.
  bool get isEmpty => id.isEmpty;

  /// Whether this entry has a non-empty id.
  bool get isNotEmpty => id.isNotEmpty;
}

/// A category entry (i.e. a root node).
class SelectorCategoryEntry<E> extends SelectorEntry<E> {
  /// Selection mode for child nodes
  final SelectionMode selectionMode;

  SelectorEntry<E>? header;
  final SelectionMode headerSelectionMode;

  SelectorEntry<E>? footer;
  final SelectionMode footerSelectionMode;

  SelectorCategoryEntry({
    this.selectionMode = SelectionMode.single,
    this.header,
    this.headerSelectionMode = SelectionMode.single,
    this.footer,
    this.footerSelectionMode = SelectionMode.single,
    required super.id,
    required super.name,
    required super.children,
    super.enabled,
    super.immediate,
  });
}

extension SelectorCategoryEntryExtension on SelectorCategoryEntry {
  /// Returns the first child if it is a custom range entry.
  SelectorRangeEntry? get firstCustomOrNull {
    final element = firstChild;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }

  /// Returns the last child if it is a custom range entry.
  SelectorRangeEntry? get lastCustomOrNull {
    final element = lastChild;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }
}

/// Base class for all selector entries.
///
/// Entries form a tree: [SelectorCategoryEntry] is typically the root and
/// [SelectorChildEntry] represents non-root nodes.
abstract class SelectorEntry<E> {
  final String id;
  final String? name;

  final Set<SelectorEntry<E>>? children;

  final bool enabled;

  /// If true, selecting this node will immediately apply the entry without needing to click the "Apply" button.
  /// Default value is false; if the node's id is [kAnyEntryId] and the node's data is empty, then immediate value is true.
  /// In single-selection mode, this value is ignored and applied immediately.
  final bool immediate;

  final E? extra;

  SelectorEntry({
    required this.id,
    this.name,
    this.children,
    this.enabled = true,
    this.immediate = false,
    this.extra,
  });

  // SelectorEntry copyWith({
  //   String? id,
  //   String? name,
  //   List<SelectorEntry>? data,
  // }) {
  //   return SelectorEntry(
  //     id: id ?? this.id,
  //     name: name ?? this.name,
  //     data: data ?? this.data,
  //   );
  // }

  @override
  String toString() => 'SelectorEntry(id: $id, name: $name)';
}

// mixin SelectorEntryMixin {
//   bool selected = false;
// }

extension SelectorEntryExt on SelectorEntry {
  /// Returns the first child entry if present.
  SelectorEntry? get firstChild => children?.first;

  /// Returns the last child entry if present.
  SelectorEntry? get lastChild => children?.last;

  /// Whether this entry has any children.
  bool get hasChildren => children?.isNotEmpty ?? false;

  // bool get selected => data?.any((e) => e.selected) ?? false;

  /// Depth of the tree structure.
  int get maxLevel {
    // If there are no children, this is a leaf node and the depth is 1.
    if (children == null || children!.isEmpty) {
      return 1;
    }

    // Child max depth + 1 is the current node depth.
    int childMaxLevel = 0;

    for (var c in children!) {
      childMaxLevel = childMaxLevel > c.maxLevel ? childMaxLevel : c.maxLevel;
    }
    return childMaxLevel + 1;
  }
}

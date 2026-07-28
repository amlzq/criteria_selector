import '../deprecated.dart';
import 'children_layout.dart';
import 'constants.dart';

/// A set of selected [SelectorEntry] values.
typedef SelectorEntries<T> = Set<SelectorEntry<T>>;

/// Special entry id representing the "Any" entry.
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

  /// The minimum value of the range.
  N? min;

  /// The maximum value of the range.
  N? max;

  /// An optional label for the input field(s) representing this range.
  final String? inputLabel;

  /// Hint text shown for the minimum value input field.
  final String? minHintText;

  /// Hint text shown for the maximum value input field.
  final String? maxHintText;

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

  @override
  SelectorRangeEntry<N, E> copyWith({
    String? parentId,
    String? id,
    String? name,
    Set<SelectorEntry<E>>? children,
    bool? enabled,
    bool? immediate,
    E? extra,
    N? min,
    N? max,
    String? inputLabel,
    String? minHintText,
    String? maxHintText,
  }) {
    return SelectorRangeEntry<N, E>(
      parentId: parentId ?? this.parentId,
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      enabled: enabled ?? this.enabled,
      immediate: immediate ?? this.immediate,
      extra: extra ?? this.extra,
      min: min ?? this.min,
      max: max ?? this.max,
      inputLabel: inputLabel ?? this.inputLabel,
      minHintText: minHintText ?? this.minHintText,
      maxHintText: maxHintText ?? this.maxHintText,
    );
  }

  @override
  String toString() =>
      'SelectorRangeEntry(id: $id, parentId: $parentId, name: $name, min: $min, max: $max)';
}

extension SelectorRangeEntryExt on SelectorRangeEntry {
  /// Whether this entry represents a custom value input.
  bool get isCustom => id == kCustomEntryId;

  /// Whether the entry has any user-provided value.
  bool get hasCustomValue =>
      (min != null && min.toString().isNotEmpty) ||
      (max != null && max.toString().isNotEmpty);

  String get name => this.name ?? '$min-$max';
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

  @override
  String toString() =>
      'SelectorTextEntry(id: $id, parentId: $parentId, name: $name)';
}

/// A child entry (i.e. a non-root node).
class SelectorChildEntry<E> extends SelectorEntry<E> {
  SelectorChildEntry({
    required this.parentId,
    required super.id,
    super.name,
    super.children,
    super.enabled,
    super.immediate,
    super.extra,
  });

  /// The id of this entry's parent category.
  final String parentId;

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

  SelectorChildEntry<E> copyWith({
    String? parentId,
    String? id,
    String? name,
    Set<SelectorEntry<E>>? children,
    bool? enabled,
    bool? immediate,
    E? extra,
  }) {
    return SelectorChildEntry<E>(
      parentId: parentId ?? this.parentId,
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      enabled: enabled ?? this.enabled,
      immediate: immediate ?? this.immediate,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SelectorChildEntry<E> &&
            runtimeType == other.runtimeType &&
            other.id == id &&
            other.parentId == parentId &&
            other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, parentId, name);

  @override
  String toString() =>
      'SelectorChildEntry(id: $id, parentId: $parentId, name: $name)';
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
  SelectorCategoryEntry({
    this.selectionMode = SelectionMode.single,
    this.header,
    this.headerSelectionMode = SelectionMode.single,
    this.footer,
    this.footerSelectionMode = SelectionMode.single,
    SelectorChildrenLayout? childrenLayout,
    @Deprecated(
      'Use childrenLayout instead. When set, it is mapped to a '
      'SelectorListLayout. It will be removed in a future major version.',
    )
    SelectorListConfig? listConfig,
    @Deprecated(
      'Use childrenLayout instead. When set, it is mapped to a '
      'SelectorGridLayout. It will be removed in a future major version.',
    )
    SelectorGridConfig? gridConfig,
    @Deprecated(
      'Use childrenLayout instead. When set, it is mapped to a '
      'SelectorChipLayout. It will be removed in a future major version.',
    )
    SelectorChipConfig? chipConfig,
    required super.id,
    required super.name,
    required super.children,
    super.enabled,
    super.immediate,
  })  : assert(
          childrenLayout == null ||
              (listConfig == null && gridConfig == null && chipConfig == null),
          'Provide either childrenLayout or one of the deprecated '
          'listConfig/gridConfig/chipConfig, but not both.',
        ),
        childrenLayout = childrenLayout ??
            (listConfig != null
                ? const SelectorListLayout()
                : gridConfig != null
                    ? SelectorGridLayout(
                        crossAxisCount: gridConfig.crossAxisCount,
                        mainAxisSpacing: gridConfig.mainAxisSpacing,
                        crossAxisSpacing: gridConfig.crossAxisSpacing,
                        childAspectRatio: gridConfig.childAspectRatio,
                      )
                    : chipConfig != null
                        ? const SelectorChipLayout()
                        : null);

  /// The selection mode applied to this category's children.
  ///
  /// Defaults to [SelectionMode.single].
  final SelectionMode selectionMode;

  /// An optional header entry rendered above this category's children.
  SelectorEntry<E>? header;

  /// The selection mode applied to [header].
  ///
  /// Defaults to [SelectionMode.single].
  final SelectionMode headerSelectionMode;

  /// An optional footer entry rendered below this category's children.
  SelectorEntry<E>? footer;

  /// The selection mode applied to [footer].
  ///
  /// Defaults to [SelectionMode.single].
  final SelectionMode footerSelectionMode;

  /// The layout used to render this category's children.
  ///
  /// When `null`, a default [SelectorListLayout] is used at render time.
  final SelectorChildrenLayout? childrenLayout;

  /// Use [childrenLayout] instead.
  @Deprecated(
    'Use childrenLayout instead. Returns a SelectorListConfig when '
    'childrenLayout is a SelectorListLayout. It will be removed in a future '
    'major version.',
  )
  SelectorListConfig? get listConfig =>
      childrenLayout is SelectorListLayout ? const SelectorListConfig() : null;

  /// Use [childrenLayout] instead.
  @Deprecated(
    'Use childrenLayout instead. Returns a SelectorGridConfig mirroring the '
    'current SelectorGridLayout. It will be removed in a future major version.',
  )
  SelectorGridConfig? get gridConfig {
    final layout = childrenLayout;
    return layout is SelectorGridLayout
        ? SelectorGridConfig(
            crossAxisCount: layout.crossAxisCount,
            mainAxisSpacing: layout.mainAxisSpacing,
            crossAxisSpacing: layout.crossAxisSpacing,
            childAspectRatio: layout.childAspectRatio,
          )
        : null;
  }

  /// Use [childrenLayout] instead.
  @Deprecated(
    'Use childrenLayout instead. Returns a SelectorChipConfig when '
    'childrenLayout is a SelectorChipLayout. It will be removed in a future '
    'major version.',
  )
  SelectorChipConfig? get chipConfig =>
      childrenLayout is SelectorChipLayout ? const SelectorChipConfig() : null;

  SelectorCategoryEntry<E> copyWith({
    String? id,
    String? name,
    Set<SelectorEntry<E>>? children,
    bool? enabled,
    bool? immediate,
    SelectionMode? selectionMode,
    SelectorEntry<E>? header,
    SelectionMode? headerSelectionMode,
    SelectorEntry<E>? footer,
    SelectionMode? footerSelectionMode,
    SelectorChildrenLayout? childrenLayout,
    @Deprecated(
      'Use childrenLayout instead. When set, it is mapped to a '
      'SelectorListLayout. It will be removed in a future major version.',
    )
    SelectorListConfig? listConfig,
    @Deprecated(
      'Use childrenLayout instead. When set, it is mapped to a '
      'SelectorGridLayout. It will be removed in a future major version.',
    )
    SelectorGridConfig? gridConfig,
    @Deprecated(
      'Use childrenLayout instead. When set, it is mapped to a '
      'SelectorChipLayout. It will be removed in a future major version.',
    )
    SelectorChipConfig? chipConfig,
  }) {
    final SelectorChildrenLayout? resolvedLayout = childrenLayout ??
        (listConfig != null
            ? const SelectorListLayout()
            : gridConfig != null
                ? SelectorGridLayout(
                    crossAxisCount: gridConfig.crossAxisCount,
                    mainAxisSpacing: gridConfig.mainAxisSpacing,
                    crossAxisSpacing: gridConfig.crossAxisSpacing,
                    childAspectRatio: gridConfig.childAspectRatio,
                  )
                : chipConfig != null
                    ? const SelectorChipLayout()
                    : this.childrenLayout);
    return SelectorCategoryEntry<E>(
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      enabled: enabled ?? this.enabled,
      immediate: immediate ?? this.immediate,
      selectionMode: selectionMode ?? this.selectionMode,
      header: header ?? this.header,
      headerSelectionMode: headerSelectionMode ?? this.headerSelectionMode,
      footer: footer ?? this.footer,
      footerSelectionMode: footerSelectionMode ?? this.footerSelectionMode,
      childrenLayout: resolvedLayout,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SelectorCategoryEntry<E> &&
            runtimeType == other.runtimeType &&
            other.id == id &&
            other.name == name &&
            other.selectionMode == selectionMode &&
            other.childrenLayout == childrenLayout;
  }

  @override
  int get hashCode => Object.hash(id, name, selectionMode, childrenLayout);

  @override
  String toString() =>
      'SelectorCategoryEntry(id: $id, name: $name, selectionMode: $selectionMode, header: $header, footer: $footer, childrenLayout: $childrenLayout)';
}

extension SelectorCategoryEntryExtension on SelectorCategoryEntry {
  bool get hasCustomOrNull =>
      firstCustomOrNull != null || lastCustomOrNull != null;

  /// Returns the first child if it is a custom range entry.
  SelectorRangeEntry? get firstCustomOrNull {
    final element = children?.firstOrNull;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }

  /// Returns the last child if it is a custom range entry.
  SelectorRangeEntry? get lastCustomOrNull {
    final element = children?.lastOrNull;
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
  SelectorEntry({
    required this.id,
    this.name,
    this.children,
    this.enabled = true,
    this.immediate = false,
    this.extra,
  });

  /// The unique identifier of this entry within its parent.
  final String id;

  /// The display name of this entry.
  String? name;

  /// The child entries of this entry, or null if it is a leaf.
  final Set<SelectorEntry<E>>? children;

  /// Whether this entry can be selected or interacted with.
  ///
  /// Defaults to true. When false, the entry is rendered as disabled.
  final bool enabled;

  /// If true, selecting this node will immediately apply the entry without needing to click the "Apply" button.
  ///
  /// Defaults to false. If the node's id is [kAnyEntryId] and the node's data
  /// is empty, the effective value becomes true. In single-selection mode this
  /// value is ignored and the entry is applied immediately.
  final bool immediate;

  /// Optional arbitrary data attached to this entry.
  final E? extra;

  @override
  String toString() =>
      'SelectorEntry(id: $id, name: $name, children: $children)';
}

extension SelectorEntryExt on SelectorEntry {
  /// Returns the first child entry if present.
  SelectorEntry? get firstChild => children?.firstOrNull;

  /// Returns the last child entry if present.
  SelectorEntry? get lastChild => children?.lastOrNull;

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

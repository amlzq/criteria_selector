import 'package:flutter/foundation.dart';

/// Sealed layout descriptor for the children of a [SelectorCategoryEntry].
///
/// This replaces the previously separate, mutually-exclusive `listConfig`,
/// `gridConfig` and `chipConfig` fields on [SelectorCategoryEntry] with a single
/// `childrenLayout` property. Use a [SelectorListLayout] for a vertical list,
/// [SelectorGridLayout] for a grid, or [SelectorChipLayout] for a wrap of chips.
///
/// Because the class is `sealed`, the compiler can exhaustively check `switch`
/// statements over [SelectorChildrenLayout], so adding a new layout later is a
/// compile-time-safe change.
@immutable
sealed class SelectorChildrenLayout {
  const SelectorChildrenLayout();
}

/// Vertical list layout for the children of a [SelectorCategoryEntry].
class SelectorListLayout extends SelectorChildrenLayout {
  const SelectorListLayout();

  @override
  bool operator ==(Object other) => other is SelectorListLayout;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Grid layout for the children of a [SelectorCategoryEntry].
class SelectorGridLayout extends SelectorChildrenLayout {
  const SelectorGridLayout({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The spacing between children in the main axis.
  final double mainAxisSpacing;

  /// The spacing between children in the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectorGridLayout &&
          crossAxisCount == other.crossAxisCount &&
          mainAxisSpacing == other.mainAxisSpacing &&
          crossAxisSpacing == other.crossAxisSpacing &&
          childAspectRatio == other.childAspectRatio;

  @override
  int get hashCode => Object.hash(
      crossAxisCount, mainAxisSpacing, crossAxisSpacing, childAspectRatio);
}

/// Wrap of chips layout for the children of a [SelectorCategoryEntry].
class SelectorChipLayout extends SelectorChildrenLayout {
  const SelectorChipLayout();

  @override
  bool operator ==(Object other) => other is SelectorChipLayout;

  @override
  int get hashCode => runtimeType.hashCode;
}

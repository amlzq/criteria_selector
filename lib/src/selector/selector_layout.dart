import 'package:flutter/foundation.dart';

/// Sealed layout descriptor for the children of a [SelectorCategoryEntry].
///
/// This replaces the previously separate, mutually-exclusive `listConfig`,
/// `gridConfig` and `chipConfig` fields on [SelectorCategoryEntry] with a single
/// `layout` property. Use a [SelectorListLayout] for a vertical list,
/// [SelectorGridLayout] for a grid, or [SelectorChipLayout] for a wrap of chips.
///
/// Because the class is `sealed`, the compiler can exhaustively check `switch`
/// statements over [SelectorLayout], so adding a new layout later is a
/// compile-time-safe change.
@immutable
sealed class SelectorLayout {
  const SelectorLayout();
}

/// Vertical list layout for the children of a [SelectorCategoryEntry].
class SelectorListLayout extends SelectorLayout {
  const SelectorListLayout({
    this.toText = '-',
  });

  /// Text rendered between the two text fields (default: `'-'`).
  final String toText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectorListLayout && toText == other.toText;

  @override
  int get hashCode => toText.hashCode;
}

/// Grid layout for the children of a [SelectorCategoryEntry].
class SelectorGridLayout extends SelectorLayout {
  const SelectorGridLayout({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.toText = '-',
  });

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The spacing between children in the main axis.
  final double mainAxisSpacing;

  /// The spacing between children in the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// Text rendered between the two text fields (default: `'-'`).
  final String toText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectorGridLayout &&
          crossAxisCount == other.crossAxisCount &&
          mainAxisSpacing == other.mainAxisSpacing &&
          crossAxisSpacing == other.crossAxisSpacing &&
          childAspectRatio == other.childAspectRatio &&
          toText == other.toText;

  @override
  int get hashCode => Object.hash(crossAxisCount, mainAxisSpacing,
      crossAxisSpacing, childAspectRatio, toText);
}

/// Wrap of chips layout for the children of a [SelectorCategoryEntry].
class SelectorChipLayout extends SelectorLayout {
  const SelectorChipLayout();

  @override
  bool operator ==(Object other) => other is SelectorChipLayout;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Range-slider layout for the children of a [SelectorCategoryEntry].
///
/// Use this layout when a category owns a single custom [SelectorRangeEntry]
/// and you want to render it as a "price-range" style control: a
/// [SelectorRangeSlider] on top of two synced text fields.
///
/// The category is expected to expose exactly one
/// [SelectorRangeEntry.firstCustomOrNull]; if none is found, the view falls
/// back to a degenerate 0..1 range.
class SelectorRangeLayout extends SelectorLayout {
  const SelectorRangeLayout({
    this.toText = '-',
  });

  /// Text rendered between the two text fields (default: `'to'`).
  final String toText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectorRangeLayout && toText == other.toText;

  @override
  int get hashCode => toText.hashCode;
}

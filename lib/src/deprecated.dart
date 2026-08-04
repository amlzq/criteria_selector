/// Deprecated API aliases for the `criteria_selector` package.
///
/// This file collects the deprecated symbols that are kept for backward
/// compatibility during a deprecation period. Each alias/class below maps to
/// its replacement and will be removed in a future minor version.
library;

import 'package:flutter/foundation.dart';

import 'i18n/select_localizations.dart';
import 'i18n/select_localizations_delegate.dart';
import 'select_label_state.dart';
import 'select_overlay_style.dart';
import 'selector/select_delegate.dart';
import 'selector/select_layout.dart';
import 'selector/widgets/widgets.dart';

/// Deprecated layout configuration for the children of a [SelectCategoryEntry].
///
/// Use [SelectLayout] / [SelectListLayout] via
/// [SelectCategoryEntry.layout] instead. This class is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use SelectLayout / SelectListLayout via '
  'SelectCategoryEntry.layout instead. '
  'This class will be removed in a future minor version.',
)
@immutable
class SelectorListConfig {
  const SelectorListConfig();
}

/// Deprecated layout configuration for the children of a [SelectCategoryEntry].
///
/// Use [SelectLayout] / [SelectGridLayout] via
/// [SelectCategoryEntry.layout] instead. This class is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use SelectLayout / SelectGridLayout via '
  'SelectCategoryEntry.layout instead. '
  'This class will be removed in a future minor version.',
)
@immutable
class SelectorGridConfig {
  const SelectorGridConfig({
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
}

/// Deprecated layout configuration for the children of a [SelectCategoryEntry].
///
/// Use [SelectLayout] / [SelectChipLayout] via
/// [SelectCategoryEntry.layout] instead. This class is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use SelectLayout / SelectChipLayout via '
  'SelectCategoryEntry.layout instead. '
  'This class will be removed in a future minor version.',
)
@immutable
class SelectorChipConfig {
  const SelectorChipConfig();
}

/// Deprecated alias for [SelectLayout].
///
/// The `Selector`-prefixed layout names were renamed to drop the redundant
/// `Selector` prefix. This alias is kept for backward compatibility and will be
/// removed in a future minor version.
@Deprecated(
  'Use SelectLayout instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorLayout = SelectLayout;

/// Deprecated alias for [SelectListLayout].
@Deprecated(
  'Use SelectListLayout instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorListLayout = SelectListLayout;

/// Deprecated alias for [SelectGridLayout].
@Deprecated(
  'Use SelectGridLayout instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorGridLayout = SelectGridLayout;

/// Deprecated alias for [SelectChipLayout].
@Deprecated(
  'Use SelectChipLayout instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorChipLayout = SelectChipLayout;

/// Deprecated alias for [SelectRangeLayout].
@Deprecated(
  'Use SelectRangeLayout instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorRangeLayout = SelectRangeLayout;

/// Deprecated alias for [SelectLocalizations].
///
/// The `Selector`-prefixed i18n class was renamed to drop the redundant
/// `Selector` prefix. This alias is kept for backward compatibility and will
/// be removed in a future minor version.
@Deprecated(
  'Use SelectLocalizations instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorLocalizations = SelectLocalizations;

/// Deprecated alias for [SelectLocalizationsDelegate].
///
/// The `Selector`-prefixed i18n class was renamed to drop the redundant
/// `Selector` prefix. This alias is kept for backward compatibility and will
/// be removed in a future minor version.
@Deprecated(
  'Use SelectLocalizationsDelegate instead. This alias will be removed in a '
  'future minor version.',
)
typedef SelectorLocalizationsDelegate = SelectLocalizationsDelegate;

/// Deprecated alias for [SelectLabelLoader].
///
/// The `Selector`-prefixed label-loader typedef was renamed to drop the
/// redundant `Selector` prefix. This alias is kept for backward compatibility
/// and will be removed in a future minor version.
@Deprecated(
  'Use SelectLabelLoader instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorLabelLoader = SelectLabelLoader;

/// Deprecated alias for [SelectLabelState].
///
/// The `Selector`-prefixed label-state class was renamed to drop the
/// redundant `Selector` prefix. This alias is kept for backward compatibility
/// and will be removed in a future minor version.
@Deprecated(
  'Use SelectLabelState instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorLabelState = SelectLabelState;

/// Deprecated alias for [SelectOverlayStyle].
///
/// The `Dropdown`-prefixed overlay-style class was renamed to drop the
/// redundant `Dropdown` prefix. This alias is kept for backward compatibility
/// and will be removed in a future minor version.
@Deprecated(
  'Use SelectOverlayStyle instead. This alias will be removed in a future '
  'minor version.',
)
typedef DropdownOverlayStyle = SelectOverlayStyle;

/// Deprecated alias for [SelectActionBar].
///
/// The `Selector`-prefixed widget types were renamed to drop the redundant
/// `Selector` prefix. This alias is kept for backward compatibility and will
/// be removed in a future minor version.
@Deprecated(
  'Use SelectActionBar instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorActionBar = SelectActionBar;

/// Deprecated alias for [SelectActionBarTheme].
@Deprecated(
  'Use SelectActionBarTheme instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorActionBarTheme = SelectActionBarTheme;

/// Deprecated alias for [SelectActionBarSkeleton].
@Deprecated(
  'Use SelectActionBarSkeleton instead. This alias will be removed in a '
  'future minor version.',
)
typedef SelectorActionBarSkeleton = SelectActionBarSkeleton;

/// Deprecated alias for [SelectActionBarBuilder].
@Deprecated(
  'Use SelectActionBarBuilder instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorActionBarBuilder = SelectActionBarBuilder;

/// Deprecated alias for [SelectChipBar].
@Deprecated(
  'Use SelectChipBar instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorChipBar = SelectChipBar;

/// Deprecated alias for [SelectChipBarTheme].
@Deprecated(
  'Use SelectChipBarTheme instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorChipBarTheme = SelectChipBarTheme;

/// Deprecated alias for [SelectChipVariant].
@Deprecated(
  'Use SelectChipVariant instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorChipVariant = SelectChipVariant;

/// Deprecated alias for [SelectExpansionTile].
@Deprecated(
  'Use SelectExpansionTile instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorExpansionTile = SelectExpansionTile;

/// Deprecated alias for [SelectExpansionTileTheme].
@Deprecated(
  'Use SelectExpansionTileTheme instead. This alias will be removed in a '
  'future minor version.',
)
typedef SelectorExpansionTileTheme = SelectExpansionTileTheme;

/// Deprecated alias for [SelectFieldTile].
@Deprecated(
  'Use SelectFieldTile instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorFieldTile = SelectFieldTile;

/// Deprecated alias for [SelectFieldTileTheme].
@Deprecated(
  'Use SelectFieldTileTheme instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorFieldTileTheme = SelectFieldTileTheme;

/// Deprecated alias for [SelectFieldTileVariant].
@Deprecated(
  'Use SelectFieldTileVariant instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorFieldTileVariant = SelectFieldTileVariant;

/// Deprecated alias for [SelectGridTile].
@Deprecated(
  'Use SelectGridTile instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorGridTile = SelectGridTile;

/// Deprecated alias for [SelectGridTileTheme].
@Deprecated(
  'Use SelectGridTileTheme instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorGridTileTheme = SelectGridTileTheme;

/// Deprecated alias for [SelectGridTileVariant].
@Deprecated(
  'Use SelectGridTileVariant instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorGridTileVariant = SelectGridTileVariant;

/// Deprecated alias for [SelectGridView].
@Deprecated(
  'Use SelectGridView instead. This alias will be removed in a future minor '
  'version.',
)
typedef SelectorGridView = SelectGridView;

/// Deprecated alias for [SelectGridViewState].
@Deprecated(
  'Use SelectGridViewState instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorGridViewState = SelectGridViewState;

/// Deprecated alias for [SelectGridSkeleton].
@Deprecated(
  'Use SelectGridSkeleton instead. This alias will be removed in a future '
  'minor version.',
)
typedef SelectorGridSkeleton = SelectGridSkeleton;

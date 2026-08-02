/// Deprecated API aliases for the `criteria_selector` package.
///
/// This file collects the deprecated symbols that are kept for backward
/// compatibility during a deprecation period. Each alias/class below maps to
/// its replacement and will be removed in a future minor version.
library;

import 'package:flutter/foundation.dart';

import 'i18n/localizations.dart';
import 'i18n/localizations_delegate.dart';
import 'selector/selector_layout.dart';

/// Use [SelectorLocalizations] instead.
@Deprecated(
  'Renamed to SelectorLocalizations. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future minor version.',
)
typedef CriteriaSelectorLocalizations = SelectorLocalizations;

/// Use [SelectorLocalizationsDelegate] instead.
@Deprecated(
  'Renamed to SelectorLocalizationsDelegate. The API and behavior are '
  'identical; simply rename the type. This alias will be removed in a future '
  'minor version.',
)
typedef CriteriaSelectorLocalizationsDelegate = SelectorLocalizationsDelegate;

/// Deprecated layout configuration for the children of a [SelectorCategoryEntry].
///
/// Use [SelectorLayout] / [SelectorListLayout] via
/// [SelectorCategoryEntry.layout] instead. This class is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use SelectorLayout / SelectorListLayout via '
  'SelectorCategoryEntry.layout instead. '
  'This class will be removed in a future minor version.',
)
@immutable
class SelectorListConfig {
  const SelectorListConfig();
}

/// Deprecated layout configuration for the children of a [SelectorCategoryEntry].
///
/// Use [SelectorLayout] / [SelectorGridLayout] via
/// [SelectorCategoryEntry.layout] instead. This class is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use SelectorLayout / SelectorGridLayout via '
  'SelectorCategoryEntry.layout instead. '
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

/// Deprecated layout configuration for the children of a [SelectorCategoryEntry].
///
/// Use [SelectorLayout] / [SelectorChipLayout] via
/// [SelectorCategoryEntry.layout] instead. This class is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use SelectorLayout / SelectorChipLayout via '
  'SelectorCategoryEntry.layout instead. '
  'This class will be removed in a future minor version.',
)
@immutable
class SelectorChipConfig {
  const SelectorChipConfig();
}

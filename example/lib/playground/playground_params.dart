import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

/// Where the selector is rendered inside the simulated phone.
enum EntryPoint {
  box,
  dropdownBar,
  dropdownButton,
  dialog,
  bottomSheet,
}

/// Selector layout / delegate family.
enum Layout {
  cascading,
  grid,
  flatten,
  list,
}

/// Visual style of grid / chip tiles.
enum TileVariant {
  filled,
  outlined,
}

/// All tunable parameters of the interactive demo, held in a single immutable
/// value so the controls panel can replace it in one [setState] call.
class PlaygroundParams {
  final EntryPoint entryPoint;
  final Layout layout;
  final SelectionMode selectionMode;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final TileVariant tileVariant;
  final Color seedColor;
  final bool useMaterial3;

  /// Explicit brightness of the simulated phone preview. When `null`, the
  /// preview follows the app's resolved brightness (the [ThemeMode] set by the
  /// top-right button, including `system`). This keeps the independent-preview
  /// ability while allowing a one-click "follow app" sync.
  final Brightness? brightness;

  const PlaygroundParams({
    required this.entryPoint,
    required this.layout,
    required this.selectionMode,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.spacing,
    required this.tileVariant,
    required this.seedColor,
    required this.useMaterial3,
    this.brightness,
  });

  PlaygroundParams copyWith({
    EntryPoint? entryPoint,
    Layout? layout,
    SelectionMode? selectionMode,
    int? crossAxisCount,
    double? childAspectRatio,
    double? spacing,
    TileVariant? tileVariant,
    Color? seedColor,
    bool? useMaterial3,
    Brightness? brightness,
    // Nullable fields need an explicit "clear" flag because `?? this.x` cannot
    // tell "not provided" apart from "provided as null".
    bool clearBrightness = false,
  }) {
    return PlaygroundParams(
      entryPoint: entryPoint ?? this.entryPoint,
      layout: layout ?? this.layout,
      selectionMode: selectionMode ?? this.selectionMode,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      spacing: spacing ?? this.spacing,
      tileVariant: tileVariant ?? this.tileVariant,
      seedColor: seedColor ?? this.seedColor,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      brightness: clearBrightness
          ? null
          : (brightness ?? this.brightness),
    );
  }
}

/// Preset seed colors shown as swatches in the controls panel.
const List<Color> seedColorPresets = <Color>[
  Colors.deepPurple,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.pink,
  Colors.indigo,
];

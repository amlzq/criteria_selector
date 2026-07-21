import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'field_tile_theme.dart';

/// A range input tile for a [SelectorRangeEntry].
///
/// This widget renders two numeric text fields for min/max input.
class SelectorFieldTile extends StatelessWidget {
  const SelectorFieldTile(
    this.entry, {
    super.key,
    this.padding,
    this.minController,
    this.maxController,
    this.minFocusNode,
    this.maxFocusNode,
    this.selectedColor,
    this.tileColor,
    this.selectedTileColor,
    this.variant,
  });

  /// The range entry that defines this tile's input configuration.
  ///
  /// Provides the min/max hint text and an optional input label rendered before
  /// the two fields.
  final SelectorRangeEntry entry;

  /// The padding around the whole tile.
  ///
  /// If null, [EdgeInsets.zero] is used.
  final EdgeInsetsGeometry? padding;

  /// The controller for the minimum value text field.
  ///
  /// If null, an internal controller is created for this field.
  final TextEditingController? minController;

  /// The controller for the maximum value text field.
  ///
  /// If null, an internal controller is created for this field.
  final TextEditingController? maxController;

  /// The focus node for the minimum value text field.
  ///
  /// If null, an internal focus node is created for this field.
  final FocusNode? minFocusNode;

  /// The focus node for the maximum value text field.
  ///
  /// If null, an internal focus node is created for this field.
  final FocusNode? maxFocusNode;

  /// The color used to highlight the tile when a field is focused or has input.
  ///
  /// If null, [SelectorFieldTileTheme.selectedColor] is used. If that is also
  /// null, the value is [SelectorThemeData.selectedColor].
  final Color? selectedColor;

  /// Defines the background color of `SelectorFieldTile` when not focused.
  final Color? tileColor;

  /// Defines the background color of `SelectorFieldTile` when focused.
  final Color? selectedTileColor;

  /// The visual variant of this tile.
  ///
  /// When null, [SelectorFieldTileTheme.variant] is used. Defaults to
  /// [SelectorFieldTileVariant.filled], matching [SelectorGridTile].
  final SelectorFieldTileVariant? variant;

  @override
  Widget build(BuildContext context) {
    // final theme = SelectorFieldTileTheme.of(context);
    return TextFieldTapRegion(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (entry.inputLabel?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  entry.inputLabel ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            Expanded(
              child: _TextField(
                controller: minController,
                focusNode: minFocusNode,
                hintText: entry.minHintText,
                tileColor: tileColor,
                selectedTileColor: selectedTileColor,
                variant: variant,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("-", style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: _TextField(
                controller: maxController,
                focusNode: maxFocusNode,
                hintText: entry.maxHintText,
                tileColor: tileColor,
                selectedTileColor: selectedTileColor,
                variant: variant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;

  final Color? tileColor;
  final Color? selectedTileColor;
  final SelectorFieldTileVariant? variant;

  const _TextField({
    this.controller,
    this.focusNode,
    this.hintText,
    this.tileColor,
    this.selectedTileColor,
    this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SelectorFieldTileTheme.of(context);

    final effectiveVariant =
        variant ?? theme.variant ?? SelectorFieldTileVariant.filled;

    final defaults = _SelectorFieldTileDefaults(context, effectiveVariant);

    final effectiveTileColor =
        tileColor ?? theme.tileColor ?? defaults.tileColor!;

    final effectiveSelectedTileColor = selectedTileColor ??
        theme.selectedTileColor ??
        defaults.selectedTileColor!;

    final selected = (focusNode?.hasFocus ?? false) ||
        (controller?.text.isNotEmpty ?? false);

    final isFilled = effectiveVariant == SelectorFieldTileVariant.filled;

    // Unified tile styling matching [SelectorGridTile]:
    // - filled:   tileColor / selectedTileColor as background, no border
    // - outlined: transparent background, tileColor / selectedTileColor as border
    final tileBackgroundColor = isFilled
        ? (selected ? effectiveSelectedTileColor : effectiveTileColor)
        : null;

    final borderColor =
        selected ? effectiveSelectedTileColor : effectiveTileColor;

    final effectiveBorder =
        isFilled ? null : Border.all(color: borderColor, width: 1.2);

    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tileBackgroundColor,
        border: effectiveBorder,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        // [SelectorFieldTile] wraps the whole row in a [TextFieldTapRegion], so
        // taps on the sibling field / "-" separator are treated as inside and
        // do not trigger this. Only genuine outside taps (grid cells, scrim)
        // unfocus and dismiss the keyboard.
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );

    // return Container(
    //   height: 32,
    //   decoration: BoxDecoration(
    //     border: Border.all(
    //       color: borderColor,
    //       width: 1.2,
    //     ),
    //     borderRadius: BorderRadius.circular(4),
    //   ),
    //   child: TextField(
    //     controller: controller,
    //     focusNode: focusNode,
    //     keyboardType: TextInputType.number,
    //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    //     textAlign: TextAlign.center,
    //     style: const TextStyle(fontSize: 14),
    //     // onChanged: ,
    //     // onSubmitted: ,
    //     // onEditingComplete: ,
    //     // onTap: ,
    //     decoration: InputDecoration(
    //       hintText: hintText,
    //       hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
    //       border: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(10.0),
    //         borderSide: BorderSide(color: Colors.blue),
    //       ),
    //       focusedBorder: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(10.0),
    //         borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    //       ),
    //       contentPadding: const EdgeInsets.only(bottom: 10),
    //     ),
    //   ),
    // );
  }
}

class _SelectorFieldTileDefaults extends SelectorFieldTileTheme {
  _SelectorFieldTileDefaults(
    this.context, [
    SelectorFieldTileVariant? variant,
  ]) : super(variant: variant);

  final BuildContext context;

  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get textColor => _theme.onBackgroundColorHighest;

  @override
  TextStyle? get labelStyle => _textTheme.bodyLarge;

  @override
  TextStyle? get sublabelStyle => _textTheme.bodyMedium;

  @override
  Color? get selectedColor => _theme.selectedColor;

  /// Default [tileColor] based on [variant].
  ///
  /// Mirrors [_SelectorGridTileDefaults.tileColor]: a light tint derived from
  /// [SelectorThemeData.onBackgroundColorHighest] toward white in light theme;
  /// blends surface colors for harmony in dark theme.
  @override
  Color? get tileColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      final blendAmount =
          variant == SelectorFieldTileVariant.outlined ? 0.2 : 0.35;
      return Color.lerp(_theme.backgroundColor,
          _theme.backgroundColorHighest, blendAmount);
    }
    if (variant == SelectorFieldTileVariant.outlined) {
      return Color.lerp(_theme.onBackgroundColorHighest, Colors.white, 0.55);
    }
    return Color.lerp(_theme.onBackgroundColorHighest, Colors.white, 0.8);
  }

  /// Default [selectedTileColor].
  ///
  /// Mirrors [_SelectorGridTileDefaults.selectedTileColor]: blends with
  /// background in dark theme for a harmonious look.
  @override
  Color? get selectedTileColor {
    final baseSelected = _theme.selectedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Color.lerp(_theme.backgroundColor, baseSelected, 0.35);
    }
    return baseSelected;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'field_tile_theme.dart';

/// A range input tile for a [SelectorRangeEntry].
///
/// This widget renders two numeric text fields for min/max input.
class SelectorFieldTile extends StatelessWidget {
  final SelectorRangeEntry item;
  final EdgeInsetsGeometry? padding;

  final TextEditingController? minController;
  final TextEditingController? maxController;
  final FocusNode? minFocusNode;
  final FocusNode? maxFocusNode;

  final Color? selectedColor;

  const SelectorFieldTile(
    this.item, {
    super.key,
    this.padding,
    this.minController,
    this.maxController,
    this.minFocusNode,
    this.maxFocusNode,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = SelectorFieldTileTheme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (item.inputLabel?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(
                item.inputLabel ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          Expanded(
            child: _TextField(
              controller: minController,
              focusNode: minFocusNode,
              hintText: item.minHintText,
              selectedColor: selectedColor,
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
              hintText: item.maxHintText,
              selectedColor: selectedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;

  final Color? selectedColor;

  const _TextField({
    this.controller,
    this.focusNode,
    this.hintText,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final _SelectorFieldTileDefaults defaults =
        _SelectorFieldTileDefaults(context);

    final theme = SelectorFieldTileTheme.of(context);

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final selected = (focusNode?.hasFocus ?? false) ||
        (controller?.text.isNotEmpty ?? false);

    final borderColor = selected ? effectiveSelectedColor : Colors.grey[500]!;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13),
      // onChanged: ,
      // onSubmitted: ,
      // onEditingComplete: ,
      // onTap: ,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        // isDense: true,
        constraints: const BoxConstraints(maxHeight: 36, minHeight: 36),
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
  _SelectorFieldTileDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get textColor => _theme.onBackgroundColorHighest;

  @override
  TextStyle? get labelStyle => _textTheme.bodyMedium;

  @override
  TextStyle? get sublabelStyle => _textTheme.bodySmall;

  @override
  Color? get selectedColor => _theme.selectedColor;
}

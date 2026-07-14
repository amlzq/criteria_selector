import 'package:flutter/material.dart';

import 'selector/constants.dart';
import 'selector/selector_delegate.dart';
import 'selector/selector_panel.dart';
import 'selector/selector_theme_data.dart';

/// Shows a criteria selector in a modal bottom sheet built with Flutter's
/// [showModalBottomSheet].
///
/// Returns the selected [SelectorEntries] when the user applies the selection,
/// or `null` when the sheet is dismissed (for example by tapping the barrier
/// when [isDismissible] is `true`, dragging it down, or via the system back
/// gesture).
///
/// The concrete selector type (Cascading, List, Grid or Flatten) is determined
/// entirely by the concrete [SelectorDelegate] passed via [delegate]. Any
/// [SelectorDelegate] subclass works, so no separate functions are required.
///
/// The interaction mirrors [showSelector]:
/// - In single-selection mode, tapping an item applies the selection
///   immediately and closes the sheet.
/// - In multi-selection mode, the action bar's "Apply" button must be tapped
///   to confirm; "Reset" only clears the current selection without closing.
///
/// The optional [title] is rendered above the selector panel.
///
/// Most of the remaining parameters ([backgroundColor], [elevation], [shape],
/// [clipBehavior], [constraints], [barrierColor], [isScrollControlled],
/// [useRootNavigator], [isDismissible], [enableDrag], [showDragHandle],
/// [useSafeArea] and [routeSettings]) are forwarded directly to
/// [showModalBottomSheet].
///
/// [isScrollControlled] defaults to `true` so the sheet can size to its
/// content. Because the selector body is shrink-wrapped (it has no outer
/// scroll), a default max height of 90% of the screen is applied automatically
/// and the body scrolls internally, unless [constraints] is provided.
Future<SelectorEntries?> showModalBottomSelector({
  required BuildContext context,
  required SelectorDelegate delegate,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool useSafeArea = true,
  Widget? title,
  SelectorThemeData? selectorTheme,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool enableDrag = true,
  bool? showDragHandle,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  // With [isScrollControlled] true Flutter does not cap the sheet height, but
  // the selector body is shrink-wrapped and has no outer scroll. Without a max
  // height tall content would overflow off-screen and hide the action bar, so
  // apply a sensible default unless the caller overrides [constraints].
  final effectiveConstraints = constraints ??
      BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      );
  return showModalBottomSheet<SelectorEntries?>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: effectiveConstraints,
    barrierColor: barrierColor,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    builder: (sheetContext) => _ModalBottomSheetContent(
      delegate: delegate,
      title: title,
      selectorTheme: selectorTheme,
    ),
  );
}

/// The bottom-sheet body rendered by [showModalBottomSheet].
///
/// Wraps a [SelectorPanel] and closes the sheet (returning the selection) when
/// the panel fires its apply callback.
class _ModalBottomSheetContent extends StatefulWidget {
  const _ModalBottomSheetContent({
    required this.delegate,
    this.title,
    this.selectorTheme,
  });

  final SelectorDelegate delegate;
  final Widget? title;
  final SelectorThemeData? selectorTheme;

  @override
  State<_ModalBottomSheetContent> createState() =>
      _ModalBottomSheetContentState();
}

class _ModalBottomSheetContentState extends State<_ModalBottomSheetContent> {
  // Guards against double-pop if both an apply callback and a drag/barrier
  // dismiss race.
  bool _popped = false;

  void _popWith(SelectorEntries? result) {
    if (_popped) return;
    _popped = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final panel = SelectorPanel(
      delegate: widget.delegate,
      selectorTheme: widget.selectorTheme,
      onApplyTap: (selected) => _popWith(selected),
      // Reset is handled internally by the selector widget; the sheet stays
      // open so the user can keep adjusting the selection.
      onResetTap: () {},
    );

    // Shrink to the panel's intrinsic height when content is short (e.g. a
    // 6-row single-select list) so there is no empty space, while still capping
    // at the bottom sheet's own max height (0.9 of the screen when
    // [isScrollControlled] is false) when content is large. The selector then
    // scrolls internally and its action bar stays pinned to the bottom.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null) _BottomSheetHeader(title: widget.title!),
        Flexible(
          fit: FlexFit.loose,
          child: panel,
        ),
      ],
    );
  }
}

/// Optional header shown above the selector panel inside the bottom sheet.
class _BottomSheetHeader extends StatelessWidget {
  const _BottomSheetHeader({required this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleLarge ?? theme.textTheme.titleMedium;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      alignment: Alignment.centerLeft,
      child: DefaultTextStyle(
        style: textStyle!,
        child: title,
      ),
    );
  }
}

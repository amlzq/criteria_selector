import 'package:flutter/material.dart';

import 'selector/constants.dart';
import 'selector/selector_delegate.dart';
import 'selector/selector_panel.dart';
import 'selector/selector_theme_data.dart';

/// Shows a criteria selector in a modal dialog.
///
/// Returns the selected [SelectorEntries] when the user applies the selection,
/// or `null` when the dialog is dismissed (for example by tapping the barrier
/// when [barrierDismissible] is `true`, or via the system back gesture).
///
/// The concrete selector type (Cascading, List, Grid or Flatten) is determined
/// entirely by the concrete [SelectorDelegate] passed via [delegate]. Any
/// [SelectorDelegate] subclass works, so no separate functions are required.
///
/// The interaction mirrors Flutter's [showTimePicker]:
/// - In single-selection mode, tapping an item applies the selection
///   immediately and closes the dialog.
/// - In multi-selection mode, the action bar's "Apply" button must be tapped
///   to confirm; "Reset" only clears the current selection without closing.
///
/// The optional [title] is rendered above the selector panel.
Future<SelectorEntries?> showSelector({
  required BuildContext context,
  required SelectorDelegate delegate,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  Widget? title,
  SelectorThemeData? selectorTheme,
  Widget Function(Object error, StackTrace? stackTrace)? errorBuilder,
  TransitionBuilder? builder,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  final route = _SelectorDialogRoute<SelectorEntries?>(
    pageBuilder: (innerContext) => _SelectorDialog(
      delegate: delegate,
      title: title,
      selectorTheme: selectorTheme,
      errorBuilder: errorBuilder,
    ),
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black54,
    barrierLabel: barrierDismissible
        ? MaterialLocalizations.of(context).modalBarrierDismissLabel
        : null,
    settings: routeSettings,
    anchorPoint: anchorPoint,
    builder: builder,
  );

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<SelectorEntries?>(route);
}

/// Modal route used by [showSelector].
///
/// Mirrors the structure of Flutter's `_TimePickerDialogRoute`: it builds the
/// page via [pageBuilder] and applies a fade + scale transition.
class _SelectorDialogRoute<T> extends RawDialogRoute<T> {
  _SelectorDialogRoute({
    required WidgetBuilder pageBuilder,
    super.barrierDismissible = true,
    required Color barrierColor,
    super.barrierLabel,
    super.settings,
    super.anchorPoint,
    TransitionBuilder? builder,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            final Widget page = pageBuilder(context);
            return builder == null ? page : builder(context, page);
          },
          barrierColor: barrierColor,
          transitionDuration: const Duration(milliseconds: 200),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

/// The dialog body rendered by [_SelectorDialogRoute].
///
/// Wraps a [SelectorPanel] and closes the route (returning the selection) when
/// the panel fires its apply callback.
class _SelectorDialog extends StatefulWidget {
  const _SelectorDialog({
    required this.delegate,
    this.title,
    this.selectorTheme,
    this.errorBuilder,
  });

  final SelectorDelegate delegate;
  final Widget? title;
  final SelectorThemeData? selectorTheme;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  @override
  State<_SelectorDialog> createState() => _SelectorDialogState();
}

class _SelectorDialogState extends State<_SelectorDialog> {
  // Guards against double-pop if both an apply callback and a barrier dismiss
  // race (e.g. on some platforms).
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
      errorBuilder: widget.errorBuilder,
      onApplyTap: (selected) => _popWith(selected),
      // Reset is handled internally by the selector widget; the dialog stays
      // open so the user can keep adjusting the selection.
      onResetTap: () {},
    );

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          // Shrink to the panel's intrinsic height when content is short
          // (e.g. a 6-row single-select list) so there is no empty space,
          // while still capping at 0.7 of the screen height.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null)
              _SelectorDialogHeader(title: widget.title!),
            // `loose` lets the panel take only as much height as it needs when
            // content is small, but never exceed the free space (0.7 screen
            // height minus the header) when content is large, so the selector
            // scrolls internally and its action bar stays pinned to the bottom.
            Flexible(
              fit: FlexFit.loose,
              child: panel,
            ),
          ],
        ),
      ),
    );
  }
}

/// Optional header shown above the selector panel inside [_SelectorDialog].
class _SelectorDialogHeader extends StatelessWidget {
  const _SelectorDialogHeader({required this.title});

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

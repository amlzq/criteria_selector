import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import 'selector_controller.dart';
import 'selector_theme.dart';
import 'selector_theme_data.dart';

/// A widget that renders a [Selector] and manages its selection state.
///
/// The panel loads [Selector.data] and displays the selector body once the data
/// is available, or a skeleton while it is loading. Selector widgets rendered by
/// the panel are styled according to [selectorTheme].
///
/// The selection state is driven by a [SelectorController]. If [controller] is
/// omitted, the panel creates and owns an internal controller. In both cases
/// (an internal controller or a caller-provided one), the panel forwards
/// selection events through the [onChangeTap], [onApplyTap] and [onResetTap]
/// callbacks. When [controller] is provided, the caller still owns it and can
/// drive the selection programmatically (for example, with
/// [SelectorController.select]); the panel-level callbacks are fired in addition
/// to any listeners registered directly on the controller.
///
/// The active controller is exposed to descendants via
/// [SelectorControllerProvider].
class SelectorPanel extends StatefulWidget {
  const SelectorPanel({
    super.key,
    required this.selector,
    this.controller,
    this.onChangeTap,
    this.onApplyTap,
    this.onResetTap,
    this.selectorTheme,
    this.errorBuilder,
  });

  final Selector selector;

  /// Optional controller that drives the selection state.
  ///
  /// When provided, callers can call [SelectorController.select] and other
  /// methods from outside the panel. The panel will not dispose a controller
  /// that it did not create.
  ///
  /// When a controller is supplied, the panel-level [onChangeTap],
  /// [onApplyTap] and [onResetTap] callbacks are forwarded in addition to any
  /// listeners registered directly on the controller. The panel will not
  /// dispose a controller that it did not create.
  final SelectorController? controller;

  /// Fired when the selection changes.
  ///
  /// Forwarded in both cases, whether [controller] is provided or not.
  final SelectorCallback? onChangeTap;

  /// Fired when the selection is applied.
  ///
  /// Forwarded in both cases, whether [controller] is provided or not.
  final SelectorCallback? onApplyTap;

  /// Fired when reset is triggered.
  ///
  /// Forwarded in both cases, whether [controller] is provided or not.
  final VoidCallback? onResetTap;

  final SelectorThemeData? selectorTheme;

  /// Optional builder invoked when [Selector.data] fails to load.
  ///
  /// When omitted, a simple [Text] widget showing the error is rendered.
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  @override
  State<SelectorPanel> createState() => _SelectorPanelState();
}

class _SelectorPanelState extends State<SelectorPanel> {
  SelectorController? _internalController;
  final List<VoidCallback> _unregister = [];

  SelectorController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createInternalController();
    }
    _registerForwardingListeners();
  }

  void _createInternalController() {
    _internalController = SelectorController(
      selectionMode: widget.selector.selectionMode,
      previousSelected: widget.selector.selectedData,
      resetSelected: widget.selector.resetData,
    );
  }

  /// Forwards the panel-level callbacks on the active controller, whether it is
  /// the internal one or a caller-provided one. Listeners are re-registered
  /// whenever the effective controller instance changes.
  void _registerForwardingListeners() {
    _unregister.add(_controller.addChangeListener((selected) {
      widget.onChangeTap?.call(selected);
    }));
    _unregister.add(_controller.addApplyListener((selected) {
      widget.onApplyTap?.call(selected);
    }));
    _unregister.add(_controller.addResetListener(() {
      widget.onResetTap?.call();
    }));
  }

  void _unregisterForwardingListeners() {
    for (final u in _unregister) {
      u();
    }
    _unregister.clear();
  }

  void _disposeInternalController() {
    _internalController?.dispose();
    _internalController = null;
  }

  @override
  void didUpdateWidget(covariant SelectorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _unregisterForwardingListeners();
      if (oldWidget.controller == null) {
        _disposeInternalController();
      }
      if (widget.controller == null) {
        _createInternalController();
      }
      _registerForwardingListeners();
    }
  }

  @override
  void dispose() {
    _unregisterForwardingListeners();
    _disposeInternalController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectorTheme(
      data:
          widget.selectorTheme ?? SelectorThemeData.fallback(Theme.of(context)),
      child: ColoredBox(
        color: SelectorTheme.of(context).backgroundColor,
        child: SelectorControllerProvider(
          controller: _controller,
          child: FutureBuilder<SelectorEntries>(
            future: widget.selector.data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  final error = snapshot.error!;
                  final builder = widget.errorBuilder;
                  if (builder != null) {
                    return builder(error, snapshot.stackTrace);
                  }
                  return Center(child: Text('Error: $error'));
                } else {
                  final entries = snapshot.data?.toList() ?? <SelectorEntry>[];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: widget.selector.buildBody(
                        context, entries, _controller.previousSelected),
                  );
                }
              } else {
                // Request in progress: show loading
                return widget.selector.buildSkeleton(context);
              }
            },
          ),
        ),
      ),
    );
  }
}

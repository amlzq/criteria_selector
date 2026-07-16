import 'package:flutter/material.dart';

import 'selector/constants.dart';
import 'selector/selector_controller.dart';
import 'selector/selector_delegate.dart';
import 'selector/selector_panel.dart';

/// A high-level, ready-to-use criteria selector.
///
/// [CriteriaSelector] is the public entry point for embedding a selector
/// directly in a page or dialog body. It wraps [SelectorPanel] — now an
/// internal implementation detail that is no longer exported — and takes care
/// of the controller lifecycle so callers get a complete, styled component
/// without extra wiring.
///
/// The actual selection UI, including the apply/reset action bar in
/// multi-selection mode, is produced by the supplied [delegate]. The action
/// bar's behavior is inherently delegate-specific (for example, resetting the
/// focused category index), so it stays owned by the delegate rather than being
/// re-created here. [CriteriaSelector] forwards the [onChangeTap], [onApplyTap]
/// and [onResetTap] callbacks fired by the selection.
///
/// Styling is carried entirely by the [delegate] (colors, per-widget themes
/// and the panel decoration via [SelectorDelegate.panelTheme]). When a selector
/// is the only one in its host, a separate `selectorTheme` parameter is
/// unnecessary.
///
/// If [controller] is omitted, [CriteriaSelector] creates and owns an internal
/// [SelectorController]; otherwise the caller-provided controller is used and
/// remains owned by the caller.
class CriteriaSelector extends StatefulWidget {
  const CriteriaSelector({
    super.key,
    required this.delegate,
    this.controller,
    this.onChangeTap,
    this.onApplyTap,
    this.onResetTap,
    this.maxHeightFactor = 0.5,
  }) : assert(maxHeightFactor > 0 && maxHeightFactor <= 1);

  /// Configuration describing how entries are loaded and how the selector body
  /// is rendered. Determines the concrete selector type (Cascading, List, Grid
  /// or Flatten). Also carries all theme overrides (colors, per-widget themes
  /// and the panel decoration via [SelectorDelegate.panelTheme]).
  final SelectorDelegate delegate;

  /// Optional controller that drives the selection state.
  ///
  /// When provided, callers can drive the selection programmatically (for
  /// example with [SelectorController.select]); the caller still owns it and is
  /// responsible for disposing it. When omitted, an internal controller is
  /// created and disposed by [CriteriaSelector].
  final SelectorController? controller;

  /// Fired when the selection changes.
  final SelectorCallback? onChangeTap;

  /// Fired when the selection is applied (e.g. via the action bar's "Apply").
  final SelectorCallback? onApplyTap;

  /// Fired when reset is triggered (e.g. via the action bar's "Reset").
  final VoidCallback? onResetTap;

  /// Caps the selector's height to this fraction of the screen height when it
  /// is embedded in an unbounded context (e.g. a [Column] with
  /// `mainAxisSize: min`).
  ///
  /// The cascading selector lays out its body/skeleton with a `Column(min)` +
  /// `Expanded`, which requires a bounded height. This constraint only limits
  /// growth: a smaller bound from an ancestor (such as a [SizedBox] or
  /// [Expanded]) still wins via `min(parent, factor * screenHeight)`. Content
  /// shorter than the cap still shrinks to fit.
  ///
  /// It has no effect on the modal [showSelector] / [showModalBottomSelector],
  /// which use [SelectorPanel] directly with their own height constraints.
  final double maxHeightFactor;

  @override
  State<CriteriaSelector> createState() => _CriteriaSelectorState();
}

class _CriteriaSelectorState extends State<CriteriaSelector> {
  SelectorController? _internalController;

  SelectorController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createInternalController();
    }
  }

  void _createInternalController() {
    _internalController = SelectorController(
      selectionMode: widget.delegate.selectionMode,
      previousSelected: widget.delegate.selectedData,
      resetSelected: widget.delegate.resetData,
    );
  }

  @override
  void didUpdateWidget(covariant CriteriaSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
      if (widget.controller == null) {
        _createInternalController();
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    _internalController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The controller is owned here, but the selection body (and the
    // delegate-owned action bar) is rendered by the internal SelectorPanel,
    // which is kept as the building block used by dialogs and bottom sheets.
    //
    // The cascading selector lays out its body/skeleton with a Column(min) +
    // Expanded, which requires a bounded height. Constrain the max so the
    // selector never receives unbounded height when embedded standalone; a
    // smaller bound from an ancestor still wins because constraints are
    // tightened (min) to the smaller value. Content shorter than the cap
    // shrinks to fit (it is not forced to fill).
    final maxHeight =
        widget.maxHeightFactor * MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SelectorPanel(
        delegate: widget.delegate,
        controller: _controller,
        onChangeTap: widget.onChangeTap,
        onApplyTap: widget.onApplyTap,
        onResetTap: widget.onResetTap,
      ),
    );
  }
}

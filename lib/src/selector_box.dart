import 'package:flutter/material.dart';

import 'selector/constants.dart';
import 'selector/selector_controller.dart';
import 'selector/selector_delegate.dart';
import 'selector/selector_panel.dart';

/// A high-level, ready-to-use selector.
///
/// [SelectorBox] is the public entry point for embedding a selector
/// directly in a page or dialog body. It wraps [SelectorPanel] — now an
/// internal implementation detail that is no longer exported — and takes care
/// of the controller lifecycle so callers get a complete, styled component
/// without extra wiring.
///
/// The actual selection UI, including the apply/reset action bar in
/// multi-selection mode, is produced by the supplied [delegate]. The action
/// bar's behavior is inherently delegate-specific (for example, resetting the
/// focused category index), so it stays owned by the delegate rather than being
/// re-created here. [SelectorBox] forwards the [onChangeTap] callback fired by
/// the selection; the apply/reset action bar is driven entirely by the
/// [delegate].
///
/// Styling is carried entirely by the [delegate] (colors, per-widget themes
/// and the panel decoration via [SelectorDelegate.panelTheme]). When a selector
/// is the only one in its host, a separate `selectorTheme` parameter is
/// unnecessary.
///
/// If [controller] is omitted, [SelectorBox] creates and owns an internal
/// [SelectorController]; otherwise the caller-provided controller is used and
/// remains owned by the caller.
///
/// In addition to selector-specific options, [SelectorBox] accepts the same
/// sizing and decorating parameters as [Container] — [width], [height],
/// [constraints], [padding], [margin] and [decoration]. These surround the
/// [SelectorPanel] exactly as [Container] surrounds its child: the panel is
/// inset by [padding] (inflated by any border in the [decoration]), the
/// [decoration] is painted to fill the padded extent, then [constraints]
/// (combining [width]/[height]) are applied, and finally the [margin]
/// surrounds everything. The [maxHeightFactor] still caps the height in
/// unbounded contexts; a smaller bound from [width]/[height]/[constraints]
/// always wins.
class SelectorBox extends StatefulWidget {
  /// Creates a selector box.
  ///
  /// The [width] and [height] values include the [padding] (but not the
  /// [margin]), mirroring [Container].
  SelectorBox({
    super.key,
    required this.delegate,
    this.controller,
    this.maxHeightFactor = 0.5,
    this.padding,
    this.decoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.margin,
    this.onChangeTap,
  })  : assert(maxHeightFactor > 0 && maxHeightFactor <= 1),
        assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints;

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
  /// created and disposed by [SelectorBox].
  final SelectorController? controller;

  /// Fired when the selection changes.
  final SelectorCallback? onChangeTap;

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
  /// When [width], [height] or [constraints] are provided, they are combined
  /// with this cap (a tighter bound still wins); see [constraints].
  ///
  /// It has no effect on the modal [showSelector] / [showModalBottomSelector],
  /// which use [SelectorPanel] directly with their own height constraints.
  final double maxHeightFactor;

  /// Empty space to inscribe inside the [decoration]. The [SelectorPanel] is
  /// placed inside this padding.
  ///
  /// This padding is in addition to any padding inherent in the [decoration]
  /// (e.g. borders in a [BoxDecoration]); see [Decoration.padding].
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the [decoration] and the selector content.
  final EdgeInsetsGeometry? margin;

  /// The decoration to paint behind the selector content.
  ///
  /// Commonly a [BoxDecoration]. The [SelectorPanel] is not clipped to the
  /// decoration; to clip it to a particular shape, consider wrapping the box
  /// in a [ClipPath].
  final Decoration? decoration;

  /// Additional constraints to apply to the selector content.
  ///
  /// The constructor [width] and [height] arguments are combined with this
  /// [constraints] argument to set the effective constraints, exactly as in
  /// [Container]. The [padding] goes inside the constraints.
  ///
  /// When this is null and no [width]/[height] is given, the
  /// [maxHeightFactor] caps the height in unbounded contexts. When provided, a
  /// smaller bound wins and a tighter [width]/[height] takes precedence, while
  /// [maxHeightFactor] still applies as an upper cap.
  final BoxConstraints? constraints;

  /// The padding including any padding inherent in the [decoration].
  EdgeInsetsGeometry? get _paddingIncludingDecoration {
    return switch ((padding, decoration?.padding)) {
      (null, final EdgeInsetsGeometry? padding) => padding,
      (final EdgeInsetsGeometry? padding, null) => padding,
      (_) => padding!.add(decoration!.padding),
    };
  }

  @override
  State<SelectorBox> createState() => _SelectorBoxState();
}

class _SelectorBoxState extends State<SelectorBox> {
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
  void didUpdateWidget(covariant SelectorBox oldWidget) {
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

  /// Combines [SelectorBox.constraints] (already merged with
  /// [SelectorBox.width]/[height] by the constructor) with the
  /// [SelectorBox.maxHeightFactor] cap. A smaller bound always wins, and
  /// unbounded contexts are still protected when no explicit size is given.
  BoxConstraints _effectiveConstraints(BuildContext context) {
    final BoxConstraints? sizeConstraints = widget.constraints;
    final double maxHeight =
        widget.maxHeightFactor * MediaQuery.of(context).size.height;
    final BoxConstraints heightCap = BoxConstraints(maxHeight: maxHeight);
    if (sizeConstraints != null) {
      // Enforce clamps the cap's values into the user's range, so a tighter
      // user bound wins while the cap still applies when the user leaves a
      // dimension open.
      return heightCap.enforce(sizeConstraints);
    }
    return heightCap;
  }

  @override
  Widget build(BuildContext context) {
    // The controller is owned here, but the selection body (and the
    // delegate-owned action bar) is rendered by the internal SelectorPanel,
    // which is kept as the building block used by dialogs and bottom sheets.
    //
    // Layout mirrors [Container]: the [SelectorPanel] is surrounded by
    // [padding] (inflated by any border in the [decoration]), then the
    // [decoration] is painted, then constraints are applied (combining
    // [width]/[height]/[constraints] with the [maxHeightFactor] cap), and
    // finally the [margin] surrounds everything. The cascading selector lays
    // out its body/skeleton with a Column(min) + Expanded, which requires a
    // bounded height; the constraints guarantee that.
    Widget current = SelectorPanel(
      delegate: widget.delegate,
      controller: _controller,
      onChangeTap: widget.onChangeTap,
    );

    final EdgeInsetsGeometry? effectivePadding =
        widget._paddingIncludingDecoration;
    if (effectivePadding != null) {
      current = Padding(padding: effectivePadding, child: current);
    }

    if (widget.decoration != null) {
      current = DecoratedBox(decoration: widget.decoration!, child: current);
    }

    current = ConstrainedBox(
      constraints: _effectiveConstraints(context),
      child: current,
    );

    if (widget.margin != null) {
      current = Padding(padding: widget.margin!, child: current);
    }

    return current;
  }
}

import 'package:flutter/material.dart';

import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'expansion_tile_theme.dart';

const kSelectorExpansionTileAnimationDuration = Duration(milliseconds: 200);

class SelectorExpansionTile extends StatefulWidget {
  const SelectorExpansionTile({
    super.key,
    required this.title,
    this.titleStyle,
    this.selectedColor,
    required this.child,
    this.showTrailingIcon = true,
    this.titlePadding,
    this.childPadding,
    this.animationDuration,
    this.expansionCurve,
    this.collapseCurve,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.enabled = true,
    this.onExpansionChanged,
  });

  /// The primary text displayed in the tile's header.
  final String title;

  /// The text style of the [title].
  ///
  /// If null, [SelectorExpansionTileTheme.titleStyle] is used. If that is also
  /// null, the value is [TextTheme.titleLarge].
  final TextStyle? titleStyle;

  /// The color used to highlight the tile when expanded.
  ///
  /// If null, [SelectorExpansionTileTheme.selectedColor] is used. If that is
  /// also null, the value is [SelectorThemeData.selectedColor].
  final Color? selectedColor;

  /// The content displayed below the header when the tile is expanded.
  final Widget child;

  /// Whether to show the expand/collapse icon at the end of the header.
  ///
  /// Defaults to true. The icon rotates as the tile expands and collapses.
  final bool showTrailingIcon;

  /// The padding around the header (title and trailing icon).
  ///
  /// If null, [SelectorExpansionTileTheme.titlePadding] is used. If that is
  /// also null, the value is [EdgeInsets.zero].
  final EdgeInsetsGeometry? titlePadding;

  /// The padding around the [child] content.
  ///
  /// If null, [SelectorExpansionTileTheme.childPadding] is used. If that is
  /// also null, the value is [EdgeInsets.zero].
  final EdgeInsetsGeometry? childPadding;

  /// The duration of the expand and collapse animation.
  ///
  /// If null, [SelectorExpansionTileTheme.animationDuration] is used. If that
  /// is also null, the default is 200ms.
  final Duration? animationDuration;

  /// The animation curve used when the tile expands.
  ///
  /// If null, [SelectorExpansionTileTheme.expansionCurve] is used. If that is
  /// also null, the default is [Curves.easeIn].
  final Curve? expansionCurve;

  /// The animation curve used when the tile collapses.
  ///
  /// If null, [SelectorExpansionTileTheme.collapseCurve] is used. If that is
  /// also null, the default is [Curves.easeOut].
  final Curve? collapseCurve;

  /// Whether the tile is expanded when first built.
  ///
  /// Defaults to false. The expanded state is restored across rebuilds via
  /// [PageStorage].
  final bool initiallyExpanded;

  /// Whether the [child] is kept in the tree when the tile is collapsed.
  ///
  /// If false (the default), the child is removed from the tree when collapsed
  /// and its state is lost. If true, the child is kept mounted (though hidden)
  /// so its state is preserved.
  final bool maintainState;

  /// Whether the tile responds to taps.
  ///
  /// Defaults to true. When false, the tile cannot be expanded or collapsed,
  /// and the header is shown in a disabled color.
  final bool enabled;

  /// Called when the tile expands or collapses.
  ///
  /// The argument is true when the tile becomes expanded and false when it
  /// becomes collapsed.
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<SelectorExpansionTile> createState() => _SelectorExpansionTileState();
}

class _SelectorExpansionTileState extends State<SelectorExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _heightFactor;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: kSelectorExpansionTileAnimationDuration,
    );
    _animationController.addStatusListener(_handleStatusChanged);
    _heightFactor = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
    _iconTurns = _heightFactor.drive(Tween<double>(begin: 0.0, end: 0.5));

    _isExpanded = PageStorage.maybeOf(context)?.readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_handleStatusChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final theme = SelectorExpansionTileTheme.of(context);

    final effectiveDuration = widget.animationDuration ??
        theme.animationDuration ??
        kSelectorExpansionTileAnimationDuration;

    if (_animationController.duration != effectiveDuration) {
      _animationController.duration = effectiveDuration;
    }

    final effectiveExpansionCurve =
        widget.expansionCurve ?? theme.expansionCurve ?? Curves.easeIn;
    final effectiveCollapseCurve =
        widget.collapseCurve ?? theme.collapseCurve ?? Curves.easeOut;

    _heightFactor = CurvedAnimation(
      parent: _animationController,
      curve: effectiveExpansionCurve,
      reverseCurve: effectiveCollapseCurve,
    );
    _iconTurns = _heightFactor.drive(Tween<double>(begin: 0.0, end: 0.5));
  }

  @override
  void didUpdateWidget(covariant SelectorExpansionTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled != oldWidget.enabled && !widget.enabled && _isExpanded) {
      _setExpanded(false);
    }
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed ||
        status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleTap() {
    if (!widget.enabled) {
      return;
    }
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded == isExpanded) {
      return;
    }

    setState(() {
      _isExpanded = isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      PageStorage.maybeOf(context)?.writeState(context, _isExpanded);
    });

    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final _SelectorExpansionTileDefaults defaults =
        _SelectorExpansionTileDefaults(context);

    final SelectorExpansionTileTheme theme =
        SelectorExpansionTileTheme.of(context);

    final effectiveTitleStyle =
        (widget.titleStyle ?? theme.titleStyle ?? defaults.titleStyle!);

    // final effectiveSelectedColor =
    //     widget.selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final trailingIcon = widget.showTrailingIcon
        ? RotationTransition(
            turns: _iconTurns,
            child: Icon(
              Icons.expand_more,
              color: widget.enabled ? null : Colors.grey[500],
            ),
          )
        : const SizedBox.shrink();

    final title = Padding(
      padding: widget.titlePadding ?? theme.titlePadding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Text(widget.title, style: effectiveTitleStyle),
          ),
          trailingIcon,
        ],
      ),
    );

    final body = child == null
        ? const SizedBox.shrink()
        : ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          enabled: widget.enabled,
          expanded: _isExpanded,
          child: InkWell(
            onTap: widget.enabled ? _handleTap : null,
            child: title,
          ),
        ),
        body,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SelectorExpansionTileTheme theme =
        SelectorExpansionTileTheme.of(context);

    final bool closed = !_isExpanded && _animationController.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Padding(
          padding: widget.childPadding ?? theme.childPadding ?? EdgeInsets.zero,
          child: widget.child,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _animationController.view,
      builder: _buildChildren,
      child: shouldRemoveChildren ? null : result,
    );
  }
}

class _SelectorExpansionTileDefaults extends SelectorExpansionTileTheme {
  _SelectorExpansionTileDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  TextStyle? get titleStyle => _textTheme.titleLarge;

  @override
  Color? get selectedColor => _theme.selectedColor;
}

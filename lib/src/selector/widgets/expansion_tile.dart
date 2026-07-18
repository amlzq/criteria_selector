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

  final String title;

  final TextStyle? titleStyle;

  final Color? selectedColor;

  final Widget child;

  final bool showTrailingIcon;

  final EdgeInsetsGeometry? titlePadding;

  final EdgeInsetsGeometry? childPadding;

  final Duration? animationDuration;

  final Curve? expansionCurve;

  final Curve? collapseCurve;

  final bool initiallyExpanded;

  final bool maintainState;

  final bool enabled;

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

import 'package:flutter/material.dart';

import 'dropdown_overlay.dart';
import 'dropdown_overlay_style.dart';
import 'dropdown_selector_button_theme.dart';
import 'dropdown_selector_controller.dart';
import 'dropdown_selector_result.dart';
import 'dropdown_tab_data.dart';
import 'i18n/localizations.dart';
import 'selector/constants.dart';
import 'selector/selector_delegate.dart';
import 'selector_overlay_host.dart';

/// Visual variants for [DropdownSelectorButton].
enum DropdownSelectorButtonVariant {
  /// A button with elevation and a subtle surface tint (like [ElevatedButton]).
  elevated,

  /// A filled button using the color scheme primary (like [FilledButton]).
  filled,

  /// A button with a transparent background and an outline border
  /// (like [OutlinedButton]).
  outlined,
}

/// Default height used when the button size cannot be measured yet.
const kDropdownSelectorButtonHeight = 40.0;

/// A single-button alternative to [DropdownSelectorBar].
///
/// Where [DropdownSelectorBar] renders a horizontal row of tabs, this widget
/// exposes a single trigger styled like a Material button (one of
/// [DropdownSelectorButtonVariant]) that opens the selector overlay on tap,
/// similar to [PopupMenuButton]. The interaction (overlay positioning,
/// animation, dismissal on outside tap, auto-close on apply) is driven by the
/// same [DropdownSelectorController] machinery as [DropdownSelectorBar].
///
/// Provide a [selectorDelegate] to define the selector content, and a [label]
/// or [child] for the trigger. The trailing [icon] rotates while the overlay is
/// open. After an apply, the button label is updated with the resulting label.
class DropdownSelectorButton extends StatefulWidget {
  /// Creates a filled button (the default variant).
  const DropdownSelectorButton({
    super.key,
    required this.selectorDelegate,
    this.variant = DropdownSelectorButtonVariant.filled,
    this.label,
    this.child,
    this.icon,
    this.overlayStyle,
    this.onSelectorShowed,
    this.onSelectorHidden,
    this.onSelectorWillShow,
    this.onSelectorWillHide,
    this.onChanged,
    this.onApplied,
    this.onReset,
    this.direction = DropdownSelectorDirection.below,
  }) : assert(label == null || child == null,
            'Provide either label or child, not both.');

  /// Creates an elevated button. The [variant] is fixed to
  /// [DropdownSelectorButtonVariant.elevated].
  const DropdownSelectorButton.elevated({
    super.key,
    required this.selectorDelegate,
    this.label,
    this.child,
    this.icon,
    this.overlayStyle,
    this.onSelectorShowed,
    this.onSelectorHidden,
    this.onSelectorWillShow,
    this.onSelectorWillHide,
    this.onChanged,
    this.onApplied,
    this.onReset,
    this.direction = DropdownSelectorDirection.below,
  })  : variant = DropdownSelectorButtonVariant.elevated,
        assert(label == null || child == null,
            'Provide either label or child, not both.');

  /// Creates an outlined button. The [variant] is fixed to
  /// [DropdownSelectorButtonVariant.outlined].
  const DropdownSelectorButton.outlined({
    super.key,
    required this.selectorDelegate,
    this.label,
    this.child,
    this.icon,
    this.overlayStyle,
    this.onSelectorShowed,
    this.onSelectorHidden,
    this.onSelectorWillShow,
    this.onSelectorWillHide,
    this.onChanged,
    this.onApplied,
    this.onReset,
    this.direction = DropdownSelectorDirection.below,
  })  : variant = DropdownSelectorButtonVariant.outlined,
        assert(label == null || child == null,
            'Provide either label or child, not both.');

  /// Selector configuration for the single trigger.
  final SelectorDelegate selectorDelegate;

  /// Visual style of the trigger button.
  final DropdownSelectorButtonVariant variant;

  /// Default label shown on the trigger. Replaced by the applied result label
  /// after a selection is applied. Mutually exclusive with [child].
  final String? label;

  /// Custom trigger content. Takes precedence over [label].
  final Widget? child;

  /// Trailing icon. Defaults to [Icons.arrow_drop_down] and rotates by 180°
  /// while the overlay is open.
  final Widget? icon;

  /// Overrides the default value of [DropdownOverlayStyle].
  final DropdownOverlayStyle? overlayStyle;

  /// Fired when the selector overlay is shown.
  final SelectorToggleCallback? onSelectorShowed;

  /// Fired when the selector overlay is hidden.
  final SelectorToggleCallback? onSelectorHidden;

  /// Invoked just before the overlay is shown. The returned [Future] (if any)
  /// is awaited before the overlay appears, e.g. to scroll a header into place.
  /// Returning `false` cancels the show, leaving the overlay hidden.
  final SelectorWillToggleCallback? onSelectorWillShow;

  /// Invoked just before the overlay is hidden. Returning `false` cancels the
  /// hide, leaving the overlay visible.
  final SelectorWillToggleCallback? onSelectorWillHide;

  /// Fired whenever a selector reports a selection change.
  final DropdownSelectorResultCallback? onChanged;

  /// Fired when a selector is applied.
  final DropdownSelectorResultCallback? onApplied;

  /// Fired when reset is triggered.
  final VoidCallback? onReset;

  /// Vertical placement of the selector panel relative to the trigger.
  ///
  /// Defaults to [DropdownSelectorDirection.below], which always shows the
  /// panel under the trigger. Use [DropdownSelectorDirection.adaptive] to let
  /// it flip above when there is more room there, or
  /// [DropdownSelectorDirection.above] to force the panel above. Regardless of
  /// the value, the panel is always kept fully on screen horizontally.
  final DropdownSelectorDirection direction;

  @override
  State<DropdownSelectorButton> createState() => _DropdownSelectorButtonState();
}

class _DropdownSelectorButtonState extends State<DropdownSelectorButton>
    with SingleTickerProviderStateMixin {
  late final DropdownSelectorController _controller;

  VoidCallback? _removeChangeListener;
  VoidCallback? _removeApplyListener;
  VoidCallback? _removeResetListener;

  @override
  void initState() {
    super.initState();
    _controller = DropdownSelectorController();
    _controller.addListener(_handleControllerTick);
    _removeChangeListener = _controller.addChangeListener(_handleWidgetChange);
    _removeApplyListener = _controller.addApplyListener(_handleWidgetApply);
    _removeResetListener = _controller.addResetListener(_handleWidgetReset);
    _controller.attachSelectorDelegates([widget.selectorDelegate]);
    _controller.attachTickerProvider(this);
    _controller.tabDataMap[0] = DropdownTabData(
      index: 0,
      originalLabel: widget.label,
    );
  }

  @override
  void didUpdateWidget(covariant DropdownSelectorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.attachSelectorDelegates([widget.selectorDelegate]);
    _controller.attachTickerProvider(this);
    if (oldWidget.label != widget.label) {
      final tabData = _controller.tabDataMap[0];
      if (tabData != null) {
        tabData.originalLabel = widget.label;
      } else {
        _controller.tabDataMap[0] = DropdownTabData(
          index: 0,
          originalLabel: widget.label,
        );
      }
      _controller.notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerTick);
    _removeChangeListener?.call();
    _removeApplyListener?.call();
    _removeResetListener?.call();
    _controller.hideSelector(immediate: true);
    _controller.detachTickerProvider();
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerTick() => setState(() {});

  void _handleWidgetChange(DropdownSelectorResult result) =>
      widget.onChanged?.call(result);

  void _handleWidgetApply(DropdownSelectorResult result) =>
      widget.onApplied?.call(result);

  void _handleWidgetReset() => widget.onReset?.call();

  Future<void> _handleTap() async {
    final tabData = _controller.tabDataMap[0];
    final willShow = !_controller.isSelectorShowing;
    bool proceed = true;
    if (tabData != null) {
      proceed = willShow
          ? await widget.onSelectorWillShow?.call(tabData) ?? true
          : await widget.onSelectorWillHide?.call(tabData) ?? true;
    }
    if (!proceed) return;
    _controller.previousSelectorDelegate = widget.selectorDelegate;
    _controller.toggleSelector(index: 0);
    if (tabData == null) {
      return;
    }
    if (_controller.isSelectorShowing) {
      widget.onSelectorShowed?.call(tabData);
    } else {
      widget.onSelectorHidden?.call(tabData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DropdownSelectorButtonTheme defaults =
        _DropdownSelectorButtonDefaults(context, widget.variant);
    final DropdownSelectorButtonTheme? theme =
        DropdownSelectorButtonTheme.maybeOf(context);

    final resolved = defaults.copyWith(
      backgroundColor: theme?.backgroundColor,
      foregroundColor: theme?.foregroundColor,
      overlayColor: theme?.overlayColor,
      shadowColor: theme?.shadowColor,
      surfaceTintColor: theme?.surfaceTintColor,
      side: theme?.side,
      shape: theme?.shape,
      textStyle: theme?.textStyle,
      iconColor: theme?.iconColor,
      padding: theme?.padding,
      elevation: theme?.elevation,
      overlayStyle: theme?.overlayStyle,
      selectorTheme: theme?.selectorTheme,
    );

    final overlayStyle = widget.overlayStyle ?? resolved.overlayStyle;
    final effectiveSelectorTheme = resolved.selectorTheme;

    final localizations = SelectorLocalizations.of(context);
    _controller.applyMultipleText = localizations?.multiple ?? 'Multiple';

    return SelectorOverlayHost(
      controller: _controller,
      direction: widget.direction,
      style: overlayStyle,
      selectorTheme: effectiveSelectorTheme,
      minWidthFromTrigger: true,
      triggerChild: _buildButton(context, resolved),
    );
  }

  Widget _buildButton(
      BuildContext context, DropdownSelectorButtonTheme resolved) {
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = resolved.backgroundColor!;
    final foregroundColor = resolved.foregroundColor!;
    final elevation = resolved.elevation!;
    final side = resolved.side!;
    final baseShape = resolved.shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        );
    final shape = baseShape.copyWith(side: side);
    final BorderRadius inkBorderRadius = baseShape is RoundedRectangleBorder
        ? baseShape.borderRadius.resolve(TextDirection.ltr)
        : BorderRadius.circular(8.0);
    final textStyle = resolved.textStyle ?? textTheme.labelLarge!;
    final iconColor = resolved.iconColor ?? foregroundColor;
    final padding = resolved.padding ??
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    final splash = resolved.overlayColor ?? foregroundColor.withOpacity(0.12);

    final icon = widget.icon ?? const Icon(Icons.arrow_drop_down, size: 20);

    final labelText = _controller.tabDataMap[0]?.label ?? widget.label ?? '';

    final content = widget.child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                labelText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4.0),
            RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.5).animate(
                CurvedAnimation(
                  parent: _controller.overlayAnimation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: IconTheme(
                data: IconThemeData(color: iconColor, size: 20),
                child: icon,
              ),
            ),
          ],
        );

    return Material(
      color: backgroundColor,
      elevation: elevation,
      shadowColor: resolved.shadowColor,
      surfaceTintColor: resolved.surfaceTintColor,
      shape: shape,
      type: widget.variant == DropdownSelectorButtonVariant.outlined
          ? MaterialType.transparency
          : MaterialType.button,
      child: InkWell(
        onTap: _handleTap,
        splashColor: splash,
        highlightColor: splash.withOpacity(0.5),
        borderRadius: inkBorderRadius,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: textStyle.copyWith(color: foregroundColor),
            child: IconTheme(
              data: IconThemeData(color: iconColor),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownSelectorButtonDefaults extends DropdownSelectorButtonTheme {
  _DropdownSelectorButtonDefaults(this.context, this.variant)
      : super(
          elevation:
              variant == DropdownSelectorButtonVariant.elevated ? 1.0 : 0.0,
        );

  final BuildContext context;
  final DropdownSelectorButtonVariant variant;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor {
    switch (variant) {
      case DropdownSelectorButtonVariant.elevated:
        return _colors.surfaceContainerLow;
      case DropdownSelectorButtonVariant.filled:
        return _colors.primary;
      case DropdownSelectorButtonVariant.outlined:
        return Colors.transparent;
    }
  }

  @override
  Color? get foregroundColor {
    switch (variant) {
      case DropdownSelectorButtonVariant.elevated:
        return _colors.onSurface;
      case DropdownSelectorButtonVariant.filled:
        return _colors.onPrimary;
      case DropdownSelectorButtonVariant.outlined:
        return _colors.primary;
    }
  }

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor =>
      variant == DropdownSelectorButtonVariant.elevated
          ? _colors.surfaceTint
          : null;

  @override
  BorderSide? get side {
    if (variant == DropdownSelectorButtonVariant.outlined) {
      return BorderSide(color: _colors.outline);
    }
    return BorderSide.none;
  }

  @override
  OutlinedBorder? get shape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      );

  @override
  TextStyle? get textStyle => _textTheme.labelLarge;

  @override
  Color? get iconColor => foregroundColor;

  @override
  EdgeInsetsGeometry? get padding =>
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  @override
  Color? get overlayColor => foregroundColor?.withOpacity(0.12);
}

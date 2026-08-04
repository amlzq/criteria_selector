import 'dart:async';

import 'package:flutter/material.dart';

import 'dropdown_overlay.dart';
import 'dropdown_overlay_style.dart';
import 'i18n/localizations.dart';
import 'popup_select_button_theme.dart';
import 'popup_select_controller.dart';
import 'selector/select_entry.dart';
import 'selector/selector_delegate.dart';
import 'selector_label_state.dart';
import 'selector_overlay_host.dart';

/// Visual variants for [PopupSelectButton].
enum PopupSelectButtonVariant {
  /// A button with elevation and a subtle surface tint (like [ElevatedButton]).
  elevated,

  /// A filled button using the color scheme primary (like [FilledButton]).
  filled,

  /// A button with a transparent background and an outline border
  /// (like [OutlinedButton]).
  outlined,
}

/// Callback invoked with the selected entries only — used by
typedef PopupSelectButtonResultCallback = void Function(SelectEntries selected);

typedef PopupSelectButtonWillToggleCallback = FutureOr<bool> Function();

/// Default height used when the button size cannot be measured yet.
const kPopupSelectButtonHeight = 40.0;

/// Deprecated alias for [PopupSelectButtonVariant].
///
/// Use [PopupSelectButtonVariant] instead. This alias is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectButtonVariant instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorButtonVariant = PopupSelectButtonVariant;

/// Deprecated alias for [PopupSelectButtonResultCallback].
///
/// Use [PopupSelectButtonResultCallback] instead. This alias is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectButtonResultCallback instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorButtonResultCallback = PopupSelectButtonResultCallback;

/// Deprecated alias for [PopupSelectButtonWillToggleCallback].
///
/// Use [PopupSelectButtonWillToggleCallback] instead. This alias is kept only
/// for backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectButtonWillToggleCallback instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorButtonWillToggleCallback
    = PopupSelectButtonWillToggleCallback;

/// Deprecated alias for [kPopupSelectButtonHeight].
///
/// Use [kPopupSelectButtonHeight] instead. This alias is kept only for backward
/// compatibility and will be removed in a future minor version.
@Deprecated(
  'Use kPopupSelectButtonHeight instead. '
  'This alias will be removed in a future minor version.',
)
const kDropdownSelectorButtonHeight = kPopupSelectButtonHeight;

/// A single-button alternative to [PopupSelectBar].
///
/// Where [PopupSelectBar] renders a horizontal row of tabs, this widget
/// exposes a single trigger styled like a Material button (one of
/// [PopupSelectButtonVariant]) that opens the selector overlay on tap,
/// similar to [PopupMenuButton]. The interaction (overlay positioning,
/// animation, dismissal on outside tap, auto-close on apply) is driven by the
/// same [PopupSelectController] machinery as [PopupSelectBar].
///
/// Provide a [selectorDelegate] to define the selector content, and a [label]
/// or [child] for the trigger. The trailing [icon] rotates while the overlay is
/// open. After an apply, the button label is updated with the resulting label.
class PopupSelectButton extends StatefulWidget {
  /// Creates a filled button (the default variant).
  const PopupSelectButton({
    super.key,
    required this.selectorDelegate,
    this.variant = PopupSelectButtonVariant.filled,
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
    this.labelLoader,
    this.direction = PopupSelectDirection.below,
  }) : assert(label == null || child == null,
            'Provide either label or child, not both.');

  /// Creates an elevated button. The [variant] is fixed to
  /// [PopupSelectButtonVariant.elevated].
  const PopupSelectButton.elevated({
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
    this.labelLoader,
    this.direction = PopupSelectDirection.below,
  })  : variant = PopupSelectButtonVariant.elevated,
        assert(label == null || child == null,
            'Provide either label or child, not both.');

  /// Creates an outlined button. The [variant] is fixed to
  /// [PopupSelectButtonVariant.outlined].
  const PopupSelectButton.outlined({
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
    this.labelLoader,
    this.direction = PopupSelectDirection.below,
  })  : variant = PopupSelectButtonVariant.outlined,
        assert(label == null || child == null,
            'Provide either label or child, not both.');

  /// Selector configuration for the single trigger.
  final SelectorDelegate selectorDelegate;

  /// Visual style of the trigger button.
  final PopupSelectButtonVariant variant;

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
  final VoidCallback? onSelectorShowed;

  /// Fired when the selector overlay is hidden.
  final VoidCallback? onSelectorHidden;

  /// Invoked just before the overlay is shown. The returned [Future] (if any)
  /// is awaited before the overlay appears, e.g. to scroll a header into place.
  /// Returning `false` cancels the show, leaving the overlay hidden.
  final PopupSelectButtonWillToggleCallback? onSelectorWillShow;

  /// Invoked just before the overlay is hidden. Returning `false` cancels the
  /// hide, leaving the overlay visible.
  final PopupSelectButtonWillToggleCallback? onSelectorWillHide;

  /// Fired whenever a selector reports a selection change.
  final PopupSelectButtonResultCallback? onChanged;

  /// Fired when a selector is applied.
  final PopupSelectButtonResultCallback? onApplied;

  /// Fired when reset is triggered.
  final VoidCallback? onReset;

  /// Optional custom label loader based on the applied selection result.
  ///
  /// Receives only the selected entries; the canonical [SelectorLabelLoader]
  /// form. When provided, the trigger label is built from the applied selection
  /// instead of the default [label] / result label. Mutually exclusive with
  /// [child] only in spirit — both may be set, but the loaded label replaces
  /// the displayed text.
  final SelectorLabelLoader? labelLoader;

  /// Vertical placement of the selector panel relative to the trigger.
  ///
  /// Defaults to [PopupSelectDirection.below], which always shows the
  /// panel under the trigger. Use [PopupSelectDirection.adaptive] to let
  /// it flip above when there is more room there, or
  /// [PopupSelectDirection.above] to force the panel above. Regardless of
  /// the value, the panel is always kept fully on screen horizontally.
  final PopupSelectDirection direction;

  @override
  State<PopupSelectButton> createState() => _PopupSelectButtonState();
}

class _PopupSelectButtonState extends State<PopupSelectButton>
    with SingleTickerProviderStateMixin {
  late final PopupSelectController _controller;
  final SelectorLabelState _labelState = SelectorLabelState();

  VoidCallback? _removeChangeListener;
  VoidCallback? _removeApplyListener;
  VoidCallback? _removeResetListener;

  @override
  void initState() {
    super.initState();
    _controller = PopupSelectController();
    _controller.addListener(_handleControllerTick);
    _removeChangeListener = _controller.addChangeListener(_handleWidgetChange);
    _removeApplyListener = _controller.addApplyListener(_handleWidgetApply);
    _removeResetListener = _controller.addResetListener(_handleWidgetReset);
    _controller.attachSelectorDelegates([widget.selectorDelegate]);
    _controller.attachTickerProvider(this);
    _labelState.originalLabel = widget.label;
    _labelState.labelLoader = widget.labelLoader;
    _controller.labelStateMap[0] = _labelState;
  }

  @override
  void didUpdateWidget(covariant PopupSelectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.attachSelectorDelegates([widget.selectorDelegate]);
    _controller.attachTickerProvider(this);
    if (oldWidget.label != widget.label) {
      _labelState.originalLabel = widget.label;
      _controller.notifyListeners();
    }
    if (oldWidget.labelLoader != widget.labelLoader) {
      _labelState.labelLoader = widget.labelLoader;
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

  void _handleWidgetChange(
          SelectorLabelState labelState, SelectEntries selected) =>
      widget.onChanged?.call(selected);

  void _handleWidgetApply(
          SelectorLabelState labelState, SelectEntries selected) =>
      widget.onApplied?.call(selected);

  void _handleWidgetReset() => widget.onReset?.call();

  Future<void> _handleTap() async {
    final willShow = !_controller.isSelectorShowing;
    bool proceed = willShow
        ? await widget.onSelectorWillShow?.call() ?? true
        : await widget.onSelectorWillHide?.call() ?? true;
    if (!proceed) return;
    _controller.previousSelectorDelegate = widget.selectorDelegate;
    _controller.toggleSelector(index: 0);
    if (_controller.isSelectorShowing) {
      widget.onSelectorShowed?.call();
    } else {
      widget.onSelectorHidden?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final PopupSelectButtonTheme defaults =
        _PopupSelectButtonDefaults(context, widget.variant);
    final PopupSelectButtonTheme? theme =
        PopupSelectButtonTheme.maybeOf(context);

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

  Widget _buildButton(BuildContext context, PopupSelectButtonTheme resolved) {
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

    final labelText = _labelState.label ?? widget.label ?? '';

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
      type: widget.variant == PopupSelectButtonVariant.outlined
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

class _PopupSelectButtonDefaults extends PopupSelectButtonTheme {
  _PopupSelectButtonDefaults(this.context, this.variant)
      : super(
          elevation: variant == PopupSelectButtonVariant.elevated ? 1.0 : 0.0,
        );

  final BuildContext context;
  final PopupSelectButtonVariant variant;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor {
    switch (variant) {
      case PopupSelectButtonVariant.elevated:
        return _colors.surfaceContainerLow;
      case PopupSelectButtonVariant.filled:
        return _colors.primary;
      case PopupSelectButtonVariant.outlined:
        return Colors.transparent;
    }
  }

  @override
  Color? get foregroundColor {
    switch (variant) {
      case PopupSelectButtonVariant.elevated:
        return _colors.onSurface;
      case PopupSelectButtonVariant.filled:
        return _colors.onPrimary;
      case PopupSelectButtonVariant.outlined:
        return _colors.primary;
    }
  }

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor =>
      variant == PopupSelectButtonVariant.elevated ? _colors.surfaceTint : null;

  @override
  BorderSide? get side {
    if (variant == PopupSelectButtonVariant.outlined) {
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

/// Deprecated alias for [PopupSelectButton].
///
/// Use [PopupSelectButton] instead. This alias is kept only for backward
/// compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectButton instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorButton = PopupSelectButton;

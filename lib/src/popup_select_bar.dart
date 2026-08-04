import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dropdown_overlay.dart';
import 'dropdown_overlay_style.dart';
import 'i18n/localizations.dart';
import 'popup_select_bar_theme.dart';
import 'popup_select_controller.dart';
import 'selector/select_entry.dart';
import 'selector/selector_delegate.dart';
import 'selector/selector_theme_data.dart';
import 'selector_label_state.dart';
import 'selector_overlay_host.dart';

/// Default height for [PopupSelectBar] when no theme override is provided.
const kPopupSelectBarHeight = 44.0;

typedef PopupSelectBarWillToggleCallback = FutureOr<bool> Function(
    PopupTabData tabData);

/// Callback parameter indicates which selector is being shown or hidden.
typedef PopupSelectBarToggleCallback = void Function(PopupTabData tabData);

/// Callback for selection change or apply events from a [PopupSelectBar].
///
/// Receives the tab metadata and the selected entries directly.
typedef PopupSelectBarResultCallback = void Function(
    PopupTabData tabData, SelectEntries selected);

/// Deprecated alias for [kPopupSelectBarHeight].
///
/// Use [kPopupSelectBarHeight] instead. This alias is kept only for backward
/// compatibility and will be removed in a future minor version.
@Deprecated(
  'Use kPopupSelectBarHeight instead. '
  'This alias will be removed in a future minor version.',
)
const kDropdownSelectorBarHeight = kPopupSelectBarHeight;

/// Deprecated alias for [PopupSelectBarWillToggleCallback].
///
/// Use [PopupSelectBarWillToggleCallback] instead. This alias is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectBarWillToggleCallback instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorBarWillToggleCallback
    = PopupSelectBarWillToggleCallback;

/// Deprecated alias for [PopupSelectBarToggleCallback].
///
/// Use [PopupSelectBarToggleCallback] instead. This alias is kept only for
/// backward compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectBarToggleCallback instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorBarToggleCallback = PopupSelectBarToggleCallback;

/// Deprecated alias for [PopupSelectBarResultCallback].
///
/// Use [PopupSelectBarResultCallback] instead. This alias is kept only for backward
/// compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectBarResultCallback instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorBarCallback = PopupSelectBarResultCallback;

/// A tab bar that shows an overlay selector panel when a tab is tapped.
///
/// Provide:
/// - [tabs] to render the bar UI.
/// - [selectorDelegates] to define the selector configuration for each tab.
///
/// The overlay content is driven by [PopupSelectController] and the selected
/// results are delivered via [onChanged] and [onApplied].
class PopupSelectBar extends StatefulWidget implements PreferredSizeWidget {
  const PopupSelectBar({
    super.key,
    required this.tabs,
    this.selectorDelegates = const [],
    this.height,
    this.isScrollable = false,
    this.backgroundColor,
    this.elevation = 0.0,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.indicator,
    this.unselectedIndicator,
    this.overlayStyle,
    this.onSelectorShowed,
    this.onSelectorHidden,
    this.onSelectorWillShow,
    this.onSelectorWillHide,
    this.onChanged,
    this.onApplied,
    this.onReset,
    this.controller,
    this.initialIndex,
    this.selectorTheme,
    this.direction = PopupSelectDirection.below,
  });

  /// The set of tabs to display in the bar.
  ///
  /// Each entry renders a tab's UI and must have a matching entry in
  /// [selectorDelegates]; the number of [tabs] must equal the number of
  /// [selectorDelegates].
  final List<PopupTab> tabs;

  /// Selector configuration for each tab.
  final List<SelectorDelegate> selectorDelegates;

  /// The height of the [PopupSelectBar] itself.
  ///
  /// If null, [PopupSelectBarTheme.height] is used. If that
  /// is also null, the default is [kPopupSelectBarHeight].
  final double? height;

  final bool isScrollable;

  /// The color of the [PopupSelectBar] itself.
  ///
  /// If null, [PopupSelectBarTheme.backgroundColor] is used. If that
  /// is also null, the value is [ColorScheme.surfaceContainer].
  final Color? backgroundColor;

  final double elevation;

  final Color? labelColor;

  final Color? unselectedLabelColor;

  final TextStyle? labelStyle;

  final TextStyle? unselectedLabelStyle;

  final Widget? indicator;

  final Widget? unselectedIndicator;

  final PopupSelectBarToggleCallback? onSelectorShowed;

  final PopupSelectBarToggleCallback? onSelectorHidden;

  /// Invoked just before the overlay is shown for a tab.
  ///
  /// The returned [Future] (if any) is awaited before the overlay appears, so
  /// async work such as scrolling a [SliverPersistentHeader] to the top can
  /// finish first and the overlay is positioned against the final layout.
  /// Returning `false` cancels the show, leaving the overlay hidden.
  final PopupSelectBarWillToggleCallback? onSelectorWillShow;

  /// Invoked just before the overlay is hidden for a tab. Returning `false`
  /// cancels the hide, leaving the overlay visible.
  final PopupSelectBarWillToggleCallback? onSelectorWillHide;

  /// Fired whenever a selector reports a selection change.
  final PopupSelectBarResultCallback? onChanged;

  /// Fired when a selector is applied.
  final PopupSelectBarResultCallback? onApplied;

  /// Fired when reset is triggered.
  final VoidCallback? onReset;

  /// Controls selector overlay visibility and tab state.
  final PopupSelectController? controller;

  /// If not null, the initial index of the selected tab and show selector.
  final int? initialIndex;

  /// Visual configuration for the selector overlay panel.
  ///
  /// If null, [PopupSelectBarTheme.overlayStyle] is used.
  final DropdownOverlayStyle? overlayStyle;

  /// Theme overrides applied to selector widgets inside the overlay.
  final SelectorThemeData? selectorTheme;

  /// Vertical placement of the selector panel relative to the bar.
  ///
  /// Defaults to [PopupSelectDirection.below], which always shows the
  /// panel under the trigger. Use [PopupSelectDirection.adaptive] to let
  /// it flip above when there is more room there, or
  /// [PopupSelectDirection.above] to force the panel above. Regardless of
  /// the value, the panel is always kept fully on screen horizontally.
  final PopupSelectDirection direction;

  @override
  State<PopupSelectBar> createState() => _PopupSelectBarState();

  @override
  Size get preferredSize {
    double maxHeight = kPopupSelectBarHeight;
    for (final Widget item in tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return Size.fromHeight(maxHeight);
  }
}

class _PopupSelectBarState extends State<PopupSelectBar>
    with SingleTickerProviderStateMixin {
  PopupSelectController? _controller;
  int? _previousIndex;

  VoidCallback? _removeChangeListener;
  VoidCallback? _removeApplyListener;
  VoidCallback? _removeResetListener;

  // late List<SelectorController> _selectorControllers;

  bool _debugHasScheduledValidSelectorCountCheck = false;

  @override
  void initState() {
    super.initState();
    // _controller.onChanged = widget.onChanged;
    // _controller.onApplied = widget.onApplied;
    // _controller.onReset = widget.onReset;
  }

  @override
  void dispose() {
    // _controller.detachBarContext();
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_handlePopupSelectControllerTick);
      _removeChangeListener?.call();
      _removeApplyListener?.call();
      _removeResetListener?.call();
      controller.hideSelector(immediate: true);
      controller.detachTickerProvider();
      if (widget.controller == null) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePopupSelectController(context);
  }

  @override
  void didUpdateWidget(covariant PopupSelectBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePopupSelectController(context);
  }

  void _updatePopupSelectController(BuildContext context) {
    if (_controller == null) {
      _controller = widget.controller ?? PopupSelectController();
      _controller!.addListener(_handlePopupSelectControllerTick);
      _removeChangeListener =
          _controller!.addChangeListener(_handleWidgetChange);
      _removeApplyListener = _controller!.addApplyListener(_handleWidgetApply);
      _removeResetListener = _controller!.addResetListener(_handleWidgetReset);
    }
    _controller!.attachSelectorDelegates(widget.selectorDelegates);
    _controller!.attachTickerProvider(this);
  }

  void _handlePopupSelectControllerTick() {
    if (_previousIndex != _controller?.currentIndex) {
      _previousIndex = _controller?.currentIndex;
    }
    setState(() {});
  }

  void _handleWidgetChange(
          SelectorLabelState labelState, SelectEntries selected) =>
      widget.onChanged?.call(labelState as PopupTabData, selected);

  void _handleWidgetApply(
          SelectorLabelState labelState, SelectEntries selected) =>
      widget.onApplied?.call(labelState as PopupTabData, selected);

  void _handleWidgetReset() => widget.onReset?.call();

  Future<void> _handleTap(PopupTabData tabData) async {
    // final barHeight = _getBarHeight;

    // Tapping a collapsed tab (or switching to a different one) will show the
    // overlay; tapping the already-expanded tab will hide it. Resolve the
    // intent before toggling so the matching pre-hook can run first.
    final willShow = !_controller!.isSelectorShowing ||
        _controller!.currentIndex != tabData.index;

    final proceed = willShow
        ? await widget.onSelectorWillShow?.call(tabData) ?? true
        : await widget.onSelectorWillHide?.call(tabData) ?? true;
    if (!proceed) return;

    final selector = widget.selectorDelegates.elementAt(tabData.index);
    _controller!.previousSelectorDelegate = selector;

    _controller!.toggleSelector(index: tabData.index);

    if (_controller!.isSelectorShowing) {
      widget.onSelectorShowed?.call(tabData);
    } else {
      widget.onSelectorHidden?.call(tabData);
    }

    // _controller.tabDataMap[index] = model;

    // _controller.toggle(barHeight, tabData);

    // return widget.onSelectorDone != null
    //     ? () => widget.onSelectorDone!(index)
    //     : () {};
  }

  // double get _barHeight {
  //   final PopupSelectBarTheme defaults = _PopupSelectBarDefaults(context);
  //   final PopupSelectBarTheme? inheritedTheme =
  //       PopupSelectBarTheme.maybeOf(context);
  //   return widget.height ?? inheritedTheme?.height ?? defaults.height!;
  // }

  bool _debugScheduleCheckHasValidSelectorCount() {
    if (_debugHasScheduledValidSelectorCountCheck) {
      return true;
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      _debugHasScheduledValidSelectorCountCheck = false;
      if (!mounted) {
        return;
      }
      assert(() {
        if (widget.tabs.length != widget.selectorDelegates.length) {
          throw FlutterError(
            "The number of tabs (${widget.tabs.length}) in the PopupSelectBar does not match "
            "the number of selectorDelegates(${widget.selectorDelegates.length}).",
          );
        }
        return true;
      }());
    }, debugLabel: 'PopupSelectBar.validSelectorCountCheck');
    _debugHasScheduledValidSelectorCountCheck = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugScheduleCheckHasValidSelectorCount());

    final PopupSelectBarTheme defaults = _PopupSelectBarDefaults(context);
    final PopupSelectBarTheme? theme = PopupSelectBarTheme.maybeOf(context);

    final height = widget.height ?? theme?.height ?? defaults.height!;

    final overlayStyle = widget.overlayStyle ?? theme?.overlayStyle;

    final effectiveSelectorTheme = widget.selectorTheme ?? theme?.selectorTheme;

    final localizations = SelectorLocalizations.of(context);

    final effectiveMultipleText = localizations?.multiple ?? 'Multiple';

    _controller!.applyMultipleText = effectiveMultipleText;

    return SelectorOverlayHost(
      controller: _controller!,
      direction: widget.direction,
      style: overlayStyle,
      selectorTheme: effectiveSelectorTheme,
      triggerChild: Material(
        color: widget.backgroundColor ??
            theme?.backgroundColor ??
            defaults.backgroundColor!,
        elevation: widget.elevation,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Builder(
            builder: (context) {
              final tabs = <Widget>[
                for (int i = 0; i < widget.tabs.length; i++)
                  _PopupSelectTabInfo(
                    index: i,
                    onTap: (tabData) => _handleTap(tabData),
                    indicator: widget.indicator,
                    unselectedIndicator: widget.unselectedIndicator,
                    child: _PopupSelectTabStyle(
                      isSelected: (_controller?.isSelectorShowing == true &&
                              _controller!.currentIndex == i) ||
                          _controller?.labelStateMap[i]?.isResulted == true,
                      labelColor: widget.labelColor,
                      unselectedLabelColor: widget.unselectedLabelColor,
                      labelStyle: widget.labelStyle,
                      unselectedLabelStyle: widget.unselectedLabelStyle,
                      defaults: defaults,
                      child: widget.tabs[i],
                    ),
                  ),
              ];

              final row = Row(
                mainAxisSize:
                    widget.isScrollable ? MainAxisSize.min : MainAxisSize.max,
                children: widget.isScrollable
                    ? tabs
                    : tabs.map((t) => Expanded(child: t)).toList(),
              );

              if (!widget.isScrollable) {
                return row;
              }

              return ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: row,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PopupSelectTabStyle extends StatelessWidget {
  const _PopupSelectTabStyle({
    required this.isSelected,
    required this.labelColor,
    required this.unselectedLabelColor,
    required this.labelStyle,
    required this.unselectedLabelStyle,
    required this.defaults,
    required this.child,
  });

  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool isSelected;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final PopupSelectBarTheme defaults;
  final Widget child;

  WidgetStateColor _resolveWithLabelColor(BuildContext context) {
    final PopupSelectBarTheme? theme = PopupSelectBarTheme.maybeOf(context);

    Color selectedColor = labelColor ??
        theme?.labelColor ??
        labelStyle?.color ??
        theme?.labelStyle?.color ??
        defaults.labelColor!;

    final Color unselectedColor;

    if (selectedColor is WidgetStateColor) {
      unselectedColor = selectedColor.resolve(const <WidgetState>{});
      selectedColor =
          selectedColor.resolve(const <WidgetState>{WidgetState.selected});
    } else {
      unselectedColor = unselectedLabelColor ??
          theme?.unselectedLabelColor ??
          unselectedLabelStyle?.color ??
          theme?.unselectedLabelStyle?.color ??
          defaults.unselectedLabelColor!;
    }

    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return selectedColor;
      }
      return unselectedColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PopupSelectBarTheme? theme = PopupSelectBarTheme.maybeOf(context);

    final Set<WidgetState> states = isSelected
        ? const <WidgetState>{WidgetState.selected}
        : const <WidgetState>{};

    // To enable TextStyle.lerp(style1, style2, value), both styles must have
    // the same value of inherit. Force that to be inherit=true here.
    final TextStyle effectiveLabelStyle =
        (labelStyle ?? theme?.labelStyle ?? defaults.labelStyle!)
            .copyWith(inherit: true);

    final TextStyle effectiveUnselectedLabelStyle = (unselectedLabelStyle ??
            theme?.unselectedLabelStyle ??
            defaults.unselectedLabelStyle!)
        .copyWith(inherit: true);

    final Color color = _resolveWithLabelColor(context).resolve(states);

    // return DefaultTextStyle(
    //   style: textStyle.copyWith(color: color),
    //   child: IconTheme.merge(
    //     data: IconThemeData(color: color),
    //     child: child,
    //   ),
    // );

    // Note: Use ColorFiltered to color the child widgets, so that both Text Icon and Image

    return DefaultTextStyle(
      style: isSelected ? effectiveLabelStyle : effectiveUnselectedLabelStyle,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: child,
      ),
    );
  }
}

/// A tab widget used inside [PopupSelectBar].
///
/// Provide either [label] or [child]. Use [labelLoader] to compute a custom
/// label from the applied selection result.
class PopupTab extends StatelessWidget {
  /// The text label shown in the tab.
  ///
  /// Mutually exclusive with [child]; providing both triggers an assertion.
  final String? label;

  /// An optional loader that builds the label from the current selection
  /// result.
  ///
  /// Receives only the selected entries; the canonical [SelectorLabelLoader]
  /// form.
  final SelectorLabelLoader? labelLoader;

  /// A custom widget displayed in the tab instead of [label].
  ///
  /// Mutually exclusive with [label]; providing both triggers an assertion.
  final Widget? child;

  /// An optional tag used to identify this tab.
  final String? tag;

  const PopupTab({
    super.key,
    this.label,
    this.labelLoader,
    this.child,
    this.tag,
  }) : assert(label == null || child == null,
            'Either provide a label or an child, not both.');

  @override
  Widget build(BuildContext context) {
    final PopupSelectBarTheme defaults = _PopupSelectBarDefaults(context);
    final PopupSelectBarTheme? theme = PopupSelectBarTheme.maybeOf(context);

    final PopupSelectController controller = PopupSelectController.of(context);
    final _PopupSelectTabInfo info = _PopupSelectTabInfo.of(context);
    final unselected = controller.currentIndex != info.index;
    final isSelectorShowing = controller.isSelectorShowing;

    PopupTabData? tabData = controller.labelStateMap.containsKey(info.index)
        ? controller.labelStateMap[info.index] as PopupTabData?
        : null;
    if (tabData == null) {
      tabData = PopupTabData(
          index: info.index,
          originalLabel: label,
          tag: tag,
          labelLoader: labelLoader);
      controller.labelStateMap[info.index] = tabData;
    }

    return InkWell(
      onTap: () => info.onTap.call(tabData!),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    tabData.label ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildIndicator(
                  controller,
                  info,
                  theme,
                  defaults,
                  unselected,
                  isSelectorShowing,
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildIndicator(
    PopupSelectController controller,
    _PopupSelectTabInfo info,
    PopupSelectBarTheme? theme,
    PopupSelectBarTheme defaults,
    bool unselected,
    bool isSelectorShowing,
  ) {
    final effectiveIndicator =
        info.indicator ?? theme?.indicator ?? defaults.indicator!;
    final effectiveUnselected = info.unselectedIndicator ??
        theme?.unselectedIndicator ??
        defaults.unselectedIndicator;

    // Non-active tab: show the unselected indicator (fallback to indicator).
    if (unselected) {
      return effectiveUnselected ?? effectiveIndicator;
    }

    // Only indicator provided: rotate 180° driven by the overlay animation
    // (smooth for both opening and closing).
    if (effectiveUnselected == null) {
      return RotationTransition(
        turns: Tween<double>(begin: 0.0, end: 0.5).animate(
          CurvedAnimation(
            parent: controller.overlayAnimation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: effectiveIndicator,
      );
    }

    // Both indicators provided: switch statically based on the expanded state.
    return isSelectorShowing ? effectiveIndicator : effectiveUnselected;
  }
}

class _PopupSelectTabInfo extends InheritedWidget {
  const _PopupSelectTabInfo({
    required this.index,
    required this.onTap,
    required super.child,
    this.indicator,
    this.unselectedIndicator,
  });

  final int index;

  final Widget? indicator;
  final Widget? unselectedIndicator;

  final void Function(PopupTabData tabData) onTap;

  static _PopupSelectTabInfo of(BuildContext context) {
    final _PopupSelectTabInfo? result =
        context.dependOnInheritedWidgetOfExactType<_PopupSelectTabInfo>();
    assert(
      result != null,
      'PopupTab need a _PopupSelectTabInfo parent, '
      'which is usually provided by PopupSelectBar.',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(_PopupSelectTabInfo oldWidget) {
    return index != oldWidget.index || onTap != oldWidget.onTap;
  }
}

class _PopupSelectBarDefaults extends PopupSelectBarTheme {
  _PopupSelectBarDefaults(this.context) : super(height: kPopupSelectBarHeight);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  Color? get labelColor => _colors.primary;

  @override
  TextStyle? get labelStyle => _textTheme.titleSmall;

  @override
  Color? get unselectedLabelColor => _colors.onSurface;

  @override
  TextStyle? get unselectedLabelStyle => _textTheme.titleSmall;

  @override
  Widget? get indicator => const Icon(Icons.arrow_drop_down);

  // @override
  // WidgetStateProperty<TextStyle?>? get labelStyle {
  //   // TextTheme.titleSmall
  //   return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  //     final TextStyle style = _textTheme.labelMedium!;
  //     return style.apply(
  //         color: states.contains(WidgetState.disabled)
  //             ? _colors.onSurfaceVariant.withOpacity(0.38)
  //             : states.contains(WidgetState.selected)
  //                 ? _colors.onSurface
  //                 : _colors.onSurfaceVariant);
  //   });
  // }
}

/// Deprecated alias for [PopupSelectBar].
///
/// Use [PopupSelectBar] instead. This alias is kept only for backward
/// compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupSelectBar instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownSelectorBar = PopupSelectBar;

/// Deprecated alias for [PopupTab].
///
/// Use [PopupTab] instead. This alias is kept only for backward
/// compatibility and will be removed in a future minor version.
@Deprecated(
  'Use PopupTab instead. '
  'This alias will be removed in a future minor version.',
)
typedef DropdownTab = PopupTab;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dropdown_overlay.dart';
import 'dropdown_overlay_style.dart';
import 'dropdown_selector_bar_theme.dart';
import 'dropdown_selector_controller.dart';
import 'dropdown_tab_data.dart';
import 'i18n/localizations.dart';
import 'selector/constants.dart';
import 'selector/selector_delegate.dart';
import 'selector/selector_theme_data.dart';
import 'selector_overlay_host.dart';

/// Default height for [DropdownSelectorBar] when no theme override is provided.
const kDropdownSelectorBarHeight = 44.0;

/// A tab bar that shows an overlay selector panel when a tab is tapped.
///
/// Provide:
/// - [tabs] to render the bar UI.
/// - [selectorDelegates] to define the selector configuration for each tab.
///
/// The overlay content is driven by [DropdownSelectorController] and the selected
/// results are delivered via [onChanged] and [onApplied].
class DropdownSelectorBar extends StatefulWidget
    implements PreferredSizeWidget {
  const DropdownSelectorBar({
    super.key,
    required this.tabs,
    @Deprecated(
      'Use [selectorDelegates] instead. The type and behavior are identical; '
      'simply rename the parameter. This parameter will be removed in a future '
      'major version.',
    )
    List<SelectorDelegate>? selectors,
    List<SelectorDelegate>? selectorDelegates,
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
    this.direction = DropdownSelectorDirection.below,
  })  : assert(selectorDelegates != null || selectors != null,
            'Either selectorDelegates or selectors must be provided.'),
        selectorDelegates = selectorDelegates ?? selectors ?? const [];

  final List<DropdownTab> tabs;

  /// Selector configuration for each tab.
  final List<SelectorDelegate> selectorDelegates;

  /// The height of the [DropdownSelectorBar] itself.
  ///
  /// If null, [DropdownSelectorBarTheme.height] is used. If that
  /// is also null, the default is [kDropdownSelectorBarHeight].
  final double? height;

  final bool isScrollable;

  /// The color of the [DropdownSelectorBar] itself.
  ///
  /// If null, [DropdownSelectorBarTheme.backgroundColor] is used. If that
  /// is also null, the value is [ColorScheme.surfaceContainer].
  final Color? backgroundColor;

  final double elevation;

  final Color? labelColor;
  final Color? unselectedLabelColor;

  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  final Widget? indicator;
  final Widget? unselectedIndicator;

  final SelectorVisibilityCallback? onSelectorShowed;
  final SelectorVisibilityCallback? onSelectorHidden;

  /// Invoked just before the overlay is shown for a tab.
  ///
  /// The returned [Future] (if any) is awaited before the overlay appears, so
  /// async work such as scrolling a [SliverPersistentHeader] to the top can
  /// finish first and the overlay is positioned against the final layout.
  /// Returning `false` cancels the show, leaving the overlay hidden.
  final SelectorWillShowCallback? onSelectorWillShow;

  /// Invoked just before the overlay is hidden for a tab. Returning `false`
  /// cancels the hide, leaving the overlay visible.
  final SelectorWillHideCallback? onSelectorWillHide;

  /// Fired whenever a selector reports a selection change.
  final DropdownSelectorResultCallback? onChanged;

  /// Fired when a selector is applied.
  final DropdownSelectorResultCallback? onApplied;

  /// Fired when reset is triggered.
  final VoidCallback? onReset;

  /// Controls selector overlay visibility and tab state.
  final DropdownSelectorController? controller;

  /// If not null, the initial index of the selected tab and show selector.
  final int? initialIndex;

  final DropdownOverlayStyle? overlayStyle;

  /// Theme overrides applied to selector widgets inside the overlay.
  final SelectorThemeData? selectorTheme;

  /// Vertical placement of the selector panel relative to the bar.
  ///
  /// Defaults to [DropdownSelectorDirection.below], which always shows the
  /// panel under the trigger. Use [DropdownSelectorDirection.adaptive] to let
  /// it flip above when there is more room there, or
  /// [DropdownSelectorDirection.above] to force the panel above. Regardless of
  /// the value, the panel is always kept fully on screen horizontally.
  final DropdownSelectorDirection direction;

  @override
  State<DropdownSelectorBar> createState() => _DropdownSelectorBarState();

  @override
  Size get preferredSize {
    double maxHeight = kDropdownSelectorBarHeight;
    for (final Widget item in tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return Size.fromHeight(maxHeight);
  }
}

class _DropdownSelectorBarState extends State<DropdownSelectorBar>
    with SingleTickerProviderStateMixin {
  DropdownSelectorController? _controller;
  int? _previousIndex;

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
      controller.removeListener(_handleDropdownSelectorControllerTick);
      controller.hideSelector(immediate: true);
      controller.detachTickerProvider();
      controller.onChanged = null;
      controller.onApplied = null;
      controller.onReset = null;
      if (widget.controller == null) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDropdownSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant DropdownSelectorBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDropdownSelectorController(context);
  }

  void _updateDropdownSelectorController(BuildContext context) {
    if (_controller == null) {
      _controller = widget.controller ?? DropdownSelectorController();
      _controller!.addListener(_handleDropdownSelectorControllerTick);
      _controller!.onChanged = widget.onChanged;
      _controller!.onApplied = widget.onApplied;
      _controller!.onReset = widget.onReset;
    }
    _controller!.attachSelectorDelegates(widget.selectorDelegates);
    _controller!.attachTickerProvider(this);
  }

  void _handleDropdownSelectorControllerTick() {
    if (_previousIndex != _controller?.currentIndex) {
      _previousIndex = _controller?.currentIndex;
    }
    setState(() {});
  }

  Future<void> _handleTap(DropdownTabData tabData) async {
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
  //   final DropdownSelectorBarTheme defaults = _DropdownSelectorBarDefaults(context);
  //   final DropdownSelectorBarTheme? inheritedTheme =
  //       DropdownSelectorBarTheme.maybeOf(context);
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
            "The number of tabs (${widget.tabs.length}) in the DropdownSelectorBar does not match "
            "the number of selectorDelegates(${widget.selectorDelegates.length}).",
          );
        }
        return true;
      }());
    }, debugLabel: 'DropdownSelectorBar.validSelectorCountCheck');
    _debugHasScheduledValidSelectorCountCheck = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugScheduleCheckHasValidSelectorCount());

    final DropdownSelectorBarTheme defaults =
        _DropdownSelectorBarDefaults(context);
    final DropdownSelectorBarTheme? theme =
        DropdownSelectorBarTheme.maybeOf(context);

    final height = widget.height ?? theme?.height ?? defaults.height!;

    final overlayStyle = widget.overlayStyle ?? theme?.overlayStyle;

    final effectiveSelectorTheme = widget.selectorTheme ?? theme?.selectorTheme;

    final localizations = CriteriaSelectorLocalizations.of(context);

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
                  _DropdownSelectorTabInfo(
                    index: i,
                    onTap: (tabData) => _handleTap(tabData),
                    indicator: widget.indicator,
                    unselectedIndicator: widget.unselectedIndicator,
                    child: _DropdownSelectorTabStyle(
                      isSelected: (_controller?.isSelectorShowing == true &&
                              _controller!.currentIndex == i) ||
                          _controller?.tabDataMap[i]?.isResulted == true,
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

class _DropdownSelectorTabStyle extends StatelessWidget {
  const _DropdownSelectorTabStyle({
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
  final DropdownSelectorBarTheme defaults;
  final Widget child;

  WidgetStateColor _resolveWithLabelColor(BuildContext context) {
    final DropdownSelectorBarTheme? theme =
        DropdownSelectorBarTheme.maybeOf(context);

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
    final DropdownSelectorBarTheme? theme =
        DropdownSelectorBarTheme.maybeOf(context);

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

/// A tab widget used inside [DropdownSelectorBar].
///
/// Provide either [label] or [child]. Use [labelGetter] to compute a custom
/// label from the applied selection result.
class DropdownTab extends StatelessWidget {
  final String? label;

  final DropdownTabLabelGetter? labelGetter;

  final Widget? child;

  final String? tag;

  const DropdownTab({
    super.key,
    this.label,
    this.labelGetter,
    this.child,
    this.tag,
  }) : assert(label == null || child == null,
            'Either provide a label or an child, not both.');

  @override
  Widget build(BuildContext context) {
    final DropdownSelectorBarTheme defaults =
        _DropdownSelectorBarDefaults(context);
    final DropdownSelectorBarTheme? theme =
        DropdownSelectorBarTheme.maybeOf(context);

    final DropdownSelectorController controller =
        DropdownSelectorController.of(context);
    final _DropdownSelectorTabInfo info = _DropdownSelectorTabInfo.of(context);
    final unselected = controller.currentIndex != info.index;
    final isSelectorShowing = controller.isSelectorShowing;

    DropdownTabData? tabData = controller.tabDataMap.containsKey(info.index)
        ? controller.tabDataMap[info.index]
        : null;
    if (tabData == null) {
      tabData = DropdownTabData(
          index: info.index,
          originalLabel: label,
          tag: tag,
          labelGetter: labelGetter);
      controller.tabDataMap[info.index] = tabData;
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
    DropdownSelectorController controller,
    _DropdownSelectorTabInfo info,
    DropdownSelectorBarTheme? theme,
    DropdownSelectorBarTheme defaults,
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

class _DropdownSelectorTabInfo extends InheritedWidget {
  const _DropdownSelectorTabInfo({
    required this.index,
    required this.onTap,
    required super.child,
    this.indicator,
    this.unselectedIndicator,
  });

  final int index;

  final Widget? indicator;
  final Widget? unselectedIndicator;

  final void Function(DropdownTabData tabData) onTap;

  static _DropdownSelectorTabInfo of(BuildContext context) {
    final _DropdownSelectorTabInfo? result =
        context.dependOnInheritedWidgetOfExactType<_DropdownSelectorTabInfo>();
    assert(
      result != null,
      'DropdownTab need a _DropdownSelectorTabInfo parent, '
      'which is usually provided by DropdownSelectorBar.',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(_DropdownSelectorTabInfo oldWidget) {
    return index != oldWidget.index || onTap != oldWidget.onTap;
  }
}

class _DropdownSelectorBarDefaults extends DropdownSelectorBarTheme {
  _DropdownSelectorBarDefaults(this.context)
      : super(height: kDropdownSelectorBarHeight);

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

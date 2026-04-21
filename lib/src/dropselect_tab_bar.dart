import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'constants.dart';
import 'dropselect_overlay.dart';
import 'dropselect_overlay_style.dart';
import 'dropselect_tab_bar_theme.dart';
import 'dropselect_tab_controller.dart';
import 'dropselect_tab_data.dart';
import 'selector.dart';
import 'selector/selector_theme_data.dart';

/// Default height for [DropselectTabBar] when no theme override is provided.
const kDropselectTabBarHeight = 44.0;

/// A tab bar that shows an overlay selector panel when a tab is tapped.
///
/// Provide:
/// - [tabs] to render the bar UI.
/// - [selectors] to define the selector configuration for each tab.
///
/// The overlay content is driven by [DropselectTabController] and the selected
/// results are delivered via [onChanged] and [onApplied].
class DropselectTabBar extends StatefulWidget implements PreferredSizeWidget {
  const DropselectTabBar({
    super.key,
    required this.tabs,
    required this.selectors,
    this.height,
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
    this.onChanged,
    this.onApplied,
    this.onReset,
    this.controller,
    this.initialIndex,
    this.selectorTheme,
  });

  final List<DropselectTab> tabs;

  /// Selector configuration for each tab.
  final List<Selector> selectors;

  /// The height of the [DropselectTabBar] itself.
  ///
  /// If null, [DropselectTabBarTheme.height] is used. If that
  /// is also null, the default is [kDropselectTabBarHeight].
  final double? height;

  /// The color of the [DropselectTabBar] itself.
  ///
  /// If null, [DropselectTabBarTheme.backgroundColor] is used. If that
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

  /// Fired whenever a selector reports a selection change.
  final DropselectResultCallback? onChanged;

  /// Fired when a selector is applied.
  final DropselectResultCallback? onApplied;

  /// Fired when reset is triggered.
  final VoidCallback? onReset;

  /// Controls selector overlay visibility and tab state.
  final DropselectTabController? controller;

  /// If not null, the initial index of the selected tab and show selector.
  final int? initialIndex;

  final DropselectOverlayStyle? overlayStyle;

  /// Theme overrides applied to selector widgets inside the overlay.
  final SelectorThemeData? selectorTheme;

  @override
  State<DropselectTabBar> createState() => _DropselectTabBarState();

  @override
  Size get preferredSize {
    double maxHeight = kDropselectTabBarHeight;
    for (final Widget item in tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return Size.fromHeight(maxHeight);
  }
}

class _DropselectTabBarState extends State<DropselectTabBar> {
  DropselectTabController? _controller;
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
      controller.removeListener(_handleDropselectTabControllerTick);
      controller.hideSelector();
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
    _updateDropselectTabController(context);
  }

  @override
  void didUpdateWidget(covariant DropselectTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDropselectTabController(context);
  }

  void _updateDropselectTabController(BuildContext context) {
    if (_controller == null) {
      _controller = widget.controller ?? DropselectTabController();
      _controller!.addListener(_handleDropselectTabControllerTick);
      _controller!.onChanged = widget.onChanged;
      _controller!.onApplied = widget.onApplied;
      _controller!.onReset = widget.onReset;
    }
  }

  void _handleDropselectTabControllerTick() {
    if (_previousIndex != _controller?.currentIndex) {
      _previousIndex = _controller?.currentIndex;
    }
    setState(() {});
  }

  void _handleTap(DropselectTabData tabData) {
    debugPrint('DropselectTabBar _handleTap index: ${tabData.index}');

    // final barHeight = _getBarHeight;

    final selector = widget.selectors.elementAt(tabData.index);
    _controller!.previousSelector = selector;

    final data = selector.dataFetcher?.call();
    selector.data = data;

    final selectedData = selector.selectedDataFetcher?.call();
    selector.selectedData = selectedData;

    final resetData = selector.resetDataFetcher?.call();
    selector.resetData = resetData;

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
  //   final DropselectTabBarTheme defaults = _DropselectTabBarDefaults(context);
  //   final DropselectTabBarTheme? inheritedTheme =
  //       DropselectTabBarTheme.maybeOf(context);
  //   return widget.height ?? inheritedTheme?.height ?? defaults.height!;
  // }

  double get _overlayAvailableHeight {
    var availableHeight = 400.0;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return availableHeight;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final barBottom = offset.dy + size.height;

    final screenHeight = MediaQuery.of(context).size.height;

    availableHeight = screenHeight - barBottom;
    return availableHeight;
  }

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
        if (widget.tabs.length != widget.selectors.length) {
          throw FlutterError(
            "The number of tabs (${widget.tabs.length}) in the DropselectTabBar does not match "
            "the number of selectors(${widget.selectors.length}).",
          );
        }
        return true;
      }());
    }, debugLabel: 'DropselectTabBar.validSelectorCountCheck');
    _debugHasScheduledValidSelectorCountCheck = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugScheduleCheckHasValidSelectorCount());

    final DropselectTabBarTheme defaults = _DropselectTabBarDefaults(context);
    final DropselectTabBarTheme? theme = DropselectTabBarTheme.maybeOf(context);

    final height = widget.height ?? theme?.height ?? defaults.height!;

    final overlayStyle = widget.overlayStyle ?? theme?.overlayStyle;

    final effectiveSelectorTheme = widget.selectorTheme ?? theme?.selectorTheme;

    return DropselectTabControllerProvider(
      controller: _controller,
      child: CompositedTransformTarget(
        link: _controller!.layerLink,
        child: OverlayPortal(
          controller: _controller!.portalCtrl,
          overlayChildBuilder: (context) {
            return CompositedTransformFollower(
              link: _controller!.layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, height),
              child: DropselectOverlay(
                selector: _controller!.previousSelector!,
                style: overlayStyle,
                onChangeTap: _controller!.handleChange,
                onApplyTap: _controller!.handleApply,
                onResetTap: _controller!.handleReset,
                onOverlayTap: () {
                  // FocusScope.of(context).unfocus();
                  _controller!.hideSelector();
                },
                availableHeight: _overlayAvailableHeight,
                selectorTheme: effectiveSelectorTheme,
              ),
            );
          },
          child: Material(
            color: widget.backgroundColor ??
                theme?.backgroundColor ??
                defaults.backgroundColor!,
            elevation: widget.elevation,
            child: SizedBox(
              height: height,
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < widget.tabs.length; i++)
                    Expanded(
                      child: _DropselectTabInfo(
                        index: i,
                        onTap: (tabData) => _handleTap(tabData),
                        indicator: widget.indicator,
                        unselectedIndicator: widget.unselectedIndicator,
                        child: _DropselectTabStyle(
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropselectTabStyle extends StatelessWidget {
  const _DropselectTabStyle({
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
  final DropselectTabBarTheme defaults;
  final Widget child;

  WidgetStateColor _resolveWithLabelColor(BuildContext context) {
    final DropselectTabBarTheme? theme = DropselectTabBarTheme.maybeOf(context);

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
    final DropselectTabBarTheme? theme = DropselectTabBarTheme.maybeOf(context);

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

/// A tab widget used inside [DropselectTabBar].
///
/// Provide either [label] or [child]. Use [labelGetter] to compute a custom
/// label from the applied selection result.
class DropselectTab extends StatelessWidget {
  final String? label;

  final DropselectTabLabelGetter? labelGetter;

  final Widget? child;

  final String? tag;

  const DropselectTab({
    super.key,
    this.label,
    this.labelGetter,
    this.child,
    this.tag,
  }) : assert(label == null || child == null,
            'Either provide a label or an child, not both.');

  @override
  Widget build(BuildContext context) {
    final DropselectTabBarTheme defaults = _DropselectTabBarDefaults(context);
    final DropselectTabBarTheme? theme = DropselectTabBarTheme.maybeOf(context);

    final DropselectTabController controller =
        DropselectTabController.of(context);
    final _DropselectTabInfo info = _DropselectTabInfo.of(context);
    final unselected = controller.currentIndex != info.index;
    final isSelectorShowing = controller.isSelectorShowing;

    debugPrint('label: $label, unselected: $unselected');

    DropselectTabData? tabData = controller.tabDataMap.containsKey(info.index)
        ? controller.tabDataMap[info.index]
        : null;
    if (tabData == null) {
      tabData = DropselectTabData(
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                !unselected && isSelectorShowing
                    ? info.indicator ?? theme?.indicator ?? defaults.indicator!
                    : info.unselectedIndicator ??
                        theme?.unselectedIndicator ??
                        defaults.unselectedIndicator!,
              ],
            ),
      ),
    );
  }
}

class _DropselectTabInfo extends InheritedWidget {
  const _DropselectTabInfo({
    required this.index,
    required this.onTap,
    required super.child,
    this.indicator,
    this.unselectedIndicator,
  });

  final int index;

  final Widget? indicator;
  final Widget? unselectedIndicator;

  final void Function(DropselectTabData tabData) onTap;

  static _DropselectTabInfo of(BuildContext context) {
    final _DropselectTabInfo? result =
        context.dependOnInheritedWidgetOfExactType<_DropselectTabInfo>();
    assert(
      result != null,
      'DropselectTab need a _DropselectTabInfo parent, '
      'which is usually provided by DropselectTabBar.',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(_DropselectTabInfo oldWidget) {
    return index != oldWidget.index || onTap != oldWidget.onTap;
  }
}

class _DropselectTabBarDefaults extends DropselectTabBarTheme {
  _DropselectTabBarDefaults(this.context)
      : super(height: kDropselectTabBarHeight);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  Color? get labelColor => _colors.primary;

  @override
  TextStyle? get labelStyle => _textTheme.titleMedium;

  @override
  Color? get unselectedLabelColor => _colors.onSurface;

  @override
  TextStyle? get unselectedLabelStyle => _textTheme.titleMedium;

  @override
  Widget? get indicator => Icon(
        Icons.arrow_drop_up,
        // color: labelColor,
      );

  @override
  Widget? get unselectedIndicator => Icon(
        Icons.arrow_drop_down,
        // color: unselectedLabelColor,
      );

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

import 'package:flutter/material.dart';

import 'constants.dart';
import 'dropdown_selector_result.dart';
import 'dropdown_tab_data.dart';
import 'selector.dart';
import 'selector/selector_controller.dart';
import 'selector_entry.dart';
import 'selector_utils.dart';

/// Controller for [DropdownSelectorBar] and its selector overlay.
///
/// This controller stores per-tab label data ([DropdownTabData]) and manages
/// the overlay visibility. It also forwards selection events through
/// [onChanged], [onApplied], and [onReset].
class DropdownSelectorController extends ChangeNotifier {
  static const Duration _kOverlayAnimationDuration =
      Duration(milliseconds: 240);

  /// Fired whenever a selector reports a selection change.
  DropdownSelectorResultCallback? onChanged;

  /// Fired when a selector is applied.
  DropdownSelectorResultCallback? onApplied;

  /// Fired when reset is triggered.
  VoidCallback? onReset;

  /// Per-tab label and result data keyed by tab index.
  final Map<int, DropdownTabData> tabDataMap = {};
  bool _isDisposed = false;

  /// Returns the nearest controller provided by [DropdownSelectorControllerProvider]
  /// or null if none is found.
  static DropdownSelectorController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_DropdownSelectorControllerScope>()
        ?.controller;
  }

  /// Returns the nearest controller provided by [DropdownSelectorControllerProvider].
  static DropdownSelectorController of(BuildContext context) {
    final DropdownSelectorController? controller = maybeOf(context);
    assert(() {
      if (controller == null) {
        throw FlutterError(
          'DropdownSelectorController.of() was called with a context that does not '
          'contain a DropdownSelectorControllerProvider widget.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return controller!;
  }

  final portalCtrl = OverlayPortalController();
  final layerLink = LayerLink();

  TickerProvider? _tickerProvider;
  AnimationController? _overlayAnimCtrl;
  Animation<double>? _overlayAnimation;
  bool _isExpanded = false;

  // OverlayEntry? _entry;

  // BuildContext? get barContext => _barContext;
  // BuildContext? _barContext;

  // void attachBarContext(BuildContext context) {
  //   _barContext = context;
  // }

  // void detachBarContext() {
  //   _barContext = null;
  // }

  /// Currently selected tab index.
  int? currentIndex;

  /// Returns the current tab data for [currentIndex].
  DropdownTabData get currentTabData => tabDataMap[currentIndex]!;

  /// The selector previously used for the overlay.
  Selector? previousSelector;

  /// The [SelectorController] for the currently active selector panel, if any.
  ///
  /// Created when a selector is shown (see [_showSelector]) and disposed when
  /// the overlay is hidden. Exposed so that [DropdownSelectorBar] can pass it to
  /// [SelectorPanel] via its `controller` parameter.
  SelectorController? get selectorController => _selectorController;
  SelectorController? _selectorController;

  /// Localized "Multiple" text used when building apply result labels.
  ///
  /// Injected by [DropdownSelectorBar] from the active localizations before the
  /// overlay is shown.
  String? applyMultipleText;

  List<Selector>? _selectors;

  void attachSelectors(List<Selector> selectors) {
    if (_isDisposed) return;
    _selectors = selectors;
  }

  Selector? _selectorAt(int tabIndex) {
    final selectors = _selectors;
    if (selectors == null) return null;
    if (tabIndex < 0 || tabIndex >= selectors.length) return null;
    return selectors[tabIndex];
  }

  Animation<double> get overlayAnimation =>
      _overlayAnimation ?? AlwaysStoppedAnimation(_isExpanded ? 1.0 : 0.0);

  void attachTickerProvider(TickerProvider tickerProvider) {
    if (_isDisposed) return;
    if (identical(_tickerProvider, tickerProvider) &&
        _overlayAnimCtrl != null) {
      return;
    }

    if (_tickerProvider != null &&
        !identical(_tickerProvider, tickerProvider)) {
      detachTickerProvider();
    }

    _tickerProvider = tickerProvider;
    _ensureOverlayAnimationController();
    final animCtrl = _overlayAnimCtrl;
    if (animCtrl == null) return;
    animCtrl.value = _isExpanded ? 1.0 : 0.0;
  }

  void detachTickerProvider() {
    _tickerProvider = null;
    _overlayAnimation = null;
    final animCtrl = _overlayAnimCtrl;
    _overlayAnimCtrl = null;
    animCtrl?.dispose();
  }

  void _ensureOverlayAnimationController() {
    final tickerProvider = _tickerProvider;
    if (tickerProvider == null) return;

    final existingCtrl = _overlayAnimCtrl;
    if (existingCtrl != null) {
      return;
    }

    final animCtrl = AnimationController(
      vsync: tickerProvider,
      duration: _kOverlayAnimationDuration,
    );
    _overlayAnimCtrl = animCtrl;
    _overlayAnimation = CurvedAnimation(
      parent: animCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    hideSelector(immediate: true);
    _isDisposed = true;
    detachTickerProvider();
    tabDataMap.clear();
    // removeOverlay();
    super.dispose();
  }

  void _safePortalHide() {
    try {
      portalCtrl.hide();
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  /// Shows or hides the selector overlay.
  ///
  /// If [index] differs from [currentIndex], the overlay is shown and
  /// [currentIndex] is updated.
  void toggleSelector({int? index}) {
    if (_isDisposed) return;
    if (currentIndex != index || !_isExpanded) {
      _showSelector(index);
      return;
    }
    hideSelector();
  }

  bool get isSelectorShowing => _isExpanded;

  /// Hides the selector overlay if it is showing.
  void hideSelector({bool immediate = false}) {
    if (_isDisposed) {
      if (immediate) {
        _overlayAnimCtrl?.value = 0.0;
        _safePortalHide();
        _disposeSelectorController();
      }
      return;
    }

    if (!_isExpanded && !portalCtrl.isShowing) {
      _disposeSelectorController();
      return;
    }

    _isExpanded = false;
    notifyListeners();

    if (immediate) {
      _overlayAnimCtrl?.value = 0.0;
      _safePortalHide();
      _disposeSelectorController();
      notifyListeners();
      return;
    }

    final animCtrl = _overlayAnimCtrl;
    if (animCtrl == null) {
      _safePortalHide();
      _disposeSelectorController();
      notifyListeners();
      return;
    }

    if (!portalCtrl.isShowing) {
      animCtrl.value = 0.0;
      _disposeSelectorController();
      return;
    }

    animCtrl.reverse(from: animCtrl.value).whenComplete(() {
      if (_isDisposed) return;
      if (portalCtrl.isShowing) {
        _safePortalHide();
      }
      _disposeSelectorController();
      notifyListeners();
    });
  }

  void _showSelector(int? index) {
    if (_isDisposed) return;
    if (index == null) return;

    currentIndex = index;
    _isExpanded = true;

    // Create (or refresh) the SelectorController for this selector session.
    _createSelectorController();

    _ensureOverlayAnimationController();
    final animCtrl = _overlayAnimCtrl;

    if (!portalCtrl.isShowing) {
      portalCtrl.show();
      animCtrl?.forward(from: 0.0);
      notifyListeners();
      return;
    }

    animCtrl?.value = 1.0;
    notifyListeners();
  }

  /// Creates a [SelectorController] bound to [previousSelector] and wires the
  /// change/apply/reset listeners to this controller's handlers.
  ///
  /// Any previously created controller is disposed first.
  void _createSelectorController() {
    _disposeSelectorController();
    final selector = previousSelector;
    if (selector == null) return;
    final ctrl = SelectorController(
      selectionMode: selector.selectionMode,
      previousSelected: selector.selectedData,
      resetSelected: selector.resetData,
    );
    ctrl.addChangeListener(handleChange);
    ctrl.addApplyListener(
        (selected) => handleApply(selected, applyMultipleText ?? 'Multiple'));
    ctrl.addResetListener(handleReset);
    _selectorController = ctrl;
  }

  /// Disposes the current [SelectorController], if any.
  void _disposeSelectorController() {
    final ctrl = _selectorController;
    _selectorController = null;
    ctrl?.dispose();
  }

  /// Dispatches a selection change event.
  void handleChange(SelectorEntries selected) {
    if (_isDisposed) return;
    final result =
        DropdownSelectorResult(tabData: currentTabData, selected: selected);
    onChanged?.call(result);
  }

  /// Dispatches an apply event and updates the tab result label.
  void handleApply(SelectorEntries selected, String multipleText) {
    if (_isDisposed) return;
    final result =
        DropdownSelectorResult(tabData: currentTabData, selected: selected);
    hideSelector();
    onApplied?.call(result);
    final customLabel = result.tabData.labelGetter?.call(result);
    result.tabData.resultLabel = customLabel ??
        SelectorUtils.getResultLabel(result.selected, multipleText);
    notifyListeners();
  }

  /// Programmatically applies selection ids to the tab at [tabIndex].
  ///
  /// This method does not open the selector panel. Instead, it resolves
  /// [selectedEntryIds] against the selector data, builds a [DropdownSelectorResult],
  /// fires [onApplied], updates the tab label, and notifies listeners.
  ///
  /// Matching rules:
  /// - Matching is performed by entry id only.
  /// - If the same id appears in multiple branches, all matching entries are
  ///   included in the applied result.
  /// - Header and footer entries are supported.
  /// - Custom range entries are not supported.
  /// - Category ids are not allowed in [selectedEntryIds].
  ///
  /// Return value:
  /// - Returns `true` when the apply flow completes successfully, including the
  ///   case where no entry ids match and the result is treated as cleared/empty.
  /// - Returns `false` when the input is invalid or the selector data cannot be
  ///   prepared, such as:
  ///   - [tabIndex] does not resolve to a tab/selector
  ///   - a category id is present in [selectedEntryIds]
  ///   - a custom range id is present in [selectedEntryIds]
  ///   - selector data cannot be loaded
  Future<bool> apply({
    required int tabIndex,
    required Set<String> selectedEntryIds,
    String multipleText = 'Multiple',
  }) async {
    if (_isDisposed) return false;
    final tabData = tabDataMap[tabIndex];
    if (tabData == null) return false;

    final selector = _selectorAt(tabIndex);
    if (selector == null) return false;

    final dataFuture = selector.data;
    if (dataFuture == null) return false;

    late final SelectorEntries entries;
    try {
      entries = await dataFuture;
    } catch (_) {
      return false;
    }

    final ctx = _DropdownSelectorApplyContext(selectedEntryIds);
    final selected = _buildAppliedSelection(entries.toList(), ctx);
    if (ctx.invalidCategoryHit) return false;
    if (ctx.invalidCustomHit) return false;

    final result = DropdownSelectorResult(tabData: tabData, selected: selected);
    onApplied?.call(result);
    final customLabel = tabData.labelGetter?.call(result);
    tabData.resultLabel = customLabel ??
        SelectorUtils.getResultLabel(result.selected, multipleText);
    notifyListeners();
    return true;
  }

  Future<bool> select(int tabIndex, Set<String> selectedEntryIds) async {
    if (_isDisposed) return false;
    final tabData = tabDataMap[tabIndex];
    if (tabData == null) return false;

    final selector = _selectorAt(tabIndex);
    if (selector == null) return false;

    previousSelector = selector;

    final dataFuture = selector.data;
    if (dataFuture == null) return false;

    selector.resetData;

    late final SelectorEntries entries;
    try {
      entries = await dataFuture;
    } catch (_) {
      return false;
    }

    final ctx = _DropdownSelectorApplyContext(selectedEntryIds);
    final selected = _buildAppliedSelection(entries.toList(), ctx);
    if (ctx.invalidCategoryHit) return false;
    if (ctx.invalidCustomHit) return false;

    selector.selectedData = selected;
    _showSelector(tabIndex);
    handleChange(selected);
    return true;
  }

  static SelectorEntries _buildAppliedSelection(
    List<SelectorEntry> roots,
    _DropdownSelectorApplyContext ctx,
  ) {
    final SelectorEntries result = {};
    for (final root in roots) {
      final cropped = _cropEntry(root, ctx);
      if (ctx.invalidCategoryHit || ctx.invalidCustomHit) return {};
      if (cropped != null) result.add(cropped);
    }
    return result;
  }

  static SelectorEntry? _cropEntry(
    SelectorEntry entry,
    _DropdownSelectorApplyContext ctx,
  ) {
    if (entry is SelectorCategoryEntry) {
      if (ctx.selectedEntryIds.contains(entry.id)) {
        ctx.invalidCategoryHit = true;
        return null;
      }

      final Set<SelectorEntry> croppedChildren = {};
      final children = entry.children;
      if (children != null) {
        for (final child in children) {
          final cropped = _cropEntry(child, ctx);
          if (ctx.invalidCategoryHit || ctx.invalidCustomHit) return null;
          if (cropped != null) croppedChildren.add(cropped);
        }
      }

      final header =
          entry.header == null ? null : _cropEntry(entry.header!, ctx);
      if (ctx.invalidCategoryHit || ctx.invalidCustomHit) return null;

      final footer =
          entry.footer == null ? null : _cropEntry(entry.footer!, ctx);
      if (ctx.invalidCategoryHit || ctx.invalidCustomHit) return null;

      if (croppedChildren.isEmpty && header == null && footer == null) {
        return null;
      }

      return SelectorCategoryEntry(
        selectionMode: entry.selectionMode,
        header: header,
        headerSelectionMode: entry.headerSelectionMode,
        footer: footer,
        footerSelectionMode: entry.footerSelectionMode,
        listConfig: entry.listConfig,
        gridConfig: entry.gridConfig,
        chipConfig: entry.chipConfig,
        id: entry.id,
        name: entry.name ?? '',
        children: croppedChildren,
        enabled: entry.enabled,
        immediate: entry.immediate,
      );
    }

    final bool isHit = ctx.selectedEntryIds.contains(entry.id);
    if (isHit) {
      if (entry is SelectorRangeEntry && entry.id == kCustomEntryId) {
        ctx.invalidCustomHit = true;
        return null;
      }
      ctx.matchedCount++;
    }

    final Set<SelectorEntry> croppedChildren = {};
    final children = entry.children;
    if (children != null) {
      for (final child in children) {
        final cropped = _cropEntry(child, ctx);
        if (ctx.invalidCategoryHit || ctx.invalidCustomHit) return null;
        if (cropped != null) croppedChildren.add(cropped);
      }
    }

    if (!isHit && croppedChildren.isEmpty) return null;

    return _cloneEntry(entry,
        children: croppedChildren.isEmpty ? null : croppedChildren);
  }

  static SelectorEntry _cloneEntry(
    SelectorEntry entry, {
    required Set<SelectorEntry>? children,
  }) {
    if (entry is SelectorTextEntry) {
      return SelectorTextEntry(
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
      );
    }

    if (entry is SelectorRangeEntry) {
      return SelectorRangeEntry(
        min: entry.min,
        max: entry.max,
        inputLabel: entry.inputLabel,
        minHintText: entry.minHintText,
        maxHintText: entry.maxHintText,
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
        extra: entry.extra,
      );
    }

    if (entry is SelectorChildEntry) {
      return SelectorChildEntry(
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
        extra: entry.extra,
      );
    }

    throw UnsupportedError(
        'Unsupported SelectorEntry type: ${entry.runtimeType}');
  }

  /// Dispatches a reset event.
  void handleReset() {
    if (_isDisposed) return;
    // hideSelector();
    onReset?.call();
  }
}

class _DropdownSelectorApplyContext {
  final Set<String> selectedEntryIds;
  bool invalidCategoryHit = false;
  bool invalidCustomHit = false;
  int matchedCount = 0;

  _DropdownSelectorApplyContext(this.selectedEntryIds);
}

class _DropdownSelectorControllerScope extends InheritedWidget {
  final DropdownSelectorController? controller;

  const _DropdownSelectorControllerScope({
    this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(
      covariant _DropdownSelectorControllerScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Provides a [DropdownSelectorController] to descendants.
class DropdownSelectorControllerProvider extends StatelessWidget {
  final DropdownSelectorController? controller;
  final Widget child;

  const DropdownSelectorControllerProvider({
    super.key,
    this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _DropdownSelectorControllerScope(
        controller: controller, child: child);
  }
}

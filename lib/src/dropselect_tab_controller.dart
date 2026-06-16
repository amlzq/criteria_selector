import 'package:flutter/material.dart';

import 'constants.dart';
import 'dropselect_result.dart';
import 'dropselect_tab_data.dart';
import 'selector.dart';
import 'selector_utils.dart';

/// Controller for [DropselectTabBar] and its selector overlay.
///
/// This controller stores per-tab label data ([DropselectTabData]) and manages
/// the overlay visibility. It also forwards selection events through
/// [onChanged], [onApplied], and [onReset].
class DropselectTabController extends ChangeNotifier {
  static const Duration _kOverlayAnimationDuration =
      Duration(milliseconds: 240);

  /// Fired whenever a selector reports a selection change.
  DropselectResultCallback? onChanged;

  /// Fired when a selector is applied.
  DropselectResultCallback? onApplied;

  /// Fired when reset is triggered.
  VoidCallback? onReset;

  /// Per-tab label and result data keyed by tab index.
  final Map<int, DropselectTabData> tabDataMap = {};
  bool _isDisposed = false;

  /// Returns the nearest controller provided by [DropselectTabControllerProvider]
  /// or null if none is found.
  static DropselectTabController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_DropselectTabControllerScope>()
        ?.controller;
  }

  /// Returns the nearest controller provided by [DropselectTabControllerProvider].
  static DropselectTabController of(BuildContext context) {
    final DropselectTabController? controller = maybeOf(context);
    assert(() {
      if (controller == null) {
        throw FlutterError(
          'DropselectTabController.of() was called with a context that does not '
          'contain a DropselectTabControllerProvider widget.\n'
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
  DropselectTabData get currentTabData => tabDataMap[currentIndex]!;

  /// The selector previously used for the overlay.
  Selector? previousSelector;

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
      }
      return;
    }

    if (!_isExpanded && !portalCtrl.isShowing) {
      return;
    }

    _isExpanded = false;
    notifyListeners();

    if (immediate) {
      _overlayAnimCtrl?.value = 0.0;
      _safePortalHide();
      notifyListeners();
      return;
    }

    final animCtrl = _overlayAnimCtrl;
    if (animCtrl == null) {
      _safePortalHide();
      notifyListeners();
      return;
    }

    if (!portalCtrl.isShowing) {
      animCtrl.value = 0.0;
      return;
    }

    animCtrl.reverse(from: animCtrl.value).whenComplete(() {
      if (_isDisposed) return;
      if (portalCtrl.isShowing) {
        _safePortalHide();
      }
      notifyListeners();
    });
  }

  void _showSelector(int? index) {
    if (_isDisposed) return;
    if (index == null) return;

    currentIndex = index;
    _isExpanded = true;

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

  /// Dispatches a selection change event.
  void handleChange(SelectorEntries selected) {
    if (_isDisposed) return;
    final result =
        DropselectResult(tabData: currentTabData, selected: selected);
    onChanged?.call(result);
  }

  /// Dispatches an apply event and updates the tab result label.
  void handleApply(SelectorEntries selected, String multipleText) {
    if (_isDisposed) return;
    final result =
        DropselectResult(tabData: currentTabData, selected: selected);
    hideSelector();
    onApplied?.call(result);
    final customLabel = result.tabData.labelGetter?.call(result);
    result.tabData.resultLabel = customLabel ??
        SelectorUtils.getResultLabel(result.selected, multipleText);
    notifyListeners();
  }

  /// Dispatches a reset event.
  void handleReset() {
    if (_isDisposed) return;
    // hideSelector();
    onReset?.call();
  }
}

class _DropselectTabControllerScope extends InheritedWidget {
  final DropselectTabController? controller;

  const _DropselectTabControllerScope({
    this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _DropselectTabControllerScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Provides a [DropselectTabController] to descendants.
class DropselectTabControllerProvider extends StatelessWidget {
  final DropselectTabController? controller;
  final Widget child;

  const DropselectTabControllerProvider({
    super.key,
    this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _DropselectTabControllerScope(controller: controller, child: child);
  }
}

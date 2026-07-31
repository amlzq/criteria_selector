import 'package:flutter/material.dart';

import '../children_layout.dart';
import '../constants.dart';
import '../selector_entry.dart';
import 'field_tile.dart';
import 'range_slider.dart';

/// A composite view that renders a [SelectorRangeSlider] above a
/// [SelectorFieldTile], keeping both in sync with a single source of truth.
///
/// This is the canonical render target for
/// [SelectorRangeLayout] — drop the layout on a category that contains
/// a custom [SelectorRangeEntry] and you get a "price-range" style control
/// out of the box:
///
/// * The slider is the primary input.
/// * The two text fields mirror the slider state and remain editable for
///   precise input.
/// * When a handle touches an extreme ([min] / [max]) the corresponding
///   field shows the entry's `minHintText` / `maxHintText` as a placeholder.
class SelectorRangeView extends StatefulWidget {
  const SelectorRangeView({
    super.key,
    required this.category,
    required this.entries,
    required this.selectedEntries,
    required this.layout,
    this.focusListener,
    this.minController,
    this.maxController,
    this.minFocusNode,
    this.maxFocusNode,
    this.padding,
  });

  /// The category that owns the layout; supplies the [SelectorRangeEntry]
  /// to render via [SelectorCategoryEntryExtension.firstCustomOrNull].
  final SelectorCategoryEntry category;

  /// The full child-entry list, used as a fallback to locate a custom
  /// [SelectorRangeEntry] when [category] does not provide one.
  final List<SelectorEntry> entries;

  /// The set of currently selected entries. Used to restore the custom
  /// entry's previous min/max on first build.
  final SelectorEntries? selectedEntries;

  /// Layout configuration (e.g. `showTitle`, `toText`).
  final SelectorRangeLayout layout;

  /// Called when the range changes, mirroring the
  /// [CustomRangeListener] signature used elsewhere in the package.
  final CustomRangeListener? focusListener;

  /// Optional external controller for the min text field.
  final TextEditingController? minController;

  /// Optional external controller for the max text field.
  final TextEditingController? maxController;

  /// Optional external focus node for the min text field.
  final FocusNode? minFocusNode;

  /// Optional external focus node for the max text field.
  final FocusNode? maxFocusNode;

  /// Padding around the whole view.
  final EdgeInsetsGeometry? padding;

  @override
  State<SelectorRangeView> createState() => _SelectorRangeViewState();
}

class _SelectorRangeViewState extends State<SelectorRangeView> {
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late FocusNode _minFocusNode;
  late FocusNode _maxFocusNode;

  // Range bounds. The entry may carry N as int or double; we treat all
  // numerics uniformly as `num` and project to `double` for the slider.
  double _min = 0;
  double _max = 1;
  int? _divisions;
  num? _initialMin;
  num? _initialMax;

  /// Whether the underlying entry is integral (both bounds are `int`, e.g.
  /// a [SelectorIntEntry]). When true, slider/field values are snapped to
  /// whole numbers and never exposed as floating-point text.
  bool _isInt = false;

  // Live state.
  late RangeValues _currentRange;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _minController = widget.minController ?? TextEditingController();
    _maxController = widget.maxController ?? TextEditingController();
    _minFocusNode = widget.minFocusNode ?? FocusNode();
    _maxFocusNode = widget.maxFocusNode ?? FocusNode();
    // Commit a field when it loses focus, so tapping away also finalizes the
    // value (the slider only updates on commit, never mid-typing).
    _minFocusNode.addListener(_onMinFocusChanged);
    _maxFocusNode.addListener(_onMaxFocusChanged);
    _loadEntry();
    _currentRange = RangeValues(
      _toDouble(_initialMin) ?? _min,
      _toDouble(_initialMax) ?? _max,
    );
    _initialized = true;
    _syncControllersFromRange(force: true);
  }

  @override
  void didUpdateWidget(covariant SelectorRangeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The slider bounds (_min / _max / divisions / hints) are fixed for the
    // lifetime of this view and loaded once in [initState]. Re-reading them
    // here from the (original) category entry would revert the user's edits
    // back to the extremes and wipe the text fields on every parent rebuild
    // — every edit emits through [focusListener], which rebuilds the parent
    // and re-invokes this method. The bounds never change in response to
    // user input, so there is nothing to reconcile here.
    //
    // We only react to an explicit reset: when the custom range was selected
    // and is now gone, restore the fields to their empty (extreme)
    // placeholders.
    final oldHadCustom = (oldWidget.selectedEntries ?? const <SelectorEntry>{})
        .any((e) => e is SelectorRangeEntry && e.isCustom);
    final newHasCustom = (widget.selectedEntries ?? const <SelectorEntry>{})
        .any((e) => e is SelectorRangeEntry && e.isCustom);
    if (oldHadCustom && !newHasCustom) {
      _currentRange = RangeValues(_min, _max);
      _minController.clear();
      _maxController.clear();
    }
  }

  @override
  void dispose() {
    _minFocusNode.removeListener(_onMinFocusChanged);
    _maxFocusNode.removeListener(_onMaxFocusChanged);
    if (widget.minController == null) _minController.dispose();
    if (widget.maxController == null) _maxController.dispose();
    if (widget.minFocusNode == null) _minFocusNode.dispose();
    if (widget.maxFocusNode == null) _maxFocusNode.dispose();
    super.dispose();
  }

  void _loadEntry() {
    final entry = _findEntry();
    if (entry == null) {
      // No custom entry — fall back to a degenerate 0..1 range so the
      // slider still renders safely.
      _min = 0;
      _max = 1;
      _divisions = null;
      _initialMin = null;
      _initialMax = null;
      return;
    }
    // Read N values as num.
    _min = _toDouble(entry.min) ?? 0;
    _max = _toDouble(entry.max) ?? (_min + 1);
    if (_max <= _min) _max = _min + 1;
    _divisions = entry.divisions;
    _initialMin = entry.min;
    _initialMax = entry.max;
    // Treat the range as integral when both bounds are integers (e.g. a
    // SelectorIntEntry); the slider then snaps the displayed/returned value
    // to whole numbers instead of exposing floating-point text.
    _isInt = entry.min is int && entry.max is int;
  }

  SelectorRangeEntry? _findEntry() {
    final fromCategory = widget.category.firstCustomOrNull;
    if (fromCategory != null) return fromCategory;
    for (final e in widget.entries) {
      if (e is SelectorRangeEntry && e.isCustom) return e;
    }
    return null;
  }

  void _onSliderChanged(RangeValues newRange) {
    setState(() {
      _currentRange = _roundRange(newRange);
    });
    _syncControllersFromRange();
  }

  void _onSliderChangeEnd(RangeValues newRange) {
    setState(() {
      _currentRange = _roundRange(newRange);
    });
    _syncControllersFromRange(force: true);
    _emit(newRange);
  }

  void _onFieldDraftChanged(String text) {
    // The typed text is buffered in the field's controller while the user
    // types. We deliberately do NOT push it to the slider here — the slider
    // only updates once the edit is committed (see [_commitField]), so it does
    // not jump around mid-typing.
  }

  void _onMinFocusChanged() {
    if (!mounted) return;
    if (!_minFocusNode.hasFocus) _commitField(true, _minController.text);
  }

  void _onMaxFocusChanged() {
    if (!mounted) return;
    if (!_maxFocusNode.hasFocus) _commitField(false, _maxController.text);
  }

  /// Finalizes the value of one field. Called when the field is submitted
  /// (e.g. "done") or loses focus. This is the *only* path that updates the
  /// [SelectorRangeSlider] from the text fields.
  void _commitField(bool isMin, String text) {
    final parsed = _parseNum(text);
    if (parsed == null) {
      // Empty / invalid input: revert the field to the canonical range value
      // so a half-typed or cleared field never sticks on screen.
      _syncControllersFromRange(force: true);
      return;
    }
    final clamped = parsed.clamp(_min, _max).toDouble();
    final value = _isInt ? clamped.roundToDouble() : clamped;

    final rawStart = isMin ? value : _currentRange.start;
    final rawEnd = isMin ? _currentRange.end : value;
    // Keep the two bounds ordered: if the edited bound lands on the wrong side
    // of the other, swap them so the user can never produce an inverted range
    // (e.g. typing a smaller value into the max field auto-swaps the two).
    final newRange = rawStart <= rawEnd
        ? RangeValues(rawStart, rawEnd)
        : RangeValues(rawEnd, rawStart);

    if (newRange != _currentRange) {
      setState(() {
        _currentRange = newRange;
      });
      _emit(newRange);
    }
    // Always re-sync so both fields reflect the canonical (snapped / swapped)
    // value now that editing is done.
    _syncControllersFromRange(force: true);
  }

  void _syncControllersFromRange({bool force = false}) {
    final minText = _format(_currentRange.start, atExtreme: _atMinExtreme);
    final maxText = _format(_currentRange.end, atExtreme: _atMaxExtreme);
    if (force || _minController.text != minText) {
      _minController.value = TextEditingValue(
        text: minText,
        selection: TextSelection.collapsed(offset: minText.length),
      );
    }
    if (force || _maxController.text != maxText) {
      _maxController.value = TextEditingValue(
        text: maxText,
        selection: TextSelection.collapsed(offset: maxText.length),
      );
    }
  }

  void _emit(RangeValues range) {
    final cb = widget.focusListener;
    if (cb == null) return;
    cb(
      widget.category.id,
      _toEmitText(range.start, _atMinExtreme),
      _toEmitText(range.end, _atMaxExtreme),
    );
  }

  String _toEmitText(double v, bool atExtreme) {
    if (atExtreme) return '';
    return _format(v, atExtreme: false);
  }

  RangeValues _roundRange(RangeValues r) {
    if (!_isInt) return r;
    return RangeValues(
      r.start.roundToDouble().clamp(_min, _max),
      r.end.roundToDouble().clamp(_min, _max),
    );
  }

  bool get _atMinExtreme => _currentRange.start <= _min + _epsilon;
  bool get _atMaxExtreme => _currentRange.end >= _max - _epsilon;
  static const double _epsilon = 1e-9;

  String _format(double v, {required bool atExtreme}) {
    if (atExtreme) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  /// Formats an extreme bound (min/max) for the slider's bottom labels.
  ///
  /// Unlike [_format], this always renders the numeric value — even at the
  /// extremes — because the labels are meant to display the range bounds
  /// (e.g. "0" / "2000000"), while the text fields show their placeholders
  /// at the extremes.
  String _formatBound(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  num? _parseNum(String text) {
    if (text.isEmpty) return null;
    final cleaned = text.replaceAll(',', '').replaceAll(RegExp(r'\s+'), '');
    return num.tryParse(cleaned);
  }

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return num.tryParse(value.toString())?.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }
    final entry = _findEntry();
    final showTitle = widget.layout.showTitle && widget.category.name != null;
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectorRangeSlider(
            title: showTitle
                ? Text(
                    widget.category.name ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            min: _min,
            max: _max,
            values: _currentRange,
            divisions: _divisions,
            // Show the range extremes at the bottom corners of the slider.
            minLabel: _formatBound(_min),
            maxLabel: _formatBound(_max),
            onChanged: _onSliderChanged,
            onChangeEnd: _onSliderChangeEnd,
          ),
          const SizedBox(height: 12),
          // Reuse [SelectorFieldTile] for the two text fields. It owns the
          // visual treatment; the change/submit callbacks wire the deferred
          // slider sync (see [_commitField]).
          if (entry != null)
            SelectorFieldTile(
              entry,
              minController: _minController,
              maxController: _maxController,
              minFocusNode: _minFocusNode,
              maxFocusNode: _maxFocusNode,
              separator: widget.layout.toText,
              // The range view accepts fractional input while typing and
              // rounds/snaps on commit (see [_commitField]).
              allowDecimal: true,
              onMinChanged: _onFieldDraftChanged,
              onMaxChanged: _onFieldDraftChanged,
              onMinSubmitted: (text) => _commitField(true, text),
              onMaxSubmitted: (text) => _commitField(false, text),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

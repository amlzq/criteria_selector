import '../selector_entry.dart';

/// Callback invoked when an item in a list/grid is tapped.
typedef ItemTapCallback<T extends SelectorEntry> = Function(int index, T entry);

/// Callback invoked when a custom range entry is tapped.
typedef CustomRangeListener = void Function(
    String categoryId, String minValue, String maxValue);

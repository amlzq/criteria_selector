import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'playground_l10n.dart';
import 'playground_params.dart';

/// The left-hand parameter panel. Every control reports changes through
/// [onChanged] with a new immutable [PlaygroundParams].
class ControlsPanel extends StatelessWidget {
  final PlaygroundParams params;
  final ValueChanged<PlaygroundParams> onChanged;
  final PlaygroundL10n l10n;

  const ControlsPanel({
    required this.params,
    required this.onChanged,
    required this.l10n,
    super.key,
  });

  bool get _gridRelevant =>
      params.layout == Layout.grid || params.layout == Layout.flatten;

  // The dropdown bar demo owns 4 fixed tabs (one per layout family), so the
  // global Layout selector no longer affects it and is disabled for that entry
  // point.
  bool get _layoutEnabled => params.entryPoint != EntryPoint.dropdownBar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _SectionTitle(l10n.entryPoint),
        _EnumDropdown<EntryPoint>(
          value: params.entryPoint,
          items: const {
            EntryPoint.box: 'SelectorBox',
            EntryPoint.dropdownBar: 'DropdownSelectorBar',
            EntryPoint.dropdownButton: 'DropdownSelectorButton',
            EntryPoint.dialog: 'showSelector',
            EntryPoint.bottomSheet: 'showModalBottomSelector',
          },
          onChanged: (v) => onChanged(params.copyWith(entryPoint: v)),
        ),
        const SizedBox(height: 16),
        _SectionTitle(l10n.layout, enabled: _layoutEnabled),
        _EnumDropdown<Layout>(
          value: params.layout,
          enabled: _layoutEnabled,
          items: {
            Layout.cascading: l10n.layoutCascading,
            Layout.grid: l10n.layoutGrid,
            Layout.flatten: l10n.layoutFlatten,
            Layout.list: l10n.layoutList,
          },
          onChanged: (v) => onChanged(params.copyWith(layout: v)),
        ),
        const SizedBox(height: 16),
        _SectionTitle(l10n.selectionMode),
        SegmentedButton<SelectionMode>(
          selected: {params.selectionMode},
          onSelectionChanged: (set) =>
              onChanged(params.copyWith(selectionMode: set.first)),
          segments: <ButtonSegment<SelectionMode>>[
            ButtonSegment(
                value: SelectionMode.single, label: Text(l10n.single)),
            ButtonSegment(
                value: SelectionMode.multiple, label: Text(l10n.multiple)),
          ],
        ),
        const SizedBox(height: 16),
        _SectionTitle(l10n.tileVariant),
        SegmentedButton<TileVariant>(
          selected: {params.tileVariant},
          onSelectionChanged: (set) =>
              onChanged(params.copyWith(tileVariant: set.first)),
          segments: <ButtonSegment<TileVariant>>[
            ButtonSegment(value: TileVariant.filled, label: Text(l10n.filled)),
            ButtonSegment(
                value: TileVariant.outlined, label: Text(l10n.outlined)),
          ],
        ),
        const SizedBox(height: 16),
        _SectionTitle(l10n.columns(params.crossAxisCount)),
        Slider(
          value: params.crossAxisCount.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          label: '${params.crossAxisCount}',
          onChanged: _gridRelevant
              ? (v) => onChanged(params.copyWith(crossAxisCount: v.round()))
              : null,
        ),
        _SectionTitle(
            l10n.aspectRatio(params.childAspectRatio.toStringAsFixed(1))),
        Slider(
          value: params.childAspectRatio,
          min: 1.0,
          max: 4.0,
          divisions: 30,
          label: params.childAspectRatio.toStringAsFixed(1),
          onChanged: _gridRelevant
              ? (v) => onChanged(params.copyWith(childAspectRatio: v))
              : null,
        ),
        _SectionTitle(l10n.spacing(params.spacing.round())),
        Slider(
          value: params.spacing,
          min: 0,
          max: 16,
          divisions: 16,
          label: params.spacing.round().toString(),
          onChanged: _gridRelevant
              ? (v) => onChanged(params.copyWith(spacing: v))
              : null,
        ),
        const SizedBox(height: 16),
        _SectionTitle(l10n.brightness),
        SegmentedButton<Brightness?>(
          selected: {params.brightness},
          onSelectionChanged: (set) {
            final brightness = set.first;
            onChanged(params.copyWith(
              brightness: brightness,
              clearBrightness: brightness == null,
            ));
          },
          segments: <ButtonSegment<Brightness?>>[
            ButtonSegment(value: null, label: Text(l10n.follow)),
            ButtonSegment(value: Brightness.light, label: Text(l10n.light)),
            ButtonSegment(value: Brightness.dark, label: Text(l10n.dark)),
          ],
        ),
        const SizedBox(height: 8),
        _SectionTitle(l10n.seedColor),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final color in seedColorPresets)
              _ColorSwatch(
                color: color,
                selected: color.value == params.seedColor.value,
                onTap: () => onChanged(params.copyWith(seedColor: color)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.material3),
          value: params.useMaterial3,
          onChanged: (v) => onChanged(params.copyWith(useMaterial3: v)),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool enabled;
  const _SectionTitle(this.text, {this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: enabled ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const _EnumDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items: <DropdownMenuItem<T>>[
        for (final entry in items.entries)
          DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: enabled ? (v) => onChanged(v as T) : null,
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black87 : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';
import '../log.dart';

/// Minimum interval between two snack bars so that high-frequency
/// [onChanged] callbacks don't stack snack bars.
const Duration _resultThrottleInterval = Duration(milliseconds: 500);

DateTime? _lastShownAt;

/// Shows a snack bar that displays the selected filter result.
///
/// Tapping the "view" action opens a bottom sheet with the flattened
/// [SelectorEntries] conditions.
///
/// Calls are throttled by [throttleInterval]: consecutive calls within the
/// interval are ignored, which avoids stacking snack bars when [onChanged]
/// fires frequently.
void showSelectedResult(
  BuildContext context,
  SelectorEntries result, {
  Duration throttleInterval = _resultThrottleInterval,
}) {
  final conditions = '${result.flatten()}';
  debugPrintLarge('conditions: $conditions');

  final now = DateTime.now();
  if (_lastShownAt != null &&
      now.difference(_lastShownAt!) < throttleInterval) {
    return;
  }
  _lastShownAt = now;

  final l10n = AppLocalizations.of(context);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n?.filterUpdated ?? ''),
      action: SnackBarAction(
        label: l10n?.view ?? '',
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return SafeArea(
                child: FractionallySizedBox(
                  heightFactor: 0.8,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        l10n?.filterConditions(conditions) ?? conditions,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

/// Shows a snack bar that displays the selected result of a dropdown selector.
void showDropdownSelectorResult(
  BuildContext context,
  DropdownSelectorResult result,
) {
  showSelectedResult(context, result.selected);
}

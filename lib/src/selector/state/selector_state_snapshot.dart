import '../../constants.dart';

class SelectorStateSnapshot {
  const SelectorStateSnapshot({
    required this.selectedEntriesPerLevel,
    required this.selectedHeaderEntries,
    required this.selectedFooterEntries,
  });

  final List<SelectorEntries> selectedEntriesPerLevel;
  final Map<String, SelectorEntries> selectedHeaderEntries;
  final Map<String, SelectorEntries> selectedFooterEntries;
}

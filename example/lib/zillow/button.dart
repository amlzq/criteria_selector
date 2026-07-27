import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';
import 'house_filters_repository.dart';
import 'house_repository.dart';
import 'utils.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showSelectedResult(SelectorEntries selected) {
    final l10n = AppLocalizations.of(context);
    final conditions = '${selected.flatten()}';
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

  HouseFilter? _parseFilter(String domain, SelectorEntries selected) {
    final filter = HouseFilter(cityId: userCityId);
    if (domain == 'neighborhood') {
      // Neighborhood filter
      _filtersRepo.neighborhoodResult = selected;
      filter.neighborhood = selected
          .cascadingPairsOf('neighborhood')
          .map((p) => {
                "region_id": p.id,
                "neighborhood_id": p.childIds,
              })
          .toList(growable: false);
    } else if (domain == 'price') {
      // Price filter
      _filtersRepo.priceResult = selected;
      final category = selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'list_price') {
        filter.listPrice = selected
            .childRangesOf('list_price')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      } else if (category.id == 'monthly_price') {
        filter.monthlyPayment = selected
            .childRangesOf('monthly_price')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
    } else if (domain == 'rooms') {
      // Rooms filter
      _filtersRepo.roomsResult = selected;
      filter.bedrooms = selected.childIdsOf('bedrooms');
      filter.bathrooms = selected.childIdsOf('bathrooms');
    } else if (domain == 'more') {
      // More filter
      _filtersRepo.moreResult = selected;
      filter.homeType = selected.childIdsOf('home_type');
      filter.listsDetails = selected.childIdsOf('lists_details');
      filter.squareFeet = selected.childIdsOf('square_feet');
      filter.lotSize = selected.childIdsOf('lot_size');
      filter.homeFeatures = selected.childIdsOf('home_features');
      filter.commute = selected.childIdsOf('commute');
      filter.expandedSearch = selected.childIdsOf('expanded_search');
    } else if (domain == 'sort') {
      // Sort filter
      _filtersRepo.sortResult = selected;
      filter.sort = selected.firstSelectedId;
    }
    return filter;
  }

  void _handleSelectorChange(String domain, SelectorEntries selected) async {
    final l10n = AppLocalizations.of(context);
    _filter = _parseFilter(domain, selected);
    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
  }

  void _handleSelectorApply(String domain, SelectorEntries selected) {
    final l10n = AppLocalizations.of(context);
    _filter = _parseFilter(domain, selected);
    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DropdownSelectorButton')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          DropdownSelectorButton(
            label: 'Neighborhood',
            selectorDelegate: CascadingSelectorDelegate(
              entriesLoader: _filtersRepo.fetchNeighborhoodData,
              selectedEntriesLoader: _filtersRepo.fetchNeighborhoodSelectedData,
              resetEntriesLoader: _filtersRepo.fetchNeighborhoodResetData,
              selectionMode: SelectionMode.multiple,
              sideBarTheme: const SelectorSideBarTheme(width: 150),
              isScrollable: true,
              radioBuilder: (context, selected) {
                return MyRadio(value: selected);
              },
              checkboxBuilder: (context, selected) {
                return MyCheckbox(value: selected);
              },
            ),
            onChanged: (selected) {
              debugPrint('onChanged: $selected');
              _handleSelectorChange('neighborhood', selected);
              _showSelectedResult(selected);
            },
            onApplied: (selected) {
              debugPrint('onApplied: $selected');
              _handleSelectorApply('neighborhood', selected);
              _showSelectedResult(selected);
            },
            onReset: () {
              debugPrint('onReset');
            },
          ),
          Center(
            child: DropdownSelectorButton.elevated(
              label: 'Price',
              selectorDelegate: GridSelectorDelegate(
                entriesLoader: _filtersRepo.fetchPriceData,
                selectedEntriesLoader: _filtersRepo.fetchPriceSelectedData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
                fieldTileTheme: const SelectorFieldTileTheme(
                  variant: SelectorFieldTileVariant.outlined,
                ),
                applyText: AppLocalizations.of(context)?.apply ?? '',
              ),
              onChanged: (selected) {
                debugPrint('onChanged: $selected');
                _handleSelectorChange('price', selected);
                _showSelectedResult(selected);
              },
              onApplied: (selected) {
                debugPrint('onApplied: $selected');
                _handleSelectorApply('price', selected);
                _showSelectedResult(selected);
              },
              onReset: () {
                debugPrint('onReset');
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: DropdownSelectorButton.outlined(
              label: 'Rooms',
              selectorDelegate: FlattenSelectorDelegate(
                entriesLoader: _filtersRepo.fetchRoomsData,
                selectedEntriesLoader: _filtersRepo.fetchRoomsSelectedData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                sideBarTheme: const SelectorSideBarTheme(width: 98),
                panelTheme: const SelectorPanelTheme(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
              ),
              onChanged: (selected) {
                debugPrint('onChanged: $selected');
                _handleSelectorChange('rooms', selected);
                _showSelectedResult(selected);
              },
              onApplied: (selected) {
                debugPrint('onApplied: $selected');
                _handleSelectorApply('rooms', selected);
                _showSelectedResult(selected);
              },
              onReset: () {
                debugPrint('onReset');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: DropdownSelectorButton(
              label: 'More',
              icon: const Icon(Icons.filter_alt_outlined),
              selectorDelegate: ListSelectorDelegate(
                entriesLoader: _filtersRepo.fetchMoreData,
                selectedEntriesLoader: _filtersRepo.fetchMoreSelectedData,
                resetEntriesLoader: _filtersRepo.fetchMoreResetData,
                selectionMode: SelectionMode.multiple,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
                fieldTileTheme: const SelectorFieldTileTheme(
                  variant: SelectorFieldTileVariant.outlined,
                ),
                chipBarTheme: const SelectorChipBarTheme(
                  variant: SelectorChipVariant.outlined,
                ),
              ),
              onChanged: (selected) {
                debugPrint('onChanged: $selected');
                _handleSelectorChange('more', selected);
                _showSelectedResult(selected);
              },
              onApplied: (selected) {
                debugPrint('onApplied: $selected');
                _handleSelectorApply('more', selected);
                _showSelectedResult(selected);
              },
              onReset: () {
                debugPrint('onReset');
              },
            ),
          ),
        ],
      ),
    );
  }
}

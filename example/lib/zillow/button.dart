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

  void _showSelectedResult(DropdownSelectorResult result) {
    final l10n = AppLocalizations.of(context);
    final conditions = '${result.selected.flatten()}';
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

  HouseFilter? _dropdownSelectorResultParser(DropdownSelectorResult result) {
    final filter = HouseFilter(cityId: userCityId);
    if (result.tabIndex == 0) {
      // Neighborhood filter
      _filtersRepo.neighborhoodResult = result.selected;
      filter.neighborhood = result
          .cascadingPairsOf('neighborhood')
          .map((p) => {
                "region_id": p.id,
                "neighborhood_id": p.childIds,
              })
          .toList(growable: false);
    } else if (result.tabIndex == 1) {
      // Price filter
      _filtersRepo.priceResult = result.selected;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'list_price') {
        filter.listPrice = result
            .childRangesOf('list_price')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      } else if (category.id == 'monthly_price') {
        filter.monthlyPayment = result
            .childRangesOf('monthly_price')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
    } else if (result.tabIndex == 2) {
      // Rooms filter
      _filtersRepo.roomsResult = result.selected;
      filter.bedrooms = result.childIdsOf('bedrooms');
      filter.bathrooms = result.childIdsOf('bathrooms');
    } else if (result.tabIndex == 3) {
      // More filter
      _filtersRepo.moreResult = result.selected;
      filter.homeType = result.childIdsOf('home_type');
      filter.listsDetails = result.childIdsOf('lists_details');
      filter.squareFeet = result.childIdsOf('square_feet');
      filter.lotSize = result.childIdsOf('lot_size');
      filter.homeFeatures = result.childIdsOf('home_features');
      filter.commute = result.childIdsOf('commute');
      filter.expandedSearch = result.childIdsOf('expanded_search');
    } else if (result.tabIndex == 4) {
      // Sort filter
      _filtersRepo.sortResult = result.selected;
      filter.sort = result.firstSelectedId;
    }
    return filter;
  }

  void _handleSelectorChange(DropdownSelectorResult result) async {
    final l10n = AppLocalizations.of(context);
    _filter = _dropdownSelectorResultParser(result);
    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
  }

  void _handleSelectorApply(DropdownSelectorResult result) {
    final l10n = AppLocalizations.of(context);
    _filter = _dropdownSelectorResultParser(result);
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
            onChanged: (result) {
              debugPrint('onChanged: $result');
              _handleSelectorChange(result);
              _showSelectedResult(result);
            },
            onApplied: (result) {
              debugPrint('onApplied: $result');
              _handleSelectorApply(result);
              _showSelectedResult(result);
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
              onChanged: (result) {
                debugPrint('onChanged: $result');
                _handleSelectorChange(result);
                _showSelectedResult(result);
              },
              onApplied: (result) {
                debugPrint('onApplied: $result');
                _handleSelectorApply(result);
                _showSelectedResult(result);
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
              onChanged: (result) {
                debugPrint('onChanged: $result');
                _handleSelectorChange(result);
                _showSelectedResult(result);
              },
              onApplied: (result) {
                debugPrint('onApplied: $result');
                _handleSelectorApply(result);
                _showSelectedResult(result);
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
              onChanged: (result) {
                debugPrint('onChanged: $result');
                _handleSelectorChange(result);
                _showSelectedResult(result);
              },
              onApplied: (result) {
                debugPrint('onApplied: $result');
                _handleSelectorApply(result);
                _showSelectedResult(result);
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

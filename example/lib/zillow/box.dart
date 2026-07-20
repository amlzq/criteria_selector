import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'house_filters_repository.dart';
import 'house_repository.dart';
import 'utils.dart';

class BoxPage extends StatefulWidget {
  const BoxPage({super.key});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  void _showSelectedResult(SelectorEntries result) {
    final l10n = AppLocalizations.of(context);
    final conditions = '${result.flatten()}';
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

  void _handleNeighborhoodChange(SelectorEntries result) async {
    final l10n = AppLocalizations.of(context);
    _filter ??= HouseFilter(cityId: userCityId);
    _filtersRepo.neighborhoodResult = result;
    _filter?.neighborhood = result
        .cascadingPairsOf('neighborhood')
        .map((p) => {
              "region_id": p.id,
              "neighborhood_id": p.childIds,
            })
        .toList(growable: false);

    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
  }

  void _handlePriceChange(SelectorEntries result) async {
    _filter ??= HouseFilter(cityId: userCityId);
    _filtersRepo.priceResult = result;
    final category = result.firstOrNull;
    if (category == null) return null;
    if (category.id == 'list_price') {
      _filter?.listPrice = result
          .childRangesOf('list_price')
          .map((e) => {
                "id": e.id,
                "min": e.min,
                "max": e.max,
              })
          .toList(growable: false);
    } else if (category.id == 'monthly_price') {
      _filter?.monthlyPayment = result
          .childRangesOf('monthly_price')
          .map((e) => {
                "id": e.id,
                "min": e.min,
                "max": e.max,
              })
          .toList(growable: false);
    }
  }

  void _handleRoomsChange(SelectorEntries result) async {
    _filter ??= HouseFilter(cityId: userCityId);
    _filtersRepo.roomsResult = result;
    _filter?.bedrooms = result.childIdsOf('bedrooms');
    _filter?.bathrooms = result.childIdsOf('bathrooms');
  }

  void _handleMoreChange(SelectorEntries result) async {
    _filter ??= HouseFilter(cityId: userCityId);
    _filtersRepo.moreResult = result;
    _filter?.homeType = result.childIdsOf('home_type');
    _filter?.listsDetails = result.childIdsOf('lists_details');
    _filter?.squareFeet = result.childIdsOf('square_feet');
    _filter?.lotSize = result.childIdsOf('lot_size');
    _filter?.homeFeatures = result.childIdsOf('home_features');
    _filter?.commute = result.childIdsOf('commute');
    _filter?.expandedSearch = result.childIdsOf('expanded_search');
  }

  void _handleSortChange(SelectorEntries result) async {
    _filter ??= HouseFilter(cityId: userCityId);
    _filtersRepo.sortResult = result;
    _filter?.sort = result.firstSelectedId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SelectorBox')),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(),
                const Text(
                  'Neighborhood',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  delegate: CascadingSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchNeighborhoodData,
                    selectedEntriesLoader:
                        _filtersRepo.fetchNeighborhoodSelectedData,
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
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handleNeighborhoodChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Price',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  delegate: GridSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchPriceData,
                    selectedEntriesLoader: _filtersRepo.fetchPriceSelectedData,
                    selectionMode: SelectionMode.multiple,
                    crossAxisCount: 3,
                    childAspectRatio: 3,
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
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handlePriceChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Rooms',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  delegate: FlattenSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchRoomsData,
                    selectedEntriesLoader: _filtersRepo.fetchRoomsSelectedData,
                    selectionMode: SelectionMode.multiple,
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    sideBarTheme: const SelectorSideBarTheme(width: 110),
                  ),
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handleRoomsChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sort',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  delegate: ListSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchSortData,
                    selectedEntriesLoader: _filtersRepo.fetchSortSelectedData,
                    resetEntriesLoader: _filtersRepo.fetchSortResetData,
                    selectionMode: SelectionMode.single,
                    radioBuilder: (context, selected) {
                      return MyRadio(value: selected);
                    },
                  ),
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handleSortChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 250),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

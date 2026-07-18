import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'house_filters_repository.dart';

class BoxPage extends StatefulWidget {
  const BoxPage({super.key});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  late final HouseFiltersRepository _filtersRepo;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
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

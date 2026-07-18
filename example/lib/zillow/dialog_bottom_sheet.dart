// ignore_for_file: avoid_print

import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';

class DialogBottomSheetDemoPage extends StatefulWidget {
  const DialogBottomSheetDemoPage({super.key});

  @override
  State<DialogBottomSheetDemoPage> createState() =>
      _DialogBottomSheetDemoPageState();
}

class _DialogBottomSheetDemoPageState extends State<DialogBottomSheetDemoPage> {
  late final HouseFiltersRepository _filtersRepo;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog & BottomSheet')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dialog'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await showSelector(
                  context: context,
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
                  title: const Text('Neighborhood'),
                );
                if (result == null) return;
                final first = result.firstSelectedId;
                if (first != null) {
                  print(
                      'neighborhood cascading: ${result.cascadingPairsOf(first)}');
                }
              },
              child: const Text('Show Neighborhood Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showSelector(
                  context: context,
                  delegate: GridSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchPriceData,
                    selectedEntriesLoader: _filtersRepo.fetchPriceSelectedData,
                    selectionMode: SelectionMode.multiple,
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    gridTileTheme: const SelectorGridTileTheme(
                      variant: SelectorGridTileVariant.outlined,
                    ),
                    fieldTileTheme: const SelectorFieldTileTheme(
                      variant: SelectorFieldTileVariant.outlined,
                    ),
                  ),
                  title: const Text('Price'),
                );
                if (result == null) return;
                print('price first: ${result.firstSelectedId}');
                print(
                    'price list ranges: ${result.childRangesOf('list_price')}');
                print(
                    'price monthly ranges: ${result.childRangesOf('monthly_price')}');
              },
              child: const Text('Show Price Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showSelector(
                  context: context,
                  delegate: FlattenSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchRoomsData,
                    selectedEntriesLoader: _filtersRepo.fetchRoomsSelectedData,
                    selectionMode: SelectionMode.multiple,
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    sideBarTheme: const SelectorSideBarTheme(width: 90),
                    panelTheme: const SelectorPanelTheme(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                  ),
                  title: const Text('Rooms'),
                );
                print('result: $result');
              },
              child: const Text('Show Rooms Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showSelector(
                  context: context,
                  delegate: ListSelectorDelegate(
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
                  elevation: 12,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  title: const Text('More'),
                );
                print('result: $result');
              },
              child: const Text('Show More Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showSelector(
                  context: context,
                  delegate: ListSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchSortData,
                    selectedEntriesLoader: _filtersRepo.fetchSortSelectedData,
                    resetEntriesLoader: _filtersRepo.fetchSortResetData,
                    selectionMode: SelectionMode.single,
                    radioBuilder: (context, selected) {
                      return MyRadio(value: selected);
                    },
                    panelTheme: const SelectorPanelTheme(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                  ),
                  elevation: 12,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  title: const Text('Sort'),
                );
                if (result == null) return;
                print('sort id: ${result.firstSelectedId}');
              },
              child: const Text('Show Sort Selector'),
            ),
            const SizedBox(height: 16),
            const Text('BottomSheet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSelector(
                  context: context,
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
                  title: const Text('Neighborhood'),
                );
                if (result == null) return;
                final first = result.firstSelectedId;
                if (first != null) {
                  print(
                      'neighborhood cascading: ${result.cascadingPairsOf(first)}');
                }
              },
              child: const Text('Show Neighborhood Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSelector(
                  context: context,
                  delegate: GridSelectorDelegate(
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
                  ),
                  title: const Text('Price'),
                );
                if (result == null) return;
                print('price first: ${result.firstSelectedId}');
                print(
                    'price list ranges: ${result.childRangesOf('list_price')}');
                print(
                    'price monthly ranges: ${result.childRangesOf('monthly_price')}');
              },
              child: const Text('Show Price Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSelector(
                  context: context,
                  delegate: FlattenSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchRoomsData,
                    selectedEntriesLoader: _filtersRepo.fetchRoomsSelectedData,
                    selectionMode: SelectionMode.multiple,
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    sideBarTheme: const SelectorSideBarTheme(width: 90),
                  ),
                  elevation: 12,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  title: const Text('Rooms'),
                );
                print('result: $result');
              },
              child: const Text('Show Rooms Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSelector(
                  context: context,
                  delegate: ListSelectorDelegate(
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
                    panelTheme: const SelectorPanelTheme(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                  ),
                  title: const Text('More'),
                );
                print('result: $result');
              },
              child: const Text('Show More Selector'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSelector(
                  context: context,
                  delegate: ListSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchSortData,
                    selectedEntriesLoader: _filtersRepo.fetchSortSelectedData,
                    resetEntriesLoader: _filtersRepo.fetchSortResetData,
                    selectionMode: SelectionMode.single,
                    radioBuilder: (context, selected) {
                      return MyRadio(value: selected);
                    },
                  ),
                  title: const Text('Sort'),
                );
                if (result == null) return;
                print('sort id: ${result.firstSelectedId}');
              },
              child: const Text('Show Sort Selector'),
            ),
          ],
        ),
      ),
    );
  }
}

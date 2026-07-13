// ignore_for_file: avoid_print

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';
import 'my_widgets.dart';

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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dialog'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await showCriteriaSelector(
                context: context,
                delegate: CascadingSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchRegionData,
                  selectedEntriesLoader: _filtersRepo.fetchRegionResetData,
                  resetEntriesLoader: _filtersRepo.fetchRegionResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                  checkboxBuilder: (context, selected) {
                    return MyCheckbox(value: selected);
                  },
                ),
                title: const Text('区域选择器'),
              );
              print('result: $result');
            },
            child: const Text('Show Region Selector'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await showCriteriaSelector(
                context: context,
                delegate: GridSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchBuyPriceData,
                  selectedEntriesLoader: _filtersRepo.fetchBuyPriceSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchBuyPriceResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  gridTileTheme: const SelectorGridTileTheme(
                    variant: SelectorGridTileVariant.outlined,
                  ),
                ),
                title: const Text('价格选择器'),
              );
              print('result: $result');
            },
            child: const Text('Show Price Selector'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await showCriteriaSelector(
                context: context,
                delegate: FlattenSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchFloorPlanBuyData,
                  selectedEntriesLoader:
                      _filtersRepo.fetchFloorPlanBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchFloorPlanBuyResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  sideBarTheme: const SelectorSideBarTheme(width: 90),
                ),
                title: const Text('户型选择器'),
              );
              print('result: $result');
            },
            child: const Text('Show FloorPlan Selector'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await showCriteriaSelector(
                context: context,
                delegate: FlattenSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchMoreBuyData,
                  selectedEntriesLoader: _filtersRepo.fetchMoreBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchMoreBuyResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  sideBarTheme: const SelectorSideBarTheme(width: 98),
                ),
                title: const Text('更多选择器'),
              );
              print('result: $result');
            },
            child: const Text('Show More Selector'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await showCriteriaSelector(
                context: context,
                delegate: ListSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchSortBuyData,
                  selectedEntriesLoader: _filtersRepo.fetchSortBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchSortBuyResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                ),
                title: const Text('排序选择器'),
              );
              print('result: $result');
            },
            child: const Text('Show Sort Selector'),
          ),
          const SizedBox(height: 16),
          const Text('BottomSheet'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

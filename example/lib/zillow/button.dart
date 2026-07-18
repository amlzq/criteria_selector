import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'house_filters_repository.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  late final HouseFiltersRepository _filtersRepo;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  void dispose() {
    super.dispose();
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
              print('onChanged: $result');
            },
            onApplied: (result) {
              print('onApplied: $result');
            },
            onReset: () {
              print('onReset');
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
                panelTheme: const SelectorPanelTheme(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
                applyText: AppLocalizations.of(context)?.apply ?? '',
              ),
              onChanged: (result) {
                print('onChanged: $result');
              },
              onReset: () {
                print('onReset');
              },
              onApplied: (result) {
                print('onApplied: $result');
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
              ),
              onChanged: (result) {
                print('onChanged: $result');
              },
              onReset: () {
                print('onReset');
              },
              onApplied: (result) {
                print('onApplied: $result');
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
                print('onChanged: $result');
              },
              onReset: () {
                print('onReset');
              },
              onApplied: (result) {
                print('onApplied: $result');
              },
            ),
          ),
        ],
      ),
    );
  }
}

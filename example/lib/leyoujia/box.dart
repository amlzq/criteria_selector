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
      appBar: AppBar(title: const Text('Dialog Sheet')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(),
              const Text('选择区域'),
              SelectorBox(
                delegate: CascadingSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchRegionData,
                  selectedEntriesLoader: _filtersRepo.fetchRegionSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchRegionResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                  checkboxBuilder: (context, selected) {
                    return MyCheckbox(value: selected);
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('选择价格'),
              SelectorBox(
                delegate: GridSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchBuyPriceData,
                  selectedEntriesLoader: _filtersRepo.fetchBuyPriceSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchBuyPriceResetData,
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
              ),
              const SizedBox(height: 24),
              const Text('选择户型'),
              SelectorBox(
                delegate: FlattenSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchFloorPlanBuyData,
                  selectedEntriesLoader:
                      _filtersRepo.fetchFloorPlanBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchFloorPlanBuyResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  sideBarTheme: const SelectorSideBarTheme(width: 98),
                ),
              ),
              const SizedBox(height: 24),
              const Text('选择排序'),
              SelectorBox(
                delegate: ListSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchSortBuyData,
                  selectedEntriesLoader: _filtersRepo.fetchSortBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchSortBuyResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

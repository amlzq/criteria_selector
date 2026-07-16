import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'house_filters_repository.dart';
import 'my_widgets.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  late final HouseFiltersRepository _filtersRepo;

  final ValueNotifier<String> _floorPlanApplyText = ValueNotifier<String>('');
  Timer? _floorPlanApplyTextDebounce;
  int _floorPlanApplyTextRequestId = 0;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  void dispose() {
    _floorPlanApplyTextDebounce?.cancel();
    _floorPlanApplyText.dispose();
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
            label: '区域',
            selectorDelegate: CascadingSelectorDelegate(
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
              label: '价格',
              selectorDelegate: GridSelectorDelegate(
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
                panelTheme: const SelectorPanelTheme(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
                applyText: AppLocalizations.of(context)?.apply ?? '',
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: DropdownSelectorButton.outlined(
              label: '户型',
              selectorDelegate: FlattenSelectorDelegate(
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
                actionBarBuilder: (
                  context, {
                  required onResetTap,
                  required onApplyTap,
                }) {
                  return MyActionBar(
                    applyTextVN: _floorPlanApplyText,
                    onResetTap: onResetTap,
                    onApplyTap: onApplyTap,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: DropdownSelectorButton(
              label: '更多',
              icon: const Icon(Icons.filter_alt_outlined),
              selectorDelegate: ListSelectorDelegate(
                entriesLoader: _filtersRepo.fetchSortBuyData,
                selectedEntriesLoader: _filtersRepo.fetchSortBuySelectedData,
                resetEntriesLoader: _filtersRepo.fetchSortBuyResetData,
                selectionMode: SelectionMode.single,
                radioBuilder: (context, selected) {
                  return MyRadio(value: selected);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

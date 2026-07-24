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

  HouseFilter? _dropdownSelectorResultParser(
      DropdownTabData tabData, SelectorEntries selected) {
    final filter = HouseFilter(cityId: userCityId);
    if (tabData.index == 0) {
      // 区域
      _filtersRepo.regionResult = selected;
      final category = selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'region') {
        // 行政区
        filter.district = selected
            .cascadingPairsOf('region')
            .map((p) => {
                  "district_id": p.id,
                  "subdistrict_id": p.childIds,
                })
            .toList(growable: false);
      } else if (category.id == 'metro') {
        // 地铁
        filter.metro = selected
            .cascadingPairsOf('metro')
            .map((p) => {
                  "line_id": p.id,
                  "station_id": p.childIds,
                })
            .toList(growable: false);
      } else if (category.id == 'nearby') {
        // 附近
        final nearbyRadiusMeters =
            selected.findIdsAtLevel(category, 1).firstOrNull;
        filter.nearbyRadiusMeters = nearbyRadiusMeters;
        filter.userLatLon = userLatLon;
      }
    } else if (tabData.index == 1) {
      // 价格筛选
      _filtersRepo.buyPriceResult = selected;
      final category = selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'total') {
        // 总价
        filter.totalPrice = selected
            .childRangesOf('total')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
      if (category.id == 'unit') {
        // 单价
        filter.unitPrice = selected
            .childRangesOf('unit')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
    } else if (tabData.index == 2) {
      // 户型筛选
      _filtersRepo.floorPlanBuyResult = selected;
      filter.livingRoom = selected.childIdsOf('living_room');
      filter.bathroom = selected.childIdsOf('bathroom');
      filter.balcony = selected.childIdsOf('balcony');
      filter.area = selected
          .childRangesOf('area')
          .map((e) => {
                "id": e.id,
                "min": e.min,
                "max": e.max,
              })
          .toList(growable: false);
    } else if (tabData.index == 3) {
      // 更多筛选
      _filtersRepo.moreBuyResult = selected;
      filter.homeType = selected.childIdsOf('home_type');
      filter.saleStatus = selected.childIdsOf('sale_status');
      filter.openTime = selected.childIdsOf('open_time');
      filter.deliveryTime = selected.childIdsOf('delivery_time');
      filter.decorationStatus = selected.childIdsOf('decoration_status');
      filter.buildingFeatures = selected.childIdsOf('building_features');
      filter.houseViewService = selected.childIdsOf('house_view_service');
    } else if (tabData.index == 4) {
      // 排序筛选
      _filtersRepo.sortBuyResult = selected;
      filter.sort = selected.firstSelectedId;
    }
    return filter;
  }

  void _handleSelectorChange(
      DropdownTabData tabData, SelectorEntries selected) async {
    final l10n = AppLocalizations.of(context);
    _filter = _dropdownSelectorResultParser(tabData, selected);
    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
  }

  void _handleSelectorApply(DropdownTabData tabData, SelectorEntries selected) {
    final l10n = AppLocalizations.of(context);
    _filter = _dropdownSelectorResultParser(tabData, selected);
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
            onChanged: (tabData, selected) {
              debugPrint('onChanged: $tabData $selected');
              _handleSelectorChange(tabData, selected);
              _showSelectedResult(selected);
            },
            onApplied: (tabData, selected) {
              debugPrint('onApplied: $selected');
              _handleSelectorApply(tabData, selected);
              _showSelectedResult(selected);
            },
            onReset: () {
              debugPrint('onReset');
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
              onChanged: (tabData, selected) {
                debugPrint('onChanged: $selected');
                _handleSelectorChange(tabData, selected);
                _showSelectedResult(selected);
              },
              onApplied: (tabData, selected) {
                debugPrint('onApplied: $selected');
                _handleSelectorApply(tabData, selected);
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
              ),
              onChanged: (tabData, selected) {
                debugPrint('onChanged: $selected');
                _handleSelectorChange(tabData, selected);
                _showSelectedResult(selected);
              },
              onApplied: (tabData, selected) {
                debugPrint('onApplied: $selected');
                _handleSelectorApply(tabData, selected);
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
              onChanged: (tabData, selected) {
                debugPrint('onChanged: $selected');
                _handleSelectorChange(tabData, selected);
                _showSelectedResult(selected);
              },
              onApplied: (tabData, selected) {
                debugPrint('onApplied: $selected');
                _handleSelectorApply(tabData, selected);
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

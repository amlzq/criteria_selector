import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';
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

  void _handleRegionChange(SelectorEntries result) async {
    final l10n = AppLocalizations.of(context);
    _filter ??= HouseFilter(cityId: userCityId);
    // 区域
    _filtersRepo.regionResult = result;
    final category = result.firstOrNull;
    if (category == null) return null;
    if (category.id == 'region') {
      // 行政区
      _filter?.district = result
          .cascadingPairsOf('region')
          .map((p) => {
                "district_id": p.id,
                "subdistrict_id": p.childIds,
              })
          .toList(growable: false);
    } else if (category.id == 'metro') {
      // 地铁
      _filter?.metro = result
          .cascadingPairsOf('metro')
          .map((p) => {
                "line_id": p.id,
                "station_id": p.childIds,
              })
          .toList(growable: false);
    } else if (category.id == 'nearby') {
      // 附近
      final nearbyRadiusMeters = result.firstSelectedId;
      _filter?.nearbyRadiusMeters = nearbyRadiusMeters;
      _filter?.userLatLon = userLatLon;
    }

    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
  }

  void _handlePriceChange(SelectorEntries result) async {
    _filter ??= HouseFilter(cityId: userCityId);
    // 价格筛选
    _filtersRepo.buyPriceResult = result;
    final category = result.firstOrNull;
    if (category == null) return null;
    if (category.id == 'total') {
      // 总价
      _filter?.totalPrice = result
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
      _filter?.unitPrice = result
          .childRangesOf('unit')
          .map((e) => {
                "id": e.id,
                "min": e.min,
                "max": e.max,
              })
          .toList(growable: false);
    }
  }

  void _handleFloorPlanChange(SelectorEntries result) async {
    _filter ??= HouseFilter(cityId: userCityId);
    // 户型筛选
    _filtersRepo.floorPlanBuyResult = result;
    _filter?.livingRoom = result.childIdsOf('living_room');
    _filter?.bathroom = result.childIdsOf('bathroom');
    _filter?.balcony = result.childIdsOf('balcony');
    _filter?.area = result
        .childRangesOf('area')
        .map((e) => {
              "id": e.id,
              "min": e.min,
              "max": e.max,
            })
        .toList(growable: false);
  }

  void _handleSortChange(SelectorEntries result) async {
    _filter = HouseFilter(cityId: userCityId);
    // 排序筛选
    _filtersRepo.sortBuyResult = result;
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
                  '选择区域',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handleRegionChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '选择价格',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  delegate: GridSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchBuyPriceData,
                    selectedEntriesLoader:
                        _filtersRepo.fetchBuyPriceSelectedData,
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
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handlePriceChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '选择户型',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  onChangeTap: (selected) {
                    debugPrint('onChangeTap: $selected');
                    _handleFloorPlanChange(selected);
                    _showSelectedResult(selected);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '选择排序',
                  style: TextStyle(fontSize: 20),
                ),
                SelectorBox(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  delegate: ListSelectorDelegate(
                    entriesLoader: _filtersRepo.fetchSortBuyData,
                    selectedEntriesLoader:
                        _filtersRepo.fetchSortBuySelectedData,
                    resetEntriesLoader: _filtersRepo.fetchSortBuyResetData,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'house_filters_repository.dart';
import 'house_repository.dart';
import 'utils.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _controller = DropdownSelectorController();
  late final HouseRepository _repo;
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  final ValueNotifier<String> _floorPlanApplyText = ValueNotifier<String>('');
  Timer? _floorPlanApplyTextDebounce;
  int _floorPlanApplyTextRequestId = 0;

  @override
  void initState() {
    super.initState();
    _repo = HouseRepository();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _filtersRepo.updateTexts(
      anyEntryText: l10n?.any ?? '',
      customInputLabel: l10n?.custom ?? '',
      minHintText: l10n?.minHint ?? '',
      maxHintText: l10n?.maxHint ?? '',
      customAreaName: l10n?.customArea ?? '',
    );
    if (_floorPlanApplyText.value.isEmpty) {
      _floorPlanApplyText.value = l10n?.apply ?? '';
    }
  }

  @override
  void dispose() {
    _repo.dispose();
    _controller.dispose();
    _floorPlanApplyTextDebounce?.cancel();
    _floorPlanApplyText.dispose();
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
      // 区域
      _filtersRepo.regionResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'region') {
        // 行政区
        filter.district = <Map<String, dynamic>>[];
        for (var d in category.children ?? {}) {
          filter.district!.add({
            "district_id": d.id,
            "subdistrict_id": d.children
                ?.map((s) => s.id)
                .toList(growable: false)
                .cast<String>(),
          });
        }
      } else if (category.id == 'metro') {
        // 地铁
        filter.metro = <Map<String, dynamic>>[];
        for (var l in category.children ?? {}) {
          filter.metro?.add({
            "line_id": l.id,
            "station_id": l.children
                ?.map((s) => s.id)
                .toList(growable: false)
                .cast<String>(),
          });
        }
      } else if (category.id == 'nearby') {
        // 附近
        final nearbyRadiusMeters =
            result.findIdsAtLevel(category, 1).firstOrNull;
        filter.nearbyRadiusMeters = nearbyRadiusMeters;
        filter.userLatLon = userLatLon;
      }
    } else if (result.tabIndex == 1) {
      // 价格筛选
      _filtersRepo.buyPriceResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'total') {
        // 总价
        filter.totalPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          filter.totalPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      } else if (category.id == 'unit') {
        // 单价
        filter.unitPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          filter.unitPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      }
    } else if (result.tabIndex == 2) {
      // 户型筛选
      _filtersRepo.floorPlanBuyResult = result;
      for (var category in result.selected) {
        if (category.id == 'living_room') {
          // 居室
          filter.livingRoom = <String>[];
          for (var e in category.children ?? {}) {
            e as SelectorTextEntry;
            filter.livingRoom!.add(e.id);
          }
        } else if (category.id == 'bathroom') {
          // 卫生间
          filter.bathroom = <String>[];
          for (var e in category.children ?? {}) {
            e as SelectorTextEntry;
            filter.bathroom!.add(e.id);
          }
        } else if (category.id == 'balcony') {
          // 阳台
          filter.balcony = <String>[];
          for (var e in category.children ?? {}) {
            e as SelectorTextEntry;
            filter.balcony!.add(e.id);
          }
        } else if (category.id == 'area') {
          // 面积
          filter.area = <Map<String, dynamic>>[];
          for (var e in category.children ?? {}) {
            e as SelectorIntEntry;
            filter.area!.add({"id": e.id, "min": e.min, "max": e.max});
          }
        }
      }
    } else if (result.tabIndex == 3) {
      // 排序筛选
      _filtersRepo.sortBuyResult = result;
      final entry = result.selected.firstOrNull;
      if (entry == null) return null;
      filter.sort = entry.id;
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
    if (result.tabIndex == 2) {
      _floorPlanApplyTextDebounce?.cancel();

      final requestId = ++_floorPlanApplyTextRequestId;
      _floorPlanApplyText.value = l10n?.viewing ?? '';

      _floorPlanApplyTextDebounce = Timer(
        const Duration(milliseconds: 250),
        () async {
          try {
            final count = await _repo.previewCount(_filter!);
            if (!mounted || requestId != _floorPlanApplyTextRequestId) return;
            final l10n = AppLocalizations.of(context);
            _floorPlanApplyText.value = count == 0
                ? (l10n?.nohomes ?? '')
                : (l10n?.viewhomes(count) ?? '');
          } catch (_) {
            if (!mounted || requestId != _floorPlanApplyTextRequestId) return;
            _floorPlanApplyText.value =
                AppLocalizations.of(context)?.apply ?? '';
          }
        },
      );
    }
  }

  void _handleSelectorApply(DropdownSelectorResult result) {
    _showSelectedResult(result);

    final l10n = AppLocalizations.of(context);
    _filter = _dropdownSelectorResultParser(result);
    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }

    _repo.refreshData(_filter!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final DropdownSelectorBarTheme dropdownTabBarTheme =
        DropdownSelectorBarTheme.maybeOf(context)!;
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: <ThemeExtension<dynamic>>[
          dropdownTabBarTheme.copyWith(
            labelColor: Colors.deepOrange,
            overlayStyle: dropdownTabBarTheme.overlayStyle?.copyWith(
              maxHeightFactor: 0.8,
            ),
          ),
        ],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.onMap ?? ''),
          bottom: DropdownSelectorBar(
            controller: _controller,
            tabs: [
              DropdownTab(
                // tag: 'region',
                label: l10n?.region ?? '',
                // labelGetter: (DropdownSelectorResult result) {
                //   // 可选：用户根据结果自定义标签
                //   return '自定义标签';
                // },
              ),
              DropdownTab(label: l10n?.price ?? ''),
              DropdownTab(label: l10n?.floorPlan ?? ''),
              DropdownTab(
                child: Image.asset('assets/sorting.png', width: 16, height: 16),
              ),
            ],
            selectorDelegates: [
              CascadingSelectorDelegate(
                entriesLoader: _filtersRepo.fetchRegionData,
                selectedEntriesLoader: _filtersRepo.fetchRegionSelectedData,
                resetEntriesLoader: _filtersRepo.fetchRegionResetData,
                selectionMode: SelectionMode.single,
              ),
              GridSelectorDelegate(
                entriesLoader: _filtersRepo.fetchBuyPriceData,
                selectedEntriesLoader: _filtersRepo.fetchBuyPriceSelectedData,
                selectionMode: SelectionMode.single,
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
              ),
              FlattenSelectorDelegate(
                entriesLoader: _filtersRepo.fetchFloorPlanBuyData,
                selectedEntriesLoader: _filtersRepo.fetchFloorPlanBuySelectedData,
                resetEntriesLoader: _filtersRepo.fetchFloorPlanBuyResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              ListSelectorDelegate(
                entriesLoader: _filtersRepo.fetchSortBuyData,
                selectedEntriesLoader: _filtersRepo.fetchSortBuySelectedData,
                resetEntriesLoader: _filtersRepo.fetchSortBuyResetData,
                selectionMode: SelectionMode.single,
              ),
            ],
            onChanged: (DropdownSelectorResult result) {
              debugPrint('onChanged: $result');
              _handleSelectorChange(result);
            },
            onApplied: (DropdownSelectorResult result) {
              debugPrint('onApplied: $result');
              _handleSelectorApply(result);
            },
            onReset: () {
              debugPrint('onReset');
            },
          ),
        ),
        body: StreamBuilder<List<House>>(
          stream: _repo.housesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n?.loadError('${snapshot.error}') ?? '${snapshot.error}',
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l10n?.nohomes ?? ''));
            }
            final houses = snapshot.data!;
            return ListView.builder(
              itemCount: houses.length,
              itemBuilder: (context, index) {
                final house = houses[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: AspectRatio(
                      aspectRatio: 120 / 80,
                      child: Image.asset(
                        house.picture ?? '',
                        width: 120,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(house.title ?? ''),
                    subtitle: Text(house.price ?? ''),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

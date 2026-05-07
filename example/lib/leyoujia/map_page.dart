import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';
import 'house_repository.dart';
import 'utils.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _controller = DropselectTabController();
  late final HouseRepository _repo;
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  final ValueNotifier<String> _floorPlanApplyText = ValueNotifier<String>('应用');
  Timer? _floorPlanApplyTextDebounce;
  int _floorPlanApplyTextRequestId = 0;

  @override
  void initState() {
    super.initState();
    _repo = HouseRepository();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  void dispose() {
    _repo.dispose();
    _controller.dispose();
    _floorPlanApplyTextDebounce?.cancel();
    _floorPlanApplyText.dispose();
    super.dispose();
  }

  void _showSelectedResult(DropselectResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('筛选条件已更新'),
        action: SnackBarAction(
          label: '查看',
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
                        child:
                            SelectableText('筛选条件：${result.selected.flatten()}'),
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

  HouseFilter? _dropselectResultParser(DropselectResult result) {
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
        filter.userLatLon = userLatLon; // TODO: 增加选择拦截器，在选之前请求定位，否则不能选
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
      final category = result.selected.firstOrNull;
      if (category == null) return null;
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
    } else if (result.tabIndex == 3) {
      // 排序筛选
      _filtersRepo.sortBuyResult = result;
      final entry = result.selected.firstOrNull;
      if (entry == null) return null;
      filter.sort = entry.id;
    }
    return filter;
  }

  void _handleSelectorChange(DropselectResult result) async {
    _filter = _dropselectResultParser(result);
    if (_filter == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('筛选条件解析失败')));
      return;
    }
    if (result.tabIndex == 2) {
      _floorPlanApplyTextDebounce?.cancel();

      final requestId = ++_floorPlanApplyTextRequestId;
      _floorPlanApplyText.value = '查看中…';

      _floorPlanApplyTextDebounce = Timer(
        const Duration(milliseconds: 250),
        () async {
          try {
            final count = await _repo.previewCount(_filter!);
            if (!mounted || requestId != _floorPlanApplyTextRequestId) return;
            _floorPlanApplyText.value = count == 0 ? '暂无房源' : '查看 $count 套';
          } catch (_) {
            if (!mounted || requestId != _floorPlanApplyTextRequestId) return;
            _floorPlanApplyText.value = '应用';
          }
        },
      );
    }
  }

  void _handleSelectorApply(DropselectResult result) {
    _filter = _dropselectResultParser(result);
    if (_filter == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('筛选条件解析失败')));
      return;
    }

    _repo.refreshData(_filter!);
  }

  @override
  Widget build(BuildContext context) {
    final DropselectTabBarTheme dropdownTabBarTheme =
        DropselectTabBarTheme.maybeOf(context)!;
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
          title: const Text('地图看房'),
          bottom: DropselectTabBar(
            controller: _controller,
            tabs: [
              const DropselectTab(
                // tag: 'region',
                label: '区域',
                // labelGetter: (DropselectResult result) {
                //   // 可选：用户根据结果自定义标签
                //   return '自定义标签';
                // },
              ),
              const DropselectTab(label: '价格'),
              const DropselectTab(label: '户型'),
              DropselectTab(
                child: Image.asset('assets/sorting.png', width: 16, height: 16),
              ),
            ],
            selectors: [
              CascadingSelector(
                dataFetcher: _filtersRepo.fetchRegionData,
                selectedDataFetcher: _filtersRepo.fetchRegionSelectedData,
                resetDataFetcher: _filtersRepo.fetchRegionResetData,
                selectionMode: SelectionMode.single,
              ),
              GridSelector(
                dataFetcher: _filtersRepo.fetchBuyPriceData,
                selectedDataFetcher: _filtersRepo.fetchBuyPriceSelectedData,
                selectionMode: SelectionMode.single,
                tileVariant: SelectorGridTileVariant.outlined,
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                actionBarTheme: const SelectorActionBarTheme(
                  resetText: '重置',
                  applyText: '应用',
                ),
              ),
              FlattenSelector(
                dataFetcher: _filtersRepo.fetchFloorPlanBuyData,
                selectedDataFetcher: _filtersRepo.fetchFloorPlanBuySelectedData,
                resetDataFetcher: _filtersRepo.fetchFloorPlanBuyResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              ListSelector(
                dataFetcher: _filtersRepo.fetchSortBuyData,
                selectedDataFetcher: _filtersRepo.fetchSortBuySelectedData,
                resetDataFetcher: _filtersRepo.fetchSortBuyResetData,
                selectionMode: SelectionMode.single,
              ),
            ],
            onChanged: (DropselectResult result) {
              debugPrint('onChanged: $result');
            },
            onApplied: (DropselectResult result) {
              debugPrint('onApplied: $result');
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
              return Center(child: Text('加载错误: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('暂无房源'));
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

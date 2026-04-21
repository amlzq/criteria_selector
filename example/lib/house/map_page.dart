import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_criteria_repository.dart';
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
  late final HouseCriteriaRepository _criteriaRepo;
  HouseCriteria? _criteria;

  final ValueNotifier<String> _floorPlanApplyText = ValueNotifier<String>('应用');
  Timer? _floorPlanApplyTextDebounce;
  int _floorPlanApplyTextRequestId = 0;

  @override
  void initState() {
    super.initState();
    _repo = HouseRepository();
    _criteriaRepo = HouseCriteriaRepository();
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

  HouseCriteria? _dropselectResultParser(DropselectResult result) {
    final criteria = HouseCriteria(cityId: userCityId);
    if (result.tabIndex == 0) {
      // 区域
      _criteriaRepo.regionResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'region') {
        // 行政区
        criteria.district = <Map<String, dynamic>>[];
        for (var d in category.children ?? {}) {
          criteria.district!.add({
            "district_id": d.id,
            "subdistrict_id": d.children
                ?.map((s) => s.id)
                .toList(growable: false)
                .cast<String>(),
          });
        }
      } else if (category.id == 'metro') {
        // 地铁
        criteria.metro = <Map<String, dynamic>>[];
        for (var l in category.children ?? {}) {
          criteria.metro?.add({
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
        criteria.nearbyRadiusMeters = nearbyRadiusMeters;
        criteria.userLatLon = userLatLon; // TODO: 增加选择拦截器，在选之前请求定位，否则不能选
      }
    } else if (result.tabIndex == 1) {
      // 价格筛选
      _criteriaRepo.buyPriceResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'total') {
        // 总价
        criteria.totalPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          criteria.totalPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      } else if (category.id == 'unit') {
        // 单价
        criteria.unitPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          criteria.unitPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      }
    } else if (result.tabIndex == 2) {
      // 户型筛选
      _criteriaRepo.floorPlanResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'living_room') {
        // 居室
        criteria.livingRoom = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          criteria.livingRoom!.add(e.id);
        }
      } else if (category.id == 'bathroom') {
        // 卫生间
        criteria.bathroom = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          criteria.bathroom!.add(e.id);
        }
      } else if (category.id == 'balcony') {
        // 阳台
        criteria.balcony = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          criteria.balcony!.add(e.id);
        }
      } else if (category.id == 'area') {
        // 面积
        criteria.area = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          criteria.area!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      }
    } else if (result.tabIndex == 3) {
      // 排序筛选
      _criteriaRepo.sortResult = result;
      final entry = result.selected.firstOrNull;
      if (entry == null) return null;
      criteria.sort = entry.id;
    }
    return criteria;
  }

  void _handleSelectorChange(DropselectResult result) async {
    _criteria = _dropselectResultParser(result);
    if (_criteria == null) {
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
            final count = await _repo.previewCount(_criteria!);
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
    _criteria = _dropselectResultParser(result);
    if (_criteria == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('筛选条件解析失败')));
      return;
    }

    _repo.refreshData(_criteria!);
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
                dataFetcher: _criteriaRepo.fetchRegionData,
                selectedDataFetcher: _criteriaRepo.fetchRegionSelectedData,
                resetDataFetcher: _criteriaRepo.fetchRegionResetData,
                selectionMode: SelectionMode.single,
              ),
              GridSelector(
                dataFetcher: _criteriaRepo.fetchBuyPriceData,
                selectedDataFetcher: _criteriaRepo.fetchBuyPriceSelectedData,
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
                dataFetcher: _criteriaRepo.fetchFloorPlanData,
                selectedDataFetcher: _criteriaRepo.fetchFloorPlanSelectedData,
                resetDataFetcher: _criteriaRepo.fetchFloorPlanResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              ListSelector(
                dataFetcher: _criteriaRepo.fetchSortData,
                selectedDataFetcher: _criteriaRepo.fetchSortSelectedData,
                resetDataFetcher: _criteriaRepo.fetchSortResetData,
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

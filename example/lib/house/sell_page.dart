import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/house/house_criteria_repository.dart';
import 'package:example/house/house_repository.dart';
import 'package:example/house/utils.dart';
import 'package:flutter/material.dart';

import 'my_widgets.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _controller = DropselectTabController();
  late final HouseRepository _repo;
  late final HouseCriteriaRepository _criteriaRepo;
  HouseCriteria? _criteria;

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
    super.dispose();
  }

  void _handleSelectorApply(DropselectResult result) {
    _criteria ??= HouseCriteria(cityId: userCityId);
    if (result.tabIndex == 0) {
      // 区域筛选
      _criteriaRepo.regionResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return;
      if (category.id == 'region') {
        // 行政区
        _criteria?.district = <Map<String, dynamic>>[];
        for (var d in category.children ?? {}) {
          _criteria?.district!.add({
            "district_id": d.id,
            "subdistrict_id": d.children
                ?.map((s) => s.id)
                .toList(growable: false)
                .cast<String>(),
          });
        }
      } else if (category.id == 'metro') {
        // 地铁
        _criteria?.metro = <Map<String, dynamic>>[];
        for (var l in category.children ?? {}) {
          _criteria?.metro?.add({
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
        _criteria?.nearbyRadiusMeters = nearbyRadiusMeters;
        _criteria?.userLatLon = userLatLon; // TODO: 增加选择拦截器，在选之前请求定位，否则不能选
      }
    } else if (result.tabIndex == 1) {
      // 价格筛选
      _criteriaRepo.sellPriceResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return;
      if (category.id == 'total') {
        // 总价
        _criteria?.totalPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          _criteria?.totalPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      } else if (category.id == 'unit') {
        // 单价
        _criteria?.unitPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          _criteria?.unitPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      }
    } else if (result.tabIndex == 2) {
      // 户型筛选
      _criteriaRepo.floorPlanSellResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return;
      if (category.id == 'living_room') {
        // 居室
        _criteria?.livingRoom = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          _criteria?.livingRoom!.add(e.id);
        }
      } else if (category.id == 'bathroom') {
        // 卫生间
        _criteria?.bathroom = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          _criteria?.bathroom!.add(e.id);
        }
      } else if (category.id == 'balcony') {
        // 阳台
        _criteria?.balcony = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          _criteria?.balcony!.add(e.id);
        }
      } else if (category.id == 'area') {
        // 面积
        _criteria?.area = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          _criteria?.area!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      }
    } else if (result.tabIndex == 3) {
      // 排序筛选
      _criteriaRepo.sortSellResult = result;
      final entry = result.selected.firstOrNull;
      if (entry == null) return;
      _criteria?.sort = entry.id;
    }
    _repo.refreshData(_criteria!);
  }

  @override
  Widget build(BuildContext context) {
    final DropselectTabBarTheme dropdownTabBarTheme =
        DropselectTabBarTheme.maybeOf(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('售屋房源'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Image.asset('assets/banner1.jpg', fit: BoxFit.cover),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              extensions: <ThemeExtension<dynamic>>[
                dropdownTabBarTheme.copyWith(
                  labelColor: Colors.amber,
                  overlayStyle: dropdownTabBarTheme.overlayStyle?.copyWith(
                    maxHeightFactor: 0.8,
                  ),
                ),
              ],
            ),
            child: DropselectTabBar(
              controller: _controller,
              // labelColor: Colors.orange,
              // indicator: Icon(Icons.arrow_upward),
              // unselectedIndicator: Icon(Icons.arrow_downward),
              // overlayStyle: DropdownOverlayStyle(
              //   backgroundColor: Colors.orange[100],
              // ),
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
                  child:
                      Image.asset('assets/sorting.png', width: 16, height: 16),
                ),
              ],
              selectors: [
                CascadingSelector(
                  dataFetcher: _criteriaRepo.fetchRegionData,
                  selectedDataFetcher: _criteriaRepo.fetchRegionSelectedData,
                  resetDataFetcher: _criteriaRepo.fetchRegionResetData,
                  selectionMode: SelectionMode.single,
                  // skeletonBuilder: (_) => const Center(
                  //     child: CircularProgressIndicator(
                  //   color: Colors.black,
                  // )),
                  // categoryBackgroundColor: Colors.grey[200]!,
                  // terminalBackgroundColor: Colors.white,
                  checkboxBuilder: (context, selected) {
                    return MyCheckbox(value: selected);
                  },
                ),
                GridSelector(
                  dataFetcher: _criteriaRepo.fetchSellPriceData,
                  selectedDataFetcher: _criteriaRepo.fetchSellPriceSelectedData,
                  resetDataFetcher: _criteriaRepo.fetchSellPriceResetData,
                  selectionMode: SelectionMode.single,
                  tileVariant: SelectorGridTileVariant.outlined,
                  crossAxisCount: 4,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                FlattenSelector(
                  dataFetcher: _criteriaRepo.fetchFloorPlanSellData,
                  selectedDataFetcher:
                      _criteriaRepo.fetchFloorPlanSellSelectedData,
                  resetDataFetcher: _criteriaRepo.fetchFloorPlanSellResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                ListSelector(
                  dataFetcher: _criteriaRepo.fetchSortSellData,
                  selectedDataFetcher: _criteriaRepo.fetchSortSellSelectedData,
                  resetDataFetcher: _criteriaRepo.fetchSortSellResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                ),
              ],
              onSelectorShowed: (DropselectTabData tabData) {
                debugPrint('onShowed: ${tabData.label}');
              },
              onSelectorHidden: (DropselectTabData tabData) {
                debugPrint('onHidden: ${tabData.label}');
              },
              onChanged: (DropselectResult result) {
                debugPrint('onChanged: $result');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('筛选条件：${result.selected.flatten()}')));
              },
              onApplied: (DropselectResult result) {
                debugPrint('onApplied: $result');
                _handleSelectorApply(result);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('筛选条件：${result.selected.flatten()}')));
              },
              onReset: () {
                debugPrint('onReset');
              },
            ),
          ),
          // ChoseChips
          // _controller.select();
          // _controller.showSelector();
          // _controller.hideSelector();
          Expanded(
            child: StreamBuilder<List<House>>(
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
        ],
      ),
    );
  }
}

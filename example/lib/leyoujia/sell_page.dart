import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/leyoujia/house_filters_repository.dart';
import 'package:example/leyoujia/house_repository.dart';
import 'package:example/leyoujia/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'my_widgets.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _controller = DropdownSelectorController();
  late final HouseRepository _repo;
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  @override
  void initState() {
    super.initState();
    _repo = HouseRepository();
    _filtersRepo = HouseFiltersRepository();

    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      _controller.select(1, {'203', '403'});
    });
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
  }

  @override
  void dispose() {
    _repo.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSelectorApply(DropdownSelectorResult result) {
    _filter ??= HouseFilter(cityId: userCityId);
    if (result.tabIndex == 0) {
      // 区域筛选
      _filtersRepo.regionResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return;
      if (category.id == 'region') {
        // 行政区
        _filter?.district = <Map<String, dynamic>>[];
        for (var d in category.children ?? {}) {
          _filter?.district!.add({
            "district_id": d.id,
            "subdistrict_id": d.children
                ?.map((s) => s.id)
                .toList(growable: false)
                .cast<String>(),
          });
        }
      } else if (category.id == 'metro') {
        // 地铁
        _filter?.metro = <Map<String, dynamic>>[];
        for (var l in category.children ?? {}) {
          _filter?.metro?.add({
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
        _filter?.nearbyRadiusMeters = nearbyRadiusMeters;
        _filter?.userLatLon = userLatLon;
      }
    } else if (result.tabIndex == 1) {
      // 价格筛选
      _filtersRepo.sellPriceResult = result;
      for (var category in result.selected) {
        if (category.id == 'total') {
          // 总价
          _filter?.totalPrice = <Map<String, dynamic>>[];
          for (var e in category.children ?? {}) {
            e as SelectorIntEntry;
            _filter?.totalPrice!.add({"id": e.id, "min": e.min, "max": e.max});
          }
        } else if (category.id == 'downpay') {
          // 首付
          _filter?.unitPrice = <Map<String, dynamic>>[];
          for (var e in category.children ?? {}) {
            e as SelectorIntEntry;
            _filter?.unitPrice!.add({"id": e.id, "min": e.min, "max": e.max});
          }
        }
      }
    } else if (result.tabIndex == 2) {
      // 户型筛选
      _filtersRepo.floorPlanSellResult = result;
      for (var category in result.selected) {
        if (category.id == 'living_room') {
          // 居室
          _filter?.livingRoom = <String>[];
          for (var e in category.children ?? {}) {
            e as SelectorTextEntry;
            _filter?.livingRoom!.add(e.id);
          }
        } else if (category.id == 'bathroom') {
          // 卫生间
          _filter?.bathroom = <String>[];
          for (var e in category.children ?? {}) {
            e as SelectorTextEntry;
            _filter?.bathroom!.add(e.id);
          }
        } else if (category.id == 'balcony') {
          // 阳台
          _filter?.balcony = <String>[];
          for (var e in category.children ?? {}) {
            e as SelectorTextEntry;
            _filter?.balcony!.add(e.id);
          }
        } else if (category.id == 'area') {
          // 面积
          _filter?.area = <Map<String, dynamic>>[];
          for (var e in category.children ?? {}) {
            e as SelectorIntEntry;
            _filter?.area!.add({"id": e.id, "min": e.min, "max": e.max});
          }
        }
      }
    } else if (result.tabIndex == 3) {
      // 排序筛选
      _filtersRepo.sortSellResult = result;
      final entry = result.selected.firstOrNull;
      if (entry == null) return;
      _filter?.sort = entry.id;
    }
    _repo.refreshData(_filter!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final DropdownSelectorBarTheme dropdownTabBarTheme =
        DropdownSelectorBarTheme.maybeOf(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.sell ?? ''),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Image.asset('assets/realestate/banner_sale.jpg',
                fit: BoxFit.cover),
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
            child: DropdownSelectorBar(
              controller: _controller,
              isScrollable: true,
              // labelColor: Colors.orange,
              // indicator: Icon(Icons.arrow_upward),
              // unselectedIndicator: Icon(Icons.arrow_downward),
              // overlayStyle: DropdownOverlayStyle(
              //   backgroundColor: Colors.orange[100],
              // ),
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
                  child:
                      Image.asset('assets/sorting.png', width: 16, height: 16),
                ),
              ],
              selectorDelegates: [
                CascadingSelectorDelegate(
                  isScrollable: true,
                  entriesLoader: _filtersRepo.fetchRegionData,
                  selectedEntriesLoader: _filtersRepo.fetchRegionSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchRegionResetData,
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
                GridSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchSellPriceData,
                  selectedEntriesLoader: _filtersRepo.fetchSellPriceSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchSellPriceResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 4,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  gridTileTheme: const SelectorGridTileTheme(
                    variant: SelectorGridTileVariant.outlined,
                  ),
                ),
                FlattenSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchFloorPlanSellData,
                  selectedEntriesLoader:
                      _filtersRepo.fetchFloorPlanSellSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchFloorPlanSellResetData,
                  selectionMode: SelectionMode.multiple,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  sideBarTheme: const SelectorSideBarTheme(width: 98),
                ),
                ListSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchSortSellData,
                  selectedEntriesLoader: _filtersRepo.fetchSortSellSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchSortSellResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                ),
              ],
              onSelectorShowed: (DropdownTabData tabData) {
                debugPrint('onShowed: ${tabData.label}');
              },
              onSelectorHidden: (DropdownTabData tabData) {
                debugPrint('onHidden: ${tabData.label}');
              },
              onChanged: (DropdownSelectorResult result) {
                debugPrint('onChanged: $result');
                final conditions = '${result.selected.flatten()}';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.filterConditions(conditions) ?? conditions,
                    ),
                  ),
                );
              },
              onApplied: (DropdownSelectorResult result) {
                debugPrint('onApplied: $result');
                _handleSelectorApply(result);
                final conditions = '${result.selected.flatten()}';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.filterConditions(conditions) ?? conditions,
                    ),
                  ),
                );
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
                  return Center(
                    child: Text(
                      l10n?.loadError('${snapshot.error}') ??
                          '${snapshot.error}',
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

import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/leyoujia/house_filters_repository.dart';
import 'package:example/leyoujia/house_repository.dart';
import 'package:example/leyoujia/utils.dart';
import 'package:example/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'my_widgets.dart';

const _bannerHeight = 150.0;
const _filterBarHeight = 44.0;
const _chipBarHeight = 48.0;
const _filterHeaderHeight = _filterBarHeight + _chipBarHeight;

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});
  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  final _controller = DropdownSelectorController();
  late final HouseRepository _repo;
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  final ValueNotifier<String> _floorPlanApplyText = ValueNotifier<String>('');
  Timer? _floorPlanApplyTextDebounce;
  int _floorPlanApplyTextRequestId = 0;

  final moreShortcut = [
    MoreItem(id: '3701', name: '现房'),
    MoreItem(id: '3903', name: '折扣好盘'),
    MoreItem(id: '3904', name: '免费专车'),
    MoreItem(id: '3605', name: '本月开盘'),
    MoreItem(id: '3902', name: '优惠活动'),
    MoreItem(id: '4004', name: 'VR看房'),
  ];

  final _moreShortcutSelected = <String>{};

  StreamSubscription<List<House>>? _housesSubscription;
  List<House>? _houses;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _repo = HouseRepository();
    _filtersRepo = HouseFiltersRepository();

    _scrollController.addListener(() {
      final offset = _scrollController.hasClients
          ? _scrollController.offset.clamp(0.0, _bannerHeight)
          : 0.0;
      if ((offset - _scrollOffsetVN.value).abs() > 0.5) {
        _scrollOffsetVN.value = offset;
      }
    });

    _housesSubscription = _repo.housesStream.listen(
      (data) {
        if (!mounted) return;
        setState(() {
          _houses = data;
          _isLoading = false;
          _error = null;
        });
      },
      onError: (Object e, StackTrace st) {
        if (!mounted) return;
        setState(() {
          _error = e;
          _isLoading = false;
        });
      },
    );
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
    _housesSubscription?.cancel();
    _scrollController.dispose();
    _scrollOffsetVN.dispose();
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
        filter.district = result
            .cascadingPairsOf('region')
            .map((p) => {
                  "district_id": p.id,
                  "subdistrict_id": p.childIds,
                })
            .toList(growable: false);
      } else if (category.id == 'metro') {
        // 地铁
        filter.metro = result
            .cascadingPairsOf('metro')
            .map((p) => {
                  "line_id": p.id,
                  "station_id": p.childIds,
                })
            .toList(growable: false);
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
        filter.totalPrice = result
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
        filter.unitPrice = result
            .childRangesOf('unit')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
    } else if (result.tabIndex == 2) {
      // 户型筛选
      _filtersRepo.floorPlanBuyResult = result;
      filter.livingRoom = result.childIdsOf('living_room');
      filter.bathroom = result.childIdsOf('bathroom');
      filter.balcony = result.childIdsOf('balcony');
      filter.area = result
          .childRangesOf('area')
          .map((e) => {
                "id": e.id,
                "min": e.min,
                "max": e.max,
              })
          .toList(growable: false);
    } else if (result.tabIndex == 3) {
      // 更多筛选
      _filtersRepo.moreBuyResult = result;
      filter.homeType = result.childIdsOf('home_type');
      filter.saleStatus = result.childIdsOf('sale_status');
      filter.openTime = result.childIdsOf('open_time');
      filter.deliveryTime = result.childIdsOf('delivery_time');
      filter.decorationStatus = result.childIdsOf('decoration_status');
      filter.buildingFeatures = result.childIdsOf('building_features');
      filter.houseViewService = result.childIdsOf('house_view_service');
    } else if (result.tabIndex == 4) {
      // 排序筛选
      _filtersRepo.sortBuyResult = result;
      filter.sort = result.firstSelectedId;
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
    final l10n = AppLocalizations.of(context);
    _filter = _dropdownSelectorResultParser(result);
    if (_filter == null) {
      if (result.tabIndex == 3) {
        _moreShortcutSelected.clear();
        setState(() {});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
    if (result.tabIndex == 3) {
      final latestMoreFilterSelected = <String>[];
      if (_filter!.deliveryTime != null) {
        latestMoreFilterSelected.addAll(_filter!.deliveryTime!);
      }
      if (_filter!.buildingFeatures != null) {
        latestMoreFilterSelected.addAll(_filter!.buildingFeatures!);
      }
      if (_filter!.openTime != null) {
        latestMoreFilterSelected.addAll(_filter!.openTime!);
      }
      _moreShortcutSelected.clear();
      _moreShortcutSelected.addAll(latestMoreFilterSelected);
      setState(() {});
    }
    _repo.refreshData(_filter!);
  }

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetVN = ValueNotifier<double>(0);

  /// Identifies the filter bar content so [onSelectorWillShow] can measure its
  /// current on-screen position and scroll it to a pinned (sticky) position.
  final GlobalKey _filterHeaderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final searchRowHeight = kToolbarHeight + topPadding;
    const expandedHeight = kToolbarHeight + _bannerHeight;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffsetVN,
            builder: (context, offset, child) {
              final isCollapsed = offset >= _bannerHeight;
              final foregroundColor =
                  isCollapsed ? Colors.black87 : Colors.white;
              final searchFillColor =
                  isCollapsed ? const Color(0xFFF2F2F2) : Colors.white;
              final searchHintColor =
                  isCollapsed ? Colors.grey[600]! : Colors.grey;
              final systemOverlayStyle = isCollapsed
                  ? SystemUiOverlayStyle.dark
                  : SystemUiOverlayStyle.light;
              return _buildAppBar(
                l10n,
                searchRowHeight: searchRowHeight,
                expandedHeight: expandedHeight,
                foregroundColor: foregroundColor,
                searchFillColor: searchFillColor,
                searchHintColor: searchHintColor,
                systemOverlayStyle: systemOverlayStyle,
              );
            },
          ),
          const _NavigationGrid(),
          _buildSectionHeader('全部房源'),
          _buildStickyFilter(l10n),
          _buildHouseList(l10n),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    AppLocalizations? l10n, {
    required double searchRowHeight,
    required double expandedHeight,
    required Color foregroundColor,
    required Color searchFillColor,
    required Color searchHintColor,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      systemOverlayStyle: systemOverlayStyle,
      title: Row(
        children: [
          BackButton(color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            l10n?.buy ?? '',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: searchFillColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: searchHintColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '搜索热门项目名…',
                        style: TextStyle(
                          color: searchHintColor,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.location_on_outlined, color: foregroundColor),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.chat_bubble_outline, color: foregroundColor),
        ),
        const SizedBox(width: 4),
      ],
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildBannerBackground(),
      ),
    );
  }

  Widget _buildBannerBackground() {
    return SizedBox.expand(
      child: Image.asset(
        'assets/realestate/banner_buy.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildStickyFilter(AppLocalizations? l10n) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterHeaderDelegate(
        height: _filterHeaderHeight,
        child: Column(
          key: _filterHeaderKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownSelectorBar(
              controller: _controller,
              tabs: [
                DropdownTab(label: l10n?.region ?? ''),
                DropdownTab(label: l10n?.price ?? ''),
                DropdownTab(label: l10n?.floorPlan ?? ''),
                DropdownTab(label: l10n?.more ?? ''),
                DropdownTab(
                  child:
                      Image.asset('assets/sorting.png', width: 16, height: 16),
                ),
              ],
              selectorDelegates: [
                CascadingSelectorDelegate(
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
                GridSelectorDelegate(
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
                  applyText: AppLocalizations.of(context)?.apply ?? '',
                ),
                FlattenSelectorDelegate(
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
                FlattenSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchMoreBuyData,
                  selectedEntriesLoader: _filtersRepo.fetchMoreBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchMoreBuyResetData,
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
                ListSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchSortBuyData,
                  selectedEntriesLoader: _filtersRepo.fetchSortBuySelectedData,
                  resetEntriesLoader: _filtersRepo.fetchSortBuyResetData,
                  selectionMode: SelectionMode.single,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                ),
              ],
              onSelectorWillShow: (DropdownTabData tabData) async {
                // Programmatic sticky: scroll exactly enough so the filter bar
                // (SliverPersistentHeader) pins just below the collapsed app
                // bar, then let the overlay anchor to that final layout.
                // Returning `true` proceeds with showing the overlay.
                final ctx = _filterHeaderKey.currentContext;
                if (ctx != null) {
                  final RenderBox? box = ctx.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final double headerTop = box.localToGlobal(Offset.zero).dy;
                    final double stickyTop =
                        kToolbarHeight + MediaQuery.of(context).padding.top;
                    final double delta = headerTop - stickyTop;
                    if (delta > 0) {
                      await _scrollController.animateTo(
                        _scrollController.offset + delta,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                }
                return true;
              },
              onSelectorShowed: (DropdownTabData tabData) {
                debugPrint('onShowed: ${tabData.label}');
              },
              onSelectorWillHide: (DropdownTabData tabData) {
                debugPrint('onWillHide: ${tabData.label}');
                return true;
              },
              onSelectorHidden: (DropdownTabData tabData) {
                debugPrint('onHidden: ${tabData.label}');
              },
              onChanged: (DropdownSelectorResult result) {
                debugPrintLarge('onChanged: $result');
                _handleSelectorChange(result);
                _showSelectedResult(result);
              },
              onApplied: (DropdownSelectorResult result) {
                debugPrintLarge('onApplied: $result');
                _handleSelectorApply(result);
                if (result.tabIndex == 2) {
                  _floorPlanApplyTextDebounce?.cancel();
                  _floorPlanApplyTextRequestId++;
                  _floorPlanApplyText.value =
                      AppLocalizations.of(context)?.apply ?? '';
                }
                _showSelectedResult(result);
              },
              onReset: () {
                debugPrint('onReset');
                if (_controller.currentIndex == 2) {
                  _floorPlanApplyTextDebounce?.cancel();
                  _floorPlanApplyTextRequestId++;
                  _floorPlanApplyText.value =
                      AppLocalizations.of(context)?.apply ?? '';
                }
              },
            ),
            Container(
              height: _chipBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: moreShortcut.length,
                itemBuilder: (context, int index) {
                  final item = moreShortcut[index];
                  return ChoiceChip(
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    showCheckmark: false,
                    label: Text(item.name ?? ''),
                    selected: _moreShortcutSelected.contains(item.id ?? ''),
                    onSelected: (bool selected) async {
                      setState(() {
                        if (selected) {
                          _moreShortcutSelected.add(item.id ?? '');
                        } else {
                          _moreShortcutSelected.remove(item.id ?? '');
                        }
                      });
                      final ok = await _controller.apply(
                          tabIndex: 3, selectedEntryIds: _moreShortcutSelected);
                      if (!ok) {
                        debugPrint('apply failed');
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 10);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseList(AppLocalizations? l10n) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            l10n?.loadError('$_error') ?? '$_error',
          ),
        ),
      );
    }
    final houses = _houses;
    if (houses == null || houses.isEmpty) {
      return SliverFillRemaining(
        child: Center(child: Text(l10n?.nohomes ?? '')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final house = houses[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: AspectRatio(
                  aspectRatio: 120 / 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      house.picture ?? '',
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(house.title ?? ''),
                subtitle: Text(house.price ?? ''),
              ),
            );
          },
          childCount: houses.length,
        ),
      ),
    );
  }
}

class _NavData {
  const _NavData(this.value, this.label, this.color, {this.hot = false});
  final String value;
  final String label;
  final Color color;
  final bool hot;
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _NavigationGrid extends StatelessWidget {
  const _NavigationGrid();

  @override
  Widget build(BuildContext context) {
    const data = [
      _NavData('768', '全部楼盘', Color(0xFFFF6B6B)),
      _NavData('605', '在售楼盘', Color(0xFFFFA726)),
      _NavData('117', '折扣好盘', Color(0xFF66BB6A)),
      _NavData('23', '特价房源', Color(0xFF42A5F5)),
      _NavData('1', '本月开盘', Color(0xFFFF6B6B), hot: true),
    ];
    const items = [
      _NavItem(Icons.grid_view_outlined, '板块找房'),
      _NavItem(Icons.location_on_outlined, '地图找房'),
      _NavItem(Icons.person_outline, '找经纪人'),
      _NavItem(Icons.train_outlined, '近地铁'),
      _NavItem(Icons.school_outlined, '学校找房'),
    ];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: data
                      .map((item) => Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: item.color,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.value,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (item.hot)
                                        Positioned(
                                          top: -4,
                                          right: -10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'HOT',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.label,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: items
                      .map((item) => Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(item.icon,
                                      size: 28, color: Colors.black87),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.label,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}

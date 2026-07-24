import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/leyoujia/house_filters_repository.dart';
import 'package:example/my_widgets.dart';
import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';
import '../log.dart';
import 'house_repository.dart';
import 'utils.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});
  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  final _controller = DropdownSelectorController();
  late final HouseRepository _repo;
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  final ValueNotifier<String> _floorPlanApplyText = ValueNotifier<String>('');
  Timer? _floorPlanApplyTextDebounce;
  int _floorPlanApplyTextRequestId = 0;

  @override
  void initState() {
    super.initState();
    _repo = HouseRepository();
    _filtersRepo = HouseFiltersRepository();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (maxScroll - current < 200 && _repo.hasMore && !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() async {
    if (_isLoadingMore || !_repo.hasMore) return;
    if (!mounted) return;
    setState(() => _isLoadingMore = true);
    try {
      await _repo.loadNextPage();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
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
    _scrollController.dispose();
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
      _filtersRepo.regionResult = result.selected;
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
      _filtersRepo.rentalResult = result.selected;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'rent') {
        // 租金
        filter.rent = result
            .childRangesOf('rent')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
    } else if (result.tabIndex == 2) {
      // 户型筛选
      _filtersRepo.floorPlanRentResult = result.selected;
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
      // 排序筛选
      _filtersRepo.sortRentResult = result.selected;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.rent ?? ''),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child:
                Image.asset('assets/realestate/banner.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownSelectorBar(
              controller: _controller,
              // labelColor: Colors.orange,
              // indicator: Icon(Icons.arrow_upward, size: 16),
              // unselectedIndicator: Icon(Icons.arrow_downward, size: 16),
              // overlayStyle: DropdownOverlayStyle(
              //   backgroundColor: Colors.orange.withOpacity(0.54),
              // ),
              tabs: [
                DropdownTab(
                  // tag: 'region',
                  label: l10n?.region ?? '',
                  // labelGetter: (tabData, selected) {
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
                  entriesLoader: () =>
                      _filtersRepo.fetchRegionData(singleAll: true),
                  selectedEntriesLoader: _filtersRepo.fetchRegionSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchRegionResetData,
                  selectionMode: SelectionMode.single,
                  // skeletonBuilder: (_) => const Center(
                  //     child: CircularProgressIndicator(
                  //   color: Colors.black,
                  // )),
                  // categoryBackgroundColor: Colors.grey[200]!,
                  // terminalBackgroundColor: Colors.white,
                  radioBuilder: (context, selected) {
                    return MyRadio(value: selected);
                  },
                  checkboxBuilder: (context, selected) {
                    return MyCheckbox(value: selected);
                  },
                ),
                GridSelectorDelegate(
                  entriesLoader: _filtersRepo.fetchRentalData,
                  selectedEntriesLoader: _filtersRepo.fetchRentalSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchRentalResetData,
                  selectionMode: SelectionMode.single,
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
                ),
                FlattenSelectorDelegate(
                  entriesLoader: () =>
                      _filtersRepo.fetchFloorPlanRentData(singleAll: true),
                  selectedEntriesLoader:
                      _filtersRepo.fetchFloorPlanRentSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchFloorPlanRentResetData,
                  selectionMode: SelectionMode.single,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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
                  entriesLoader: _filtersRepo.fetchSortRentData,
                  selectedEntriesLoader: _filtersRepo.fetchSortRentSelectedData,
                  resetEntriesLoader: _filtersRepo.fetchSortRentResetData,
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
              onChanged: (tabData, selected) {

                final result = DropdownSelectorResult(tabData: tabData, selected: selected);
                debugPrintLarge('onChanged: $result');
                _handleSelectorChange(result);
                _showSelectedResult(result);
              },
              onApplied: (tabData, selected) {

                final result = DropdownSelectorResult(tabData: tabData, selected: selected);
                debugPrintLarge('onApplied: $result');
                _handleSelectorApply(result);
                if (result.tabIndex == 2) {
                  _floorPlanApplyTextDebounce?.cancel();
                  _floorPlanApplyTextRequestId++;
                  _floorPlanApplyText.value = l10n?.apply ?? '';
                }
                _showSelectedResult(result);
              },
              onReset: () {
                debugPrint('onReset');
                if (_controller.currentIndex == 2) {
                  _floorPlanApplyTextDebounce?.cancel();
                  _floorPlanApplyTextRequestId++;
                  _floorPlanApplyText.value = l10n?.apply ?? '';
                }
              },
            ),
          ),
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
                  controller: _scrollController,
                  itemCount: houses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == houses.length) {
                      return HouseListFooter(
                        isLoadingMore: _isLoadingMore,
                        hasMore: _repo.hasMore,
                        pageInfo:
                            '第 ${_repo.loadedPages} / ${_repo.totalPages} 页',
                        noMoreText: l10n?.noMore,
                      );
                    }
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

import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:example/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'house_filters_repository.dart';
import 'house_repository.dart';
import 'utils.dart';

/// For sale
class HousePage extends StatefulWidget {
  const HousePage({super.key});
  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final _controller = DropdownSelectorController();
  late final HouseRepository _repo;
  late final HouseFiltersRepository _filtersRepo;
  HouseFilter? _filter;

  final ValueNotifier<String> _moreApplyText = ValueNotifier<String>('');
  Timer? _moreApplyTextDebounce;
  int _moreApplyTextRequestId = 0;

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
      noMinHintText: l10n?.noMin ?? '',
      noMaxHintText: l10n?.noMax ?? '',
    );
    if (_moreApplyText.value.isEmpty) {
      _moreApplyText.value = l10n?.apply ?? '';
    }
  }

  @override
  void dispose() {
    _repo.dispose();
    _controller.dispose();
    _moreApplyTextDebounce?.cancel();
    _moreApplyText.dispose();
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
      // Neighborhood filter
      _filtersRepo.neighborhoodResult = result;
      filter.region = result
          .cascadingPairsOf('neighborhood')
          .map((p) => {
                "region_id": p.id,
                "neighborhood_id": p.childIds,
              })
          .toList(growable: false);
    } else if (result.tabIndex == 1) {
      // Price filter
      _filtersRepo.priceResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'list_price') {
        filter.listPrice = result
            .childRangesOf('list_price')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      } else if (category.id == 'monthly_price') {
        filter.monthlyPayment = result
            .childRangesOf('monthly_price')
            .map((e) => {
                  "id": e.id,
                  "min": e.min,
                  "max": e.max,
                })
            .toList(growable: false);
      }
    } else if (result.tabIndex == 2) {
      // Rooms filter
      _filtersRepo.roomsResult = result;
      filter.bedrooms = result.childIdsOf('bedrooms');
      filter.bathrooms = result.childIdsOf('bathrooms');
    } else if (result.tabIndex == 3) {
      // More filter
      _filtersRepo.moreResult = result;
      filter.homeType = result.childIdsOf('home_type');
      filter.listsDetails = result.childIdsOf('lists_details');
      filter.squareFeet = result.childIdsOf('square_feet');
      filter.lotSize = result.childIdsOf('lot_size');
      filter.homeFeatures = result.childIdsOf('home_features');
      filter.commute = result.childIdsOf('commute');
      filter.expandedSearch = result.childIdsOf('expanded_search');
    } else if (result.tabIndex == 4) {
      // Sort filter
      _filtersRepo.sortResult = result;
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
    if (result.tabIndex == 3) {
      _moreApplyTextDebounce?.cancel();

      final requestId = ++_moreApplyTextRequestId;
      _moreApplyText.value = l10n?.viewing ?? '';

      _moreApplyTextDebounce = Timer(
        const Duration(milliseconds: 250),
        () async {
          try {
            final count = await _repo.previewCount(_filter!);
            if (!mounted || requestId != _moreApplyTextRequestId) return;
            final l10n = AppLocalizations.of(context);
            _moreApplyText.value = count == 0
                ? (l10n?.nohomes ?? '')
                : (l10n?.viewhomes(count) ?? '');
          } catch (_) {
            if (!mounted || requestId != _moreApplyTextRequestId) return;
            _moreApplyText.value = AppLocalizations.of(context)?.apply ?? '';
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
        title: Text(AppLocalizations.of(context)?.sell ?? ''),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(userCityId),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/realestate/banner_sale.jpg',
                width: double.infinity,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          DropdownSelectorBar(
            controller: _controller,
            isScrollable: true,
            // labelColor: Colors.orange,
            // indicator: Icon(Icons.arrow_upward, size: 16),
            // unselectedIndicator: Icon(Icons.arrow_downward, size: 16),
            // overlayStyle: DropdownOverlayStyle(
            //   backgroundColor: Colors.orange.withOpacity(0.54),
            // ),
            tabs: [
              DropdownTab(label: l10n?.neighborhood ?? ''),
              DropdownTab(
                // tag: 'price',
                label: l10n?.price ?? '',
                // labelGetter: (DropdownSelectorResult result) {
                //   // Optional: user-defined label based on the selection
                //   return 'Custom label';
                // },
              ),
              DropdownTab(label: l10n?.rooms ?? ''),
              DropdownTab(label: l10n?.more ?? ''),
              DropdownTab(
                child: Image.asset('assets/sorting.png', width: 16, height: 16),
              ),
            ],
            selectorDelegates: [
              CascadingSelectorDelegate(
                entriesLoader: _filtersRepo.fetchNeighborhoodData,
                selectedEntriesLoader:
                    _filtersRepo.fetchNeighborhoodSelectedData,
                resetEntriesLoader: _filtersRepo.fetchNeighborhoodResetData,
                selectionMode: SelectionMode.multiple,
                sideBarTheme: const SelectorSideBarTheme(width: 150),
                isScrollable: true,
              ),
              GridSelectorDelegate(
                entriesLoader: _filtersRepo.fetchPriceData,
                selectedEntriesLoader: _filtersRepo.fetchPriceSelectedData,
                // resetEntriesLoader: _filtersRepo.fetchPriceResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 1,
                childAspectRatio: 10,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
              ),
              GridSelectorDelegate(
                entriesLoader: _filtersRepo.fetchRoomsData,
                selectedEntriesLoader: _filtersRepo.fetchRoomsSelectedData,
                // resetEntriesLoader: _filtersRepo.fetchRoomsResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
              ),
              ListSelectorDelegate(
                entriesLoader: _filtersRepo.fetchMoreData,
                selectedEntriesLoader: _filtersRepo.fetchMoreSelectedData,
                resetEntriesLoader: _filtersRepo.fetchMoreResetData,
                selectionMode: SelectionMode.multiple,
                resetText: AppLocalizations.of(context)?.reset ?? '',
                applyText: AppLocalizations.of(context)?.apply ?? '',
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
                chipBarTheme: const SelectorChipBarTheme(
                  variant: SelectorChipVariant.outlined,
                ),
              ),
              ListSelectorDelegate(
                entriesLoader: _filtersRepo.fetchSortData,
                selectedEntriesLoader: _filtersRepo.fetchSortSelectedData,
                resetEntriesLoader: _filtersRepo.fetchSortResetData,
                selectionMode: SelectionMode.single,
              ),
            ],
            onSelectorShowed: (DropdownTabData tabData) {
              debugPrint('onShowed: ${tabData.label}');
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
              if (result.tabIndex == 3) {
                _moreApplyTextDebounce?.cancel();
                _moreApplyTextRequestId++;
                _moreApplyText.value = l10n?.apply ?? '';
              }
              _showSelectedResult(result);
            },
            onReset: () {
              debugPrint('onReset');
              if (_controller.currentIndex == 3) {
                _moreApplyTextDebounce?.cancel();
                _moreApplyTextRequestId++;
                _moreApplyText.value = l10n?.apply ?? '';
              }
            },
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
                  itemCount: houses.length,
                  itemBuilder: (context, index) {
                    final house = houses[index];
                    final broker = (house.price ?? '').split('\n').lastOrNull;
                    final tag = house.tag?.trim();
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.asset(
                                  house.picture ?? '',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if ((tag ?? '').isNotEmpty)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      tag!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              const Positioned(
                                top: 10,
                                right: 10,
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                              Positioned(
                                bottom: 14,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    4,
                                    (i) => Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: i == 0
                                            ? Colors.white
                                            : Colors.white70,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        house.title ?? '',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '•••',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  house.second ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  house.address ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    height: 1.15,
                                  ),
                                ),
                                if ((broker ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    broker!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
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

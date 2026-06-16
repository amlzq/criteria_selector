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
  final _controller = DropselectTabController();
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

  void _showSelectedResult(DropselectResult result) {
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

  HouseFilter? _dropselectResultParser(DropselectResult result) {
    final filter = HouseFilter(cityId: userCityId);
    if (result.tabIndex == 0) {
      // Price filter
      _filtersRepo.priceResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'list_price') {
        filter.listPrice = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          filter.listPrice!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      } else if (category.id == 'monthly_price') {
        filter.monthlyPayment = <Map<String, dynamic>>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          filter.monthlyPayment!.add({"id": e.id, "min": e.min, "max": e.max});
        }
      }
    } else if (result.tabIndex == 1) {
      // Rooms filter
      _filtersRepo.roomsResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'bedrooms') {
        filter.bedrooms = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          filter.bedrooms!.add(e.id);
        }
      } else if (category.id == 'bathrooms') {
        filter.bathrooms = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorIntEntry;
          filter.bathrooms!.add(e.id);
        }
      }
    } else if (result.tabIndex == 2) {
      // More filter
      _filtersRepo.moreResult = result;
      final category = result.selected.firstOrNull;
      if (category == null) return null;
      if (category.id == 'home_type') {
        filter.homeType = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.homeType!.add(e.id);
        }
      } else if (category.id == 'lists_details') {
        filter.listsDetails = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.listsDetails!.add(e.id);
        }
      } else if (category.id == 'square_feet') {
        filter.squareFeet = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.squareFeet!.add(e.id);
        }
      } else if (category.id == 'lot_size') {
        filter.lotSize = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.lotSize!.add(e.id);
        }
      } else if (category.id == 'home_features') {
        filter.homeFeatures = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.homeFeatures!.add(e.id);
        }
      } else if (category.id == 'commute') {
        filter.commute = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.commute!.add(e.id);
        }
      } else if (category.id == 'expanded_search') {
        filter.expandedSearch = <String>[];
        for (var e in category.children ?? {}) {
          e as SelectorTextEntry;
          filter.expandedSearch!.add(e.id);
        }
      }
    } else if (result.tabIndex == 3) {
      // Sort filter
      _filtersRepo.sortResult = result;
      final entry = result.selected.firstOrNull;
      if (entry == null) return null;
      filter.sort = entry.id;
    }
    return filter;
  }

  void _handleSelectorChange(DropselectResult result) async {
    final l10n = AppLocalizations.of(context);
    _filter = _dropselectResultParser(result);
    if (_filter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.filterParseFailed ?? '')),
      );
      return;
    }
    if (result.tabIndex == 2) {
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

  void _handleSelectorApply(DropselectResult result) {
    final l10n = AppLocalizations.of(context);
    _filter = _dropselectResultParser(result);
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
                'assets/realestate/banner1.jpg',
                width: double.infinity,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          DropselectTabBar(
            controller: _controller,
            isScrollable: true,
            // labelColor: Colors.orange,
            // indicator: Icon(Icons.arrow_upward, size: 16),
            // unselectedIndicator: Icon(Icons.arrow_downward, size: 16),
            // overlayStyle: DropdownOverlayStyle(
            //   backgroundColor: Colors.orange.withOpacity(0.54),
            // ),
            tabs: [
              DropselectTab(
                // tag: 'region',
                label: l10n?.price ?? '',
                // labelGetter: (DropselectResult result) {
                //   // Optional: user-defined label based on the selection
                //   return 'Custom label';
                // },
              ),
              DropselectTab(label: l10n?.rooms ?? ''),
              DropselectTab(label: l10n?.more ?? ''),
              DropselectTab(
                child: Image.asset('assets/sorting.png', width: 16, height: 16),
              ),
            ],
            selectors: [
              GridSelector(
                dataFetcher: _filtersRepo.fetchPriceData,
                selectedDataFetcher: _filtersRepo.fetchPriceSelectedData,
                // resetDataFetcher: _filtersRepo.fetchPriceResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 1,
                childAspectRatio: 10,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
              ),
              GridSelector(
                dataFetcher: _filtersRepo.fetchRoomsData,
                selectedDataFetcher: _filtersRepo.fetchRoomsSelectedData,
                // resetDataFetcher: _filtersRepo.fetchRoomsResetData,
                selectionMode: SelectionMode.multiple,
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                gridTileTheme: const SelectorGridTileTheme(
                  variant: SelectorGridTileVariant.outlined,
                ),
              ),
              ListSelector(
                dataFetcher: _filtersRepo.fetchMoreData,
                selectedDataFetcher: _filtersRepo.fetchMoreSelectedData,
                resetDataFetcher: _filtersRepo.fetchMoreResetData,
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
              ListSelector(
                dataFetcher: _filtersRepo.fetchSortData,
                selectedDataFetcher: _filtersRepo.fetchSortSelectedData,
                resetDataFetcher: _filtersRepo.fetchSortResetData,
                selectionMode: SelectionMode.single,
              ),
            ],
            onSelectorShowed: (DropselectTabData tabData) {
              debugPrint('onShowed: ${tabData.label}');
            },
            onSelectorHidden: (DropselectTabData tabData) {
              debugPrint('onHidden: ${tabData.label}');
            },
            onChanged: (DropselectResult result) {
              debugPrintLarge('onChanged: $result');
              _handleSelectorChange(result);
              _showSelectedResult(result);
            },
            onApplied: (DropselectResult result) {
              debugPrintLarge('onApplied: $result');
              _handleSelectorApply(result);
              if (result.tabIndex == 2) {
                _moreApplyTextDebounce?.cancel();
                _moreApplyTextRequestId++;
                _moreApplyText.value = l10n?.apply ?? '';
              }
              _showSelectedResult(result);
            },
            onReset: () {
              debugPrint('onReset');
              if (_controller.currentIndex == 2) {
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

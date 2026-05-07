import 'dart:async';
import 'dart:convert';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/foundation.dart';

import 'utils.dart';

class HouseFiltersRepository {
  /// 区域的 初始选中项
  DropselectResult? regionResult;

  final regionIniteialSelected = {
    SelectorCategoryEntry(
      id: 'community',
      name: '',
      children: {SelectorTextEntry.any(parentId: 'community', name: '')},
    )
  };

  SelectorEntries? fetchRegionSelectedData() =>
      regionResult?.selected ?? regionIniteialSelected;

  SelectorEntries? fetchRegionResetData() => regionIniteialSelected;

  Future<SelectorEntries> fetchRegionData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    // 板块/地段
    // 是地产板块（ neighborhood/community ），而不是行政区
    final community =
        RegionData.fromJson(json.decode(await loadJsonData('community.json')));
    debugPrint('community length: ${community.data?.length}');

    final metro =
        RegionData.fromJson(json.decode(await loadJsonData('metro.json')));
    debugPrint('metro length: ${metro.data?.length}');

    final nearby =
        RegionData.fromJson(json.decode(await loadJsonData('nearby.json')));
    debugPrint('nearby length: ${nearby.data?.length}');

    final region = [community, metro, nearby];
    debugPrint('region length: ${region.length}');
    SelectorEntries entries = region
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => SelectorTextEntry(
                      parentId: category.id!,
                      id: l1.id!,
                      name: l1.name!,
                      enabled: l1.enabled ?? true,
                      children: l1.data
                          ?.map((l2) => SelectorTextEntry(
                                parentId: l1.id!,
                                id: l2.id!,
                                name: l2.name!,
                                enabled: l2.enabled ?? true,
                              ))
                          .toSet(),
                      immediate: category.id == 'nearby',
                    ))
                .toSet(),
            selectionMode: category.id == 'nearby'
                ? SelectionMode.single
                : SelectionMode.multiple,
          ),
        )
        .toSet();

    // 将“距地铁”作为地铁类别的 header
    final metroEntry =
        entries.firstWhere((e) => e.id == 'metro') as SelectorCategoryEntry;
    final metroRadiusEntry =
        metroEntry.children?.firstWhere((e) => e.id == 'metro_radius');
    metroEntry.children?.remove(metroRadiusEntry);
    metroEntry.header = metroRadiusEntry;

    // 插入"不限"选项
    for (SelectorEntry category in entries) {
      category.children?.insert(
          0,
          SelectorTextEntry.any(
              parentId: category.id, name: '不限', immediate: true));
      for (SelectorEntry l1 in category.children ?? []) {
        l1.children
            ?.insert(0, SelectorTextEntry.any(parentId: l1.id, name: '不限'));
      }
    }

    debugPrint('region length: ${entries.length}');
    return Future.value(entries);
  }

  /// 排序 初始选中项
  DropselectResult? buyPriceResult;

  final buyPriceIniteialSelected = {
    SelectorCategoryEntry(
      id: 'total',
      name: '',
      children: {SelectorIntEntry(parentId: 'total', id: '203', name: '')},
    ),
    SelectorCategoryEntry(
      id: 'unit',
      name: '',
      children: {SelectorIntEntry(parentId: 'unit', id: '104', name: '')},
    ),
  };

  SelectorEntries? fetchBuyPriceSelectedData() =>
      buyPriceResult?.selected; // ?? buyPriceIniteialSelected;

  SelectorEntries? fetchBuyPriceResetData() => buyPriceIniteialSelected;

  Future<SelectorEntries> fetchBuyPriceData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    final totalPrice =
        PriceData.fromJson(json.decode(await loadJsonData('total_price.json')));
    debugPrint('totalPrice length: ${totalPrice.data?.length}');

    final unitPrice =
        PriceData.fromJson(json.decode(await loadJsonData('unit_price.json')));
    debugPrint('unitPrice length: ${unitPrice.data?.length}');

    final prices = [totalPrice, unitPrice];
    SelectorEntries entries = prices
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => SelectorIntEntry(
                      parentId: category.id!,
                      id: l1.id!,
                      name: l1.name,
                      min: l1.min,
                      max: l1.max,
                    ))
                .toSet(),
            selectionMode: SelectionMode.multiple,
          ),
        )
        .toSet();

    // 插入一些特殊选项
    for (SelectorEntry category in entries) {
      // 插入"不限"选项
      category.children?.insert(
          0,
          SelectorIntEntry.any(
              parentId: category.id, name: '不限', immediate: false));
      // 插入"自定义"选项
      category.children?.insert(
          0,
          SelectorIntEntry.custom(
              parentId: category.id,
              inputLabel: '自定义',
              minHintText: '最小值',
              maxHintText: '最大值'));
    }

    debugPrint('prices length: ${entries.length}');
    return Future.value(entries);
  }

  /// 价格的 初始选中项
  DropselectResult? sellPriceResult;

  final sellPriceIniteialSelected = {
    SelectorCategoryEntry(
      id: 'total',
      name: '',
      children: {SelectorIntEntry.any(parentId: 'total', name: '不限')},
    )
  };

  SelectorEntries? fetchSellPriceSelectedData() =>
      sellPriceResult?.selected ?? sellPriceIniteialSelected;

  SelectorEntries? fetchSellPriceResetData() => sellPriceIniteialSelected;

  Future<SelectorEntries> fetchSellPriceData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    final totalPrice =
        PriceData.fromJson(json.decode(await loadJsonData('total_price.json')));
    debugPrint('totalPrice length: ${totalPrice.data?.length}');

    final downpay =
        PriceData.fromJson(json.decode(await loadJsonData('downpay.json')));
    debugPrint('downpay length: ${downpay.data?.length}');

    final prices = [totalPrice, downpay];
    SelectorEntries entries = prices
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => SelectorIntEntry(
                      parentId: category.id!,
                      id: l1.id!,
                      name: l1.name,
                      min: l1.min,
                      max: l1.max,
                    ))
                .toSet(),
            selectionMode: category.id == 'downpay'
                ? SelectionMode.single
                : SelectionMode.multiple,
          ),
        )
        .toSet();

    // 插入一些特殊选项
    for (SelectorEntry category in entries) {
      // 插入"不限"选项
      category.children?.insert(
          0,
          SelectorIntEntry.any(
              parentId: category.id, name: '不限', immediate: false));
      // 插入"自定义"选项
      category.children?.insert(
          0,
          SelectorIntEntry.custom(
              parentId: category.id,
              inputLabel: '自定义',
              minHintText: '最小值',
              maxHintText: '最大值'));
    }

    debugPrint('prices length: ${entries.length}');
    return Future.value(entries);
  }

  /// 租金的 初始选中项
  DropselectResult? rentalResult;

  final rentalIniteialSelected = {
    SelectorCategoryEntry(
      id: 'rent',
      name: '',
      children: {SelectorIntEntry.any(parentId: 'total', name: '不限')},
    )
  };

  SelectorEntries? fetchRentalSelectedData() =>
      rentalResult?.selected ?? rentalIniteialSelected;

  SelectorEntries? fetchRentalResetData() => rentalIniteialSelected;

  Future<SelectorEntries> fetchRentalData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    final rent =
        PriceData.fromJson(json.decode(await loadJsonData('rental.json')));
    debugPrint('rent length: ${rent.data?.length}');

    final prices = [rent];
    SelectorEntries entries = prices
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => SelectorIntEntry(
                      parentId: category.id!,
                      id: l1.id!,
                      name: l1.name,
                      min: l1.min,
                      max: l1.max,
                    ))
                .toSet(),
            selectionMode: SelectionMode.multiple,
          ),
        )
        .toSet();

    // 插入一些特殊选项
    for (SelectorEntry category in entries) {
      // 插入"不限"选项
      category.children?.insert(
          0,
          SelectorIntEntry.any(
              parentId: category.id, name: '不限', immediate: false));
      // 插入"自定义"选项
      category.children?.insert(
          0,
          SelectorIntEntry.custom(
              parentId: category.id,
              inputLabel: '自定义',
              minHintText: '最小值',
              maxHintText: '最大值'));
    }

    debugPrint('prices length: ${entries.length}');
    return Future.value(entries);
  }

  /// 户型的 初始选中项
  DropselectResult? floorPlanBuyResult;

  final floorPlanBuyIniteialSelected = <SelectorCategoryEntry>{};

  SelectorEntries? fetchFloorPlanBuySelectedData() =>
      floorPlanBuyResult?.selected ?? floorPlanBuyIniteialSelected;

  SelectorEntries? fetchFloorPlanBuyResetData() => floorPlanBuyIniteialSelected;

  Future<SelectorEntries> fetchFloorPlanBuyData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final floorPlan =
        floorPlanFromJson(await loadJsonData('floor_plan_buy.json'));
    debugPrint('floorPlan length: ${floorPlan.length}');
    SelectorEntries entries = floorPlan
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => l1.id == 'area'
                    ? SelectorRangeEntry(
                        parentId: category.id!,
                        id: l1.id!,
                        name: l1.name,
                        min: l1.min,
                        max: l1.max,
                      )
                    : SelectorTextEntry(
                        parentId: category.id!,
                        id: l1.id!,
                        name: l1.name,
                      ))
                .toSet(),
            selectionMode: SelectionMode.multiple,
          ),
        )
        .toSet();

    // 插入"价格自定义"选项
    for (SelectorEntry category in entries) {
      if (category.id == 'area') {
        category.children?.add(SelectorIntEntry.custom(
            parentId: category.id,
            name: '自定义面积',
            minHintText: '最小值',
            maxHintText: '最大值'));
        break;
      }
    }

    debugPrint('floorPlan length: ${entries.length}');
    return Future.value(entries);
  }

  /// 户型的 初始选中项
  DropselectResult? floorPlanSellResult;

  final floorPlanSellIniteialSelected = <SelectorCategoryEntry>{};

  SelectorEntries? fetchFloorPlanSellSelectedData() =>
      floorPlanSellResult?.selected ?? floorPlanSellIniteialSelected;

  SelectorEntries? fetchFloorPlanSellResetData() =>
      floorPlanSellIniteialSelected;

  Future<SelectorEntries> fetchFloorPlanSellData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final floorPlan =
        floorPlanFromJson(await loadJsonData('floor_plan_sell.json'));
    debugPrint('floorPlan length: ${floorPlan.length}');
    SelectorEntries entries = floorPlan
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => l1.id == 'area'
                    ? SelectorRangeEntry(
                        parentId: category.id!,
                        id: l1.id!,
                        name: l1.name,
                        min: l1.min,
                        max: l1.max,
                      )
                    : SelectorTextEntry(
                        parentId: category.id!,
                        id: l1.id!,
                        name: l1.name,
                      ))
                .toSet(),
            selectionMode: SelectionMode.multiple,
          ),
        )
        .toSet();

    // 插入"价格自定义"选项
    for (SelectorEntry category in entries) {
      if (category.id == 'area') {
        category.children?.add(SelectorIntEntry.custom(
            parentId: category.id,
            name: '自定义面积',
            minHintText: '最小值',
            maxHintText: '最大值'));
        break;
      }
    }

    debugPrint('floorPlan length: ${entries.length}');
    return Future.value(entries);
  }

  /// 户型的 初始选中项
  DropselectResult? floorPlanRentResult;

  final floorPlanRentIniteialSelected = <SelectorCategoryEntry>{};

  SelectorEntries? fetchFloorPlanRentSelectedData() =>
      floorPlanRentResult?.selected ?? floorPlanRentIniteialSelected;

  SelectorEntries? fetchFloorPlanRentResetData() =>
      floorPlanRentIniteialSelected;

  Future<SelectorEntries> fetchFloorPlanRentData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final floorPlan =
        floorPlanFromJson(await loadJsonData('floor_plan_rent.json'));
    debugPrint('floorPlan length: ${floorPlan.length}');
    SelectorEntries entries = floorPlan
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => l1.id == 'area'
                    ? SelectorRangeEntry(
                        parentId: category.id!,
                        id: l1.id!,
                        name: l1.name,
                        min: l1.min,
                        max: l1.max,
                      )
                    : SelectorTextEntry(
                        parentId: category.id!,
                        id: l1.id!,
                        name: l1.name,
                      ))
                .toSet(),
            selectionMode: SelectionMode.multiple,
          ),
        )
        .toSet();

    debugPrint('floorPlan length: ${entries.length}');
    return Future.value(entries);
  }

  /// 排序 初始选中项
  DropselectResult? sortBuyResult;

  final sortBuyIniteialSelected = <SelectorTextEntry>{
    SelectorTextEntry.id(id: 'default_sort')
  };

  SelectorEntries? fetchSortBuySelectedData() =>
      sortBuyResult?.selected ?? sortBuyIniteialSelected;

  SelectorEntries? fetchSortBuyResetData() => sortBuyIniteialSelected;

  Future<SelectorEntries> fetchSortBuyData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final sort = sortFromJson(await loadJsonData('sort_buy.json'));
    debugPrint('sort length: ${sort.length}');
    SelectorEntries entries = sort
        .map((e) => SelectorTextEntry.name(
              id: e.id!,
              name: e.name!,
              immediate: true,
            ))
        .toSet();

    debugPrint('sort length: ${entries.length}');
    return Future.value(entries);
  }

  /// 排序 初始选中项
  DropselectResult? sortSellResult;

  final sortSellIniteialSelected = <SelectorTextEntry>{
    SelectorTextEntry.id(id: 'comprehensive_sort')
  };

  SelectorEntries? fetchSortSellSelectedData() =>
      sortSellResult?.selected ?? sortSellIniteialSelected;

  SelectorEntries? fetchSortSellResetData() => sortSellIniteialSelected;

  Future<SelectorEntries> fetchSortSellData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final sort = sortFromJson(await loadJsonData('sort_sell.json'));
    debugPrint('sort length: ${sort.length}');
    SelectorEntries entries = sort
        .map((e) => SelectorTextEntry.name(
              id: e.id!,
              name: e.name!,
              immediate: true,
            ))
        .toSet();

    debugPrint('sort length: ${entries.length}');
    return Future.value(entries);
  }

  /// 排序 初始选中项
  DropselectResult? sortRentResult;

  final sortRentIniteialSelected = <SelectorTextEntry>{
    SelectorTextEntry.id(id: 'comprehensive_sort')
  };

  SelectorEntries? fetchSortRentSelectedData() =>
      sortRentResult?.selected ?? sortRentIniteialSelected;

  SelectorEntries? fetchSortRentResetData() => sortRentIniteialSelected;

  Future<SelectorEntries> fetchSortRentData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final sort = sortFromJson(await loadJsonData('sort_rent.json'));
    debugPrint('sort length: ${sort.length}');
    SelectorEntries entries = sort
        .map((e) => SelectorTextEntry.name(
              id: e.id!,
              name: e.name!,
              immediate: true,
            ))
        .toSet();

    debugPrint('sort length: ${entries.length}');
    return Future.value(entries);
  }
}

class RegionData {
  String? id;
  String? name;
  bool? enabled;
  List<RegionData>? data;

  RegionData({this.id, this.name, this.data});

  RegionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    enabled = json['enabled'];
    if (json['data'] != null) {
      data = <RegionData>[];
      json['data'].forEach((v) {
        data!.add(RegionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['id'] = id;
    json['name'] = name;
    json['enabled'] = enabled;
    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }
    return json;
  }
}

class PriceData {
  String? id;
  String? name;
  List<PriceItem>? data;

  PriceData({this.id, this.name, this.data});

  PriceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['data'] != null) {
      data = <PriceItem>[];
      json['data'].forEach((v) {
        data!.add(PriceItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PriceItem {
  String? id;
  String? name;
  int? min;
  int? max;

  PriceItem({this.id, this.name, this.min, this.max});

  PriceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['min'] = min;
    data['max'] = max;
    return data;
  }
}

List<FloorPlanData> floorPlanFromJson(String str) => List<FloorPlanData>.from(
    json.decode(str).map((x) => FloorPlanData.fromJson(x)));

String floorPlanToJson(List<FloorPlanData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FloorPlanData {
  String? id;
  String? name;
  List<FloorPlanItem>? data;

  FloorPlanData({this.id, this.name, this.data});

  FloorPlanData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['data'] != null) {
      data = <FloorPlanItem>[];
      json['data'].forEach((v) {
        data!.add(new FloorPlanItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FloorPlanItem {
  String? id;
  String? name;
  int? min;
  int? max;

  FloorPlanItem({this.id, this.name, this.min, this.max});

  FloorPlanItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['min'] = this.min;
    data['max'] = this.max;
    return data;
  }
}

List<SortData> sortFromJson(String str) =>
    List<SortData>.from(json.decode(str).map((x) => SortData.fromJson(x)));

String sortToJson(List<SortData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SortData {
  String? id;
  String? name;

  SortData({this.id, this.name});

  SortData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/foundation.dart';

import 'utils.dart';

class HouseFiltersRepository {
  HouseFiltersRepository({
    this.anyOptionText = 'Any',
    this.noMinHintText = 'No min',
    this.noMaxHintText = 'No max',
  });

  String anyOptionText;
  String noMinHintText;
  String noMaxHintText;

  void updateTexts({
    String? anyOptionText,
    String? noMinHintText,
    String? noMaxHintText,
  }) {
    if (anyOptionText != null) this.anyOptionText = anyOptionText;
    if (noMinHintText != null) this.noMinHintText = noMinHintText;
    if (noMaxHintText != null) this.noMaxHintText = noMaxHintText;
  }

  DropselectResult? priceResult;

  SelectorEntries? fetchPriceSelectedData() => priceResult?.selected;

  Future<SelectorEntries> fetchPriceData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    final prices = priceFromJson(await loadJsonData('price.json'));

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

    // Insert some special options
    for (SelectorEntry category in entries) {
      // Insert the "Any" option
      category.children?.insert(
          0,
          SelectorIntEntry.any(
              parentId: category.id, name: anyOptionText, immediate: false));
      // Insert the "Custom" option
      category.children?.insert(
          0,
          SelectorIntEntry.custom(
              parentId: category.id,
              minHintText: noMinHintText,
              maxHintText: noMaxHintText));
    }

    debugPrint('prices length: ${entries.length}');
    return Future.value(entries);
  }

  DropselectResult? roomsResult;

  final roomsIniteialSelected = {
    SelectorCategoryEntry(
      id: 'bedrooms',
      name: '',
      children: {SelectorIntEntry(parentId: 'bedrooms', id: '203', name: '')},
    ),
    SelectorCategoryEntry(
      id: 'bathrooms',
      name: '',
      children: {SelectorIntEntry(parentId: 'bathrooms', id: '104', name: '')},
    ),
  };

  SelectorEntries? fetchRoomsSelectedData() =>
      roomsResult?.selected; // ?? roomsIniteialSelected;

  SelectorEntries? fetchRoomsResetData() => roomsIniteialSelected;

  Future<SelectorEntries> fetchRoomsData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    final rooms = roomsFromJson(await loadJsonData('rooms.json'));

    SelectorEntries entries = rooms
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) => SelectorIntEntry(
                      parentId: category.id!,
                      id: l1.id!,
                      name: l1.name,
                    ))
                .toSet(),
            selectionMode: SelectionMode.multiple,
          ),
        )
        .toSet();

    // Insert some special options
    for (SelectorEntry category in entries) {
      // Insert the "Any" option
      category.children?.insert(
          0,
          SelectorIntEntry.any(
              parentId: category.id, name: anyOptionText, immediate: false));
    }

    debugPrint('rooms length: ${entries.length}');
    return Future.value(entries);
  }

  DropselectResult? moreResult;

  final moreIniteialSelected = <SelectorCategoryEntry>{};

  SelectorEntries? fetchMoreSelectedData() =>
      moreResult?.selected ?? moreIniteialSelected;

  SelectorEntries? fetchMoreResetData() => moreIniteialSelected;

  Future<SelectorEntries> fetchMoreData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final more = moreFromJson(await loadJsonData('more.json'));
    debugPrint('more length: ${more.length}');

    SelectorListConfig? listConfig(String categoryId) {
      if (categoryId == 'expanded_search') {
        return const SelectorListConfig();
      } else {
        return null;
      }
    }

    SelectorGridConfig? gridConfig(String categoryId) {
      if (categoryId == 'home_type' ||
          categoryId == 'lists_details' ||
          categoryId == 'commute') {
        return const SelectorGridConfig(
          crossAxisCount: 2,
          childAspectRatio: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        );
      }
      if (categoryId == 'square_feet' ||
          categoryId == 'lot_size' ||
          categoryId == 'home_features') {
        return const SelectorGridConfig(
          crossAxisCount: 3,
          childAspectRatio: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        );
      } else {
        return null;
      }
    }

    SelectorChipConfig? chipConfig(String categoryId) {
      return null;
    }

    SelectorEntries entries = more
        .map(
          (category) => SelectorCategoryEntry(
            id: category.id!,
            name: category.name!,
            children: category.data
                ?.map((l1) =>
                    (category.id == 'square_feet' || category.id == 'lot_size')
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
            selectionMode: category.id == 'expanded_search'
                ? SelectionMode.single
                : SelectionMode.multiple,
            listConfig: listConfig(category.id!),
            gridConfig: gridConfig(category.id!),
            chipConfig: chipConfig(category.id!),
          ),
        )
        .toSet();

    // Insert the "Custom range" option
    for (SelectorEntry category in entries) {
      if (category.id == 'square_feet' || category.id == 'lot_size') {
        category.children?.add(SelectorIntEntry.custom(
            parentId: category.id,
            minHintText: noMinHintText,
            maxHintText: noMaxHintText));
        break;
      }
    }

    debugPrint('more length: ${entries.length}');
    return Future.value(entries);
  }

  DropselectResult? sortResult;

  final sortIniteialSelected = <SelectorTextEntry>{
    SelectorTextEntry.id(id: 'comprehensive_sort')
  };

  SelectorEntries? fetchSortSelectedData() =>
      sortResult?.selected ?? sortIniteialSelected;

  SelectorEntries? fetchSortResetData() => sortIniteialSelected;

  Future<SelectorEntries> fetchSortData() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));
    final sort = sortFromJson(await loadJsonData('sort.json'));
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

List<PriceData> priceFromJson(String str) =>
    List<PriceData>.from(json.decode(str).map((x) => PriceData.fromJson(x)));

String priceToJson(List<PriceData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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

List<RoomData> roomsFromJson(String str) =>
    List<RoomData>.from(json.decode(str).map((x) => RoomData.fromJson(x)));

String roomsToJson(List<RoomData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RoomData {
  String? id;
  String? name;
  List<RoomItem>? data;

  RoomData({this.id, this.name, this.data});

  RoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['data'] != null) {
      data = <RoomItem>[];
      json['data'].forEach((v) {
        data!.add(RoomItem.fromJson(v));
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

class RoomItem {
  String? id;
  String? name;

  RoomItem({this.id, this.name});

  RoomItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

List<MoreData> moreFromJson(String str) =>
    List<MoreData>.from(json.decode(str).map((x) => MoreData.fromJson(x)));

String moreToJson(List<MoreData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MoreData {
  String? id;
  String? name;
  List<MoreItem>? data;

  MoreData({this.id, this.name, this.data});

  MoreData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['data'] != null) {
      data = <MoreItem>[];
      json['data'].forEach((v) {
        data!.add(MoreItem.fromJson(v));
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

class MoreItem {
  String? id;
  String? name;
  int? min;
  int? max;

  MoreItem({this.id, this.name, this.min, this.max});

  MoreItem.fromJson(Map<String, dynamic> json) {
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

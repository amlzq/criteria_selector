import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'utils.dart';

class HouseRepository {
  // A realtime data stream
  final StreamController<List<House>> _controller =
      StreamController.broadcast();

  HouseRepository() {
    // Load initial data
    _loadInitialData();
  }

  Stream<List<House>> get housesStream => _controller.stream;

  void _loadInitialData() async {
    final data = houseFromJson(await loadJsonData('house.json'));
    _controller.add(data);
  }

  Future<int> previewCount(HouseFilter filterParams) async {
    debugPrint('refreshData filterParams: ${filterParams.toJson()}');

    await Future.delayed(const Duration(milliseconds: 250));
    final houses = houseFromJson(await loadJsonData('house.json'));
    debugPrint('refreshData initial houses.length: ${houses.length}');

    // final apiPayload = filterParams.toJson();

    // Simulate filtering
    houses.shuffle();
    final random = Random().nextInt(houses.length + 1);
    final result = houses.sublist(0, random);

    debugPrint('refreshData filtered houses.length: ${result.length}');

    return result.length;
  }

  // Refresh
  void refreshData(HouseFilter filterParams) async {
    debugPrint('refreshData filterParams: ${filterParams.toJson()}');

    await Future.delayed(const Duration(milliseconds: 250));
    final houses = houseFromJson(await loadJsonData('house.json'));
    debugPrint('refreshData initial houses.length: ${houses.length}');

    // final apiPayload = filterParams.toJson();

    // Simulate filtering
    houses.shuffle();
    final random = Random().nextInt(houses.length + 1);
    final result = houses.sublist(0, random);

    debugPrint('refreshData filtered houses.length: ${result.length}');

    _controller.add(result);
  }

  void dispose() => _controller.close();
}

class HouseFilter {
  String? cityId;
  List<Map<String, dynamic>>? region;
  List<Map<String, dynamic>>? listPrice;
  List<Map<String, dynamic>>? monthlyPayment;
  List<String>? bedrooms;
  List<String>? bathrooms;
  List<String>? homeType;
  List<String>? listsDetails;
  List<String>? squareFeet;
  List<String>? lotSize;
  List<String>? homeFeatures;
  List<String>? commute;
  List<String>? expandedSearch;
  String? sort;

  HouseFilter({
    required this.cityId,
    this.region,
    this.listPrice,
    this.monthlyPayment,
    this.bedrooms,
    this.bathrooms,
    this.homeType,
    this.listsDetails,
    this.squareFeet,
    this.lotSize,
    this.homeFeatures,
    this.commute,
    this.expandedSearch,
    this.sort,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['city_id'] = cityId;
    data['region'] = region;
    data['list_price'] = listPrice;
    data['monthly_payment'] = monthlyPayment;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['home_type'] = homeType;
    data['lists_details'] = listsDetails;
    data['square_feet'] = squareFeet;
    data['lot_size'] = lotSize;
    data['home_features'] = homeFeatures;
    data['commute'] = commute;
    data['expanded_search'] = expandedSearch;
    data['sort'] = sort;
    return data;
  }
}

List<House> houseFromJson(String str) =>
    List<House>.from(json.decode(str).map((x) => House.fromJson(x)));

String houseToJson(List<House> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class House {
  String? id;
  String? picture;
  String? tag;
  String? title;
  String? second;
  String? price;
  String? unitPrice;
  String? address;
  String? city;
  String? cityId;
  String? district;
  String? districtId;
  String? lat;
  String? lon;
  String? area;
  String? type;
  String? builtYear;

  House(
      {this.id,
      this.picture,
      this.tag,
      this.title,
      this.second,
      this.price,
      this.unitPrice,
      this.address,
      this.city,
      this.cityId,
      this.district,
      this.districtId,
      this.lat,
      this.lon,
      this.area,
      this.type,
      this.builtYear});

  House.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    picture = json['picture'];
    tag = json['tag'];
    title = json['title'];
    second = json['second'];
    price = json['price'];
    unitPrice = json['unitPrice'];
    address = json['address'];
    city = json['city'];
    cityId = json['city_id'];
    district = json['district'];
    districtId = json['district_id'];
    lat = json['lat'];
    lon = json['lon'];
    area = json['area'];
    type = json['type'];
    builtYear = json['builtYear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['picture'] = picture;
    data['tag'] = tag;
    data['title'] = title;
    data['second'] = second;
    data['price'] = price;
    data['unitPrice'] = unitPrice;
    data['address'] = address;
    data['city'] = city;
    data['city_id'] = cityId;
    data['district'] = district;
    data['district_id'] = districtId;
    data['lat'] = lat;
    data['lon'] = lon;
    data['area'] = area;
    data['type'] = type;
    data['builtYear'] = builtYear;
    return data;
  }
}

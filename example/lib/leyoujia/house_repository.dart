import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'utils.dart';

class HouseRepository {
  // 一个实时数据流
  final StreamController<List<House>> _controller =
      StreamController.broadcast();

  HouseRepository() {
    // 定时更新数据
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

    // 模拟筛选
    houses.shuffle();
    final random = Random().nextInt(houses.length + 1);
    final result = houses.sublist(0, random);

    debugPrint('refreshData filtered houses.length: ${result.length}');

    return result.length;
  }

  // 更新
  void refreshData(HouseFilter filterParams) async {
    debugPrint('refreshData filterParams: ${filterParams.toJson()}');

    await Future.delayed(const Duration(milliseconds: 250));
    final houses = houseFromJson(await loadJsonData('house.json'));
    debugPrint('refreshData initial houses.length: ${houses.length}');

    // final apiPayload = filterParams.toJson();

    // 模拟筛选
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
  List<Map<String, dynamic>>? district;
  List<Map<String, dynamic>>? metro;
  (String, String)? userLatLon;
  String? nearbyRadiusMeters;
  List<Map<String, dynamic>>? totalPrice;
  List<Map<String, dynamic>>? unitPrice;
  List<Map<String, dynamic>>? rent;
  List<Map<String, dynamic>>? downPay;
  List<String>? livingRoom;
  List<String>? bathroom;
  List<String>? balcony;
  List<Map<String, dynamic>>? area;
  String? sort;

  HouseFilter({
    required this.cityId,
    this.district,
    this.metro,
    this.userLatLon,
    this.nearbyRadiusMeters,
    this.livingRoom,
    this.bathroom,
    this.balcony,
    this.area,
    this.sort,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['city_id'] = cityId;
    data['district'] = district;
    data['metro'] = metro;
    data['user_lat_lon'] = userLatLon;
    data['nearby_radius_meters'] = nearbyRadiusMeters;
    data['total_price'] = totalPrice;
    data['unit_price'] = unitPrice;
    data['rent_amount'] = rent;
    data['down_pay'] = downPay;
    data['living_room'] = livingRoom;
    data['bathroom'] = bathroom;
    data['balcony'] = balcony;
    data['area'] = area;
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
  String? title;
  String? second;
  String? price;
  String? unitPrice;
  String? address;
  String? city;
  String? cityId;
  String? district;
  String? districtId;
  String? subdistrict;
  String? subdistrictId;
  String? community;
  String? line;
  String? lineId;
  String? stationId;
  String? station;
  String? lat;
  String? lon;
  String? floor;
  String? area;
  String? type;
  String? orientation;
  String? decoration;
  String? builtYear;

  House(
      {this.id,
      this.picture,
      this.title,
      this.second,
      this.price,
      this.unitPrice,
      this.address,
      this.city,
      this.cityId,
      this.district,
      this.districtId,
      this.subdistrict,
      this.subdistrictId,
      this.community,
      this.line,
      this.lineId,
      this.stationId,
      this.station,
      this.lat,
      this.lon,
      this.floor,
      this.area,
      this.type,
      this.orientation,
      this.decoration,
      this.builtYear});

  House.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    picture = json['picture'];
    title = json['title'];
    second = json['second'];
    price = json['price'];
    unitPrice = json['unitPrice'];
    address = json['address'];
    city = json['city'];
    cityId = json['city_id'];
    district = json['district'];
    districtId = json['district_id'];
    subdistrict = json['subdistrict'];
    subdistrictId = json['subdistrict_id'];
    community = json['community'];
    line = json['line'];
    lineId = json['line_id'];
    stationId = json['station_id'];
    station = json['station'];
    lat = json['lat'];
    lon = json['lon'];
    floor = json['floor'];
    area = json['area'];
    type = json['type'];
    orientation = json['orientation'];
    decoration = json['decoration'];
    builtYear = json['builtYear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['picture'] = picture;
    data['title'] = title;
    data['second'] = second;
    data['price'] = price;
    data['unitPrice'] = unitPrice;
    data['address'] = address;
    data['city'] = city;
    data['city_id'] = cityId;
    data['district'] = district;
    data['district_id'] = districtId;
    data['subdistrict'] = subdistrict;
    data['subdistrict_id'] = subdistrictId;
    data['community'] = community;
    data['line'] = line;
    data['line_id'] = lineId;
    data['station_id'] = stationId;
    data['station'] = station;
    data['lat'] = lat;
    data['lon'] = lon;
    data['floor'] = floor;
    data['area'] = area;
    data['type'] = type;
    data['orientation'] = orientation;
    data['decoration'] = decoration;
    data['builtYear'] = builtYear;
    return data;
  }
}

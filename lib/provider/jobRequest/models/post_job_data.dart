import 'package:nb_utils/nb_utils.dart';

import '../../../models/service_model.dart';

class PostJobData {
  num? id;
  String? title;
  String? description;
  String? reason;
  String? price;
  num? jobPrice;
  num? providerId;
  num? customerId;
  String? status;
  String? customerName;
  String? createdAt;
  bool? canBid;
  List<ServiceData>? service;
  String? customerProfile;

  String? address;
  String? latitude;
  String? longitude;
  num? cityId;

  static String? _nonEmptyString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static num? _numFromJson(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  /// True when post has enough location data to bid (matches job detail UI / TC-07).
  bool get hasUsableLocationForBid {
    if (address.validate().trim().isNotEmpty) return true;
    if (latitude.validate().isNotEmpty && longitude.validate().isNotEmpty) {
      return true;
    }
    if (cityId != null && cityId! > 0) return true;
    final list = service;
    if (list == null || list.isEmpty) return false;
    return list.first.hasUsableServiceLocation;
  }

  /// Single line for list/detail: post-level fields first, then nested service mapping/address/city.
  String get displayJobLocationLabel {
    if (address.validate().trim().isNotEmpty) return address!.trim();
    if (latitude.validate().isNotEmpty && longitude.validate().isNotEmpty) {
      return '${latitude!.trim()}, ${longitude!.trim()}';
    }
    if (cityId != null && cityId! > 0) return 'City ID: $cityId';
    if (service.validate().isNotEmpty) {
      final label = service!.first.displayServiceLocationLabel;
      if (label.isNotEmpty) return label;
    }
    return '';
  }

  PostJobData({
    this.id,
    this.title,
    this.description,
    this.reason,
    this.price,
    this.providerId,
    this.customerId,
    this.status,
    this.canBid,
    this.service,
    this.jobPrice,
    this.createdAt,
    this.customerName,
    this.customerProfile,
    this.address,
    this.latitude,
    this.longitude,
    this.cityId,
  });

  PostJobData.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    reason = json['reason'];
    price = json['price'] != null ? json['price'].toString() : null;
    jobPrice = json['job_price'];
    providerId = json['provider_id'];
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    status = json['status'];
    customerProfile = json['customer_profile'];
    canBid = json['can_bid'];
    createdAt = json['created_at'];

    address = _nonEmptyString(json['address']) ??
        _nonEmptyString(json['job_address']) ??
        _nonEmptyString(json['location']) ??
        _nonEmptyString(json['service_address']);
    latitude =
        _nonEmptyString(json['latitude']) ?? _nonEmptyString(json['lat']);
    longitude = _nonEmptyString(json['longitude']) ??
        _nonEmptyString(json['lng']) ??
        _nonEmptyString(json['long']);
    cityId = _numFromJson(json['city_id']);

    void parseServiceList(dynamic raw) {
      if (raw is! List) return;
      service = [];
      for (final v in raw) {
        if (v is Map<String, dynamic>) {
          service!.add(ServiceData.fromJson(v));
        } else if (v is Map) {
          service!.add(ServiceData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    if (json['service'] != null) {
      parseServiceList(json['service']);
    } else if (json['services'] != null) {
      parseServiceList(json['services']);
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['reason'] = reason;
    map['price'] = price;
    map['job_price'] = jobPrice;
    map['provider_id'] = providerId;
    map['customer_id'] = customerId;
    map['status'] = status;
    map['customer_name'] = customerName;
    map['customer_profile'] = customerProfile;
    map['can_bid'] = canBid;
    map['created_at'] = createdAt;
    map['address'] = address;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['city_id'] = cityId;
    if (service != null) {
      map['service'] = service?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

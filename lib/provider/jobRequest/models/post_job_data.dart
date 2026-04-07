import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/utils/lat_lng_valid.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/service_model.dart';

export 'post_job_location.dart';

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

  /// Human-readable city when API sends [city_name] or after [enrichPostJobCityNameFromBidderProviders].
  String? cityName;
  List<ServiceAddressMapping>? serviceAddressMapping;

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

  static String? _coordFromJson(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toString();
    return _nonEmptyString(v);
  }

  /// Root [price] is often **not** money (customer app stores "estimated time" / preferred date here).
  static bool _looksLikeIsoDateString(String s) {
    final t = s.trim();
    return RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(t);
  }

  /// Amount for "Job price" UI and bid floor: [job_price] first; else numeric [price] only if not a date-like string.
  num? get displayJobBudgetAmount {
    if (jobPrice != null) return jobPrice;
    final p = price?.trim();
    if (p == null || p.isEmpty) return null;
    if (_looksLikeIsoDateString(p)) return null;
    return num.tryParse(p);
  }

  bool get hasJobPriceForDisplay => displayJobBudgetAmount != null;

  /// Text for "Estimated time" row: ISO dates, or free text like "after 2 pm" (not used as [displayJobBudgetAmount]).
  String? get customerEstimateOrScheduleNote {
    final p = price?.trim();
    if (p == null || p.isEmpty) return null;
    if (_looksLikeIsoDateString(p)) return p;
    if (num.tryParse(p) == null) return p;
    return null;
  }

  /// Single line for list/detail: post-level fields first, then nested service mapping/address/city.
  String get displayJobLocationLabel {
    if (address.validate().trim().isNotEmpty) return address!.trim();
    if (isUsableLatLngStrings(latitude, longitude)) {
      return '${latitude!.trim()}, ${longitude!.trim()}';
    }
    for (final m in serviceAddressMapping ?? <ServiceAddressMapping>[]) {
      final pam = m.providerAddressMapping;
      if (pam == null) continue;
      final a = pam.address?.trim();
      if (a.validate().isNotEmpty) return a!;
      if (isUsableLatLngStrings(pam.latitude, pam.longitude)) {
        return '${pam.latitude}, ${pam.longitude}';
      }
    }
    if (service.validate().isNotEmpty) {
      final label = service!.first.displayServiceLocationLabel;
      if (label.isNotEmpty) return label;
    }
    if (cityId != null && cityId! > 0) {
      if (cityName.validate().trim().isNotEmpty) return cityName!.trim();
      return '';
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
    this.cityName,
    this.serviceAddressMapping,
  });

  PostJobData.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    reason = json['reason'];
    price = json['price'] != null ? json['price'].toString() : null;
    jobPrice = _numFromJson(json['job_price']) ??
        _numFromJson(json['jobPrice']) ??
        _numFromJson(json['customer_budget']) ??
        _numFromJson(json['estimated_budget']);
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
    latitude = _coordFromJson(json['latitude']) ?? _coordFromJson(json['lat']);
    longitude = _coordFromJson(json['longitude']) ??
        _coordFromJson(json['lng']) ??
        _coordFromJson(json['long']);
    cityId = _numFromJson(json['city_id']) ?? _numFromJson(json['cityId']);
    cityName =
        _nonEmptyString(json['city_name']) ?? _nonEmptyString(json['cityName']);

    final mappingJson =
        json['service_address_mapping'] ?? json['serviceAddressMapping'];
    if (mappingJson is List) {
      serviceAddressMapping = [];
      for (final v in mappingJson) {
        if (v is Map<String, dynamic>) {
          serviceAddressMapping!.add(ServiceAddressMapping.fromJson(v));
        } else if (v is Map) {
          serviceAddressMapping!.add(
              ServiceAddressMapping.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

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
      final rawService = json['service'];
      if (rawService is List) {
        parseServiceList(rawService);
      } else if (rawService is Map<String, dynamic>) {
        service = [ServiceData.fromJson(rawService)];
      } else if (rawService is Map) {
        service = [
          ServiceData.fromJson(Map<String, dynamic>.from(rawService)),
        ];
      }
    } else if (json['services'] != null) {
      parseServiceList(json['services']);
    }

    if (json is Map<String, dynamic>) {
      _augmentLocationFields(this, json);
    } else if (json is Map) {
      _augmentLocationFields(this, Map<String, dynamic>.from(json));
    }
    _promoteLocationFromNestedService(this);
  }

  static void _promoteLocationFromNestedService(PostJobData p) {
    final list = p.service;
    if (list == null || list.isEmpty) return;
    final s = list.first;
    if (p.address.validate().trim().isEmpty &&
        s.address.validate().trim().isNotEmpty) {
      p.address = s.address;
    }
    if (!isUsableLatLngStrings(p.latitude, p.longitude) &&
        isUsableLatLngStrings(s.latitude, s.longitude)) {
      p.latitude = s.latitude;
      p.longitude = s.longitude;
    }
    if (p.cityId == null || p.cityId! <= 0) {
      if (s.cityId != null && s.cityId! > 0) {
        p.cityId = s.cityId;
      }
    }
    if (p.cityName.validate().trim().isEmpty &&
        s.cityName.validate().trim().isNotEmpty) {
      p.cityName = s.cityName!.trim();
    }
    if (p.serviceAddressMapping == null || p.serviceAddressMapping!.isEmpty) {
      final m = s.serviceAddressMapping;
      if (m != null && m.isNotEmpty) {
        p.serviceAddressMapping = List<ServiceAddressMapping>.from(m);
      }
    }
  }

  /// Extra keys / nested objects some backends use for post-job location.
  static void _augmentLocationFields(PostJobData p, Map<String, dynamic> json) {
    if (p.address.validate().trim().isEmpty) {
      p.address = _nonEmptyString(json['full_address']) ??
          _nonEmptyString(json['street_address']) ??
          _nonEmptyString(json['post_job_address']) ??
          _nonEmptyString(json['job_request_address']) ??
          _nonEmptyString(json['customer_address']) ??
          _nonEmptyString(json['formatted_address']);
    }
    if (!isUsableLatLngStrings(p.latitude, p.longitude)) {
      final lat = _coordFromJson(json['job_latitude']) ??
          _coordFromJson(json['geo_lat']);
      final lng = _coordFromJson(json['job_longitude']) ??
          _coordFromJson(json['geo_lng']);
      if (isUsableLatLngStrings(lat, lng)) {
        p.latitude = lat;
        p.longitude = lng;
      }
    }
    if (p.cityId == null || p.cityId! <= 0) {
      p.cityId = _numFromJson(json['customer_city_id']) ??
          _numFromJson(json['job_city_id']);
    }
    if (p.cityName.validate().trim().isEmpty) {
      p.cityName = _nonEmptyString(json['city_name']) ??
          _nonEmptyString(json['job_city_name']);
    }

    if (p.serviceAddressMapping == null || p.serviceAddressMapping!.isEmpty) {
      final alt = json['provider_address_mapping'] ??
          json['address_mapping'] ??
          json['post_service_address_mapping'];
      if (alt is List && alt.isNotEmpty) {
        p.serviceAddressMapping = [];
        for (final v in alt) {
          if (v is Map<String, dynamic>) {
            p.serviceAddressMapping!.add(ServiceAddressMapping.fromJson(v));
          } else if (v is Map) {
            p.serviceAddressMapping!.add(
                ServiceAddressMapping.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
    }

    for (final key in <String>[
      'location',
      'job_location',
      'post_location',
      'customer_location',
      'coordinates',
      'geo',
    ]) {
      final nested = json[key];
      if (nested is! Map) continue;
      final m = Map<String, dynamic>.from(nested);
      if (p.address.validate().trim().isEmpty) {
        p.address = _nonEmptyString(m['address']) ??
            _nonEmptyString(m['formatted_address']) ??
            _nonEmptyString(m['full_address']) ??
            p.address;
      }
      if (!isUsableLatLngStrings(p.latitude, p.longitude)) {
        final lat = _coordFromJson(m['latitude']) ?? _coordFromJson(m['lat']);
        final lng = _coordFromJson(m['longitude']) ??
            _coordFromJson(m['lng']) ??
            _coordFromJson(m['long']);
        if (isUsableLatLngStrings(lat, lng)) {
          p.latitude = lat;
          p.longitude = lng;
        }
      }
      if (p.cityId == null || p.cityId! <= 0) {
        final c = _numFromJson(m['city_id']) ?? _numFromJson(m['cityId']);
        if (c != null && c > 0) p.cityId = c;
      }
      if (p.cityName.validate().trim().isEmpty) {
        final cn =
            _nonEmptyString(m['city_name']) ?? _nonEmptyString(m['cityName']);
        if (cn != null) p.cityName = cn;
      }
    }
  }

  /// When [get-post-job-detail] omits location but the list row ([get-post-job]) still has it.
  static PostJobData withLocationFallbackFromList(
    PostJobData detail,
    PostJobData listRow,
  ) {
    final addr = detail.address.validate().trim().isNotEmpty
        ? detail.address
        : listRow.address.validate().trim().isNotEmpty
            ? listRow.address
            : null;

    String? lat;
    String? lng;
    if (isUsableLatLngStrings(detail.latitude, detail.longitude)) {
      lat = detail.latitude;
      lng = detail.longitude;
    } else if (isUsableLatLngStrings(listRow.latitude, listRow.longitude)) {
      lat = listRow.latitude;
      lng = listRow.longitude;
    } else {
      lat = detail.latitude ?? listRow.latitude;
      lng = detail.longitude ?? listRow.longitude;
    }

    final city = (detail.cityId != null && detail.cityId! > 0)
        ? detail.cityId
        : (listRow.cityId != null && listRow.cityId! > 0)
            ? listRow.cityId
            : null;

    final mapping = (detail.serviceAddressMapping != null &&
            detail.serviceAddressMapping!.isNotEmpty)
        ? detail.serviceAddressMapping
        : (listRow.serviceAddressMapping != null &&
                listRow.serviceAddressMapping!.isNotEmpty)
            ? listRow.serviceAddressMapping
            : null;

    final cityNm = detail.cityName.validate().trim().isNotEmpty
        ? detail.cityName
        : listRow.cityName.validate().trim().isNotEmpty
            ? listRow.cityName
            : null;

    return PostJobData(
      id: detail.id,
      title: detail.title,
      description: detail.description,
      reason: detail.reason,
      price: detail.price,
      jobPrice: detail.jobPrice,
      providerId: detail.providerId,
      customerId: detail.customerId,
      status: detail.status,
      canBid: detail.canBid,
      service: detail.service,
      createdAt: detail.createdAt,
      customerName: detail.customerName,
      customerProfile: detail.customerProfile,
      address: addr,
      latitude: lat,
      longitude: lng,
      cityId: city,
      cityName: cityNm,
      serviceAddressMapping: mapping,
    );
  }

  /// Overlay location fields (e.g. address copied from a matching [user_post_job] booking).
  PostJobData copyWithLocationOverlay({
    String? address,
    String? latitude,
    String? longitude,
    num? cityId,
    String? cityName,
  }) {
    return PostJobData(
      id: id,
      title: title,
      description: description,
      reason: reason,
      price: price,
      jobPrice: jobPrice,
      providerId: providerId,
      customerId: customerId,
      status: status,
      canBid: canBid,
      service: service,
      createdAt: createdAt,
      customerName: customerName,
      customerProfile: customerProfile,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      serviceAddressMapping: serviceAddressMapping,
    );
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
    map['city_name'] = cityName;
    if (serviceAddressMapping != null) {
      map['service_address_mapping'] =
          serviceAddressMapping!.map((v) => v.toJson()).toList();
    }
    if (service != null) {
      map['service'] = service?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

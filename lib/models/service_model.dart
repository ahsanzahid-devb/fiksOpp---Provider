import 'dart:convert';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/package_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/lat_lng_valid.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/model_keys.dart';
import 'multi_language_request_model.dart';

class ServiceData {
  int? id;
  String? name;
  int? categoryId;
  int? subCategoryId;
  int? providerId;
  num? price;
  var priceFormat;
  String? type;
  num? discount;
  String? duration;
  int? status;
  String? description;
  int? isFeatured;
  String? providerName;
  String? providerImage;
  int? cityId;
  /// Display name when API sends [city_name] (avoid showing raw [cityId] in UI).
  String? cityName;
  String? categoryName;
  List<String>? imageAttachments;
  List<Attachments>? attchments;
  num? totalReview;
  num? totalRating;
  int? isFavourite;
  List<ServiceAddressMapping>? serviceAddressMapping;
  Map<String, MultiLanguageRequest>? translations;
  String? rejectReason;
  String? serviceRequestStatus;

  //Set Values
  num? totalAmount;
  num? discountPrice;
  num? taxAmount;
  num? couponDiscountAmount;
  String? dateTimeVal;
  String? couponId;
  num? qty;
  String? address;
  int? bookingAddressId;
  CouponData? appliedCouponData;
  num? isSlot;
  String? visitType;
  List<SlotData>? providerSlotData;
  List<PackageData>? servicePackage;
  num? advancePaymentSetting;
  num? isEnableAdvancePayment;
  num? advancePaymentAmount;
  num? advancePaymentPercentage;
  String? reason;
  String? latitude;
  String? longitude;

  //Local
  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  bool get isFixedService => type.validate() == SERVICE_TYPE_FIXED;

  bool get isFreeService => price.validate() == 0;

  bool get isAdvancePayment => isEnableAdvancePayment.validate() == 1;

  bool get isAdvancePaymentSetting => advancePaymentSetting.validate() == 1;

  String? subCategoryName;

  bool? isSelected;

  bool get isOnlineService => visitType == VISIT_OPTION_ONLINE;

  bool get isOnSiteService => visitType == VISIT_OPTION_ON_SITE;
  List<Zones>? zones;

  /// True when the service has a usable location for post-job bidding (API may nest it under [serviceAddressMapping]).
  bool get hasUsableServiceLocation {
    if (isUsableLatLngStrings(latitude, longitude)) return true;
    if (address.validate().trim().isNotEmpty) return true;
    if (cityId != null && cityId! > 0) return true;
    final m = serviceAddressMapping;
    if (m != null && m.isNotEmpty) return true;
    for (final x in m ?? <ServiceAddressMapping>[]) {
      final pam = x.providerAddressMapping;
      if (pam == null) continue;
      if (pam.address.validate().trim().isNotEmpty) return true;
      if (isUsableLatLngStrings(pam.latitude, pam.longitude)) return true;
    }
    return false;
  }

  /// Human-readable location for job detail UI (address, coordinates fallback, or city id).
  String get displayServiceLocationLabel {
    final top = address?.trim();
    if (top.validate().isNotEmpty) return top!;
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
    if (cityId != null && cityId! > 0) {
      if (cityName.validate().trim().isNotEmpty) return cityName!.trim();
      return '';
    }
    return '';
  }

  /// One-line audit for debug logs when bidding is blocked.
  String get bidLocationAuditLine {
    final addrOk = address.validate().trim().isNotEmpty;
    final n = serviceAddressMapping?.length ?? 0;
    final latLng = isUsableLatLngStrings(latitude, longitude);
    return 'service.id=$id address_nonEmpty=$addrOk cityId=$cityId latLng_ok=$latLng '
        'service_address_mapping_count=$n hasUsableServiceLocation=$hasUsableServiceLocation';
  }

  ServiceData({
    this.id,
    this.name,
    this.imageAttachments,
    this.providerSlotData,
    this.categoryId,
    this.providerId,
    this.price,
    this.priceFormat,
    this.type,
    this.discount,
    this.duration,
    this.status,
    this.isSlot,
    this.visitType,
    this.description,
    this.isFeatured,
    this.providerName,
    this.subCategoryId,
    this.providerImage,
    this.cityId,
    this.cityName,
    this.categoryName,
    this.attchments,
    this.totalReview,
    this.totalRating,
    this.isFavourite,
    this.serviceAddressMapping,
    this.rejectReason,
    this.serviceRequestStatus,
    this.totalAmount,
    this.discountPrice,
    this.taxAmount,
    this.couponDiscountAmount,
    this.dateTimeVal,
    this.couponId,
    this.subCategoryName,
    this.qty,
    this.address,
    this.bookingAddressId,
    this.appliedCouponData,
    this.isSelected,
    this.servicePackage,
    this.advancePaymentSetting,
    this.isEnableAdvancePayment,
    this.advancePaymentAmount,
    this.advancePaymentPercentage,
    this.translations,
    this.reason,
    this.zones,
    this.latitude,
    this.longitude,
  });

  static String? _coordString(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toString();
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  ServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    providerImage = json['provider_image'];
    categoryId = json['category_id'];
    subCategoryId = json['subcategory_id'];
    providerId = json['provider_id'];
    price = json['price'];
    priceFormat = json['price_format'];
    type = json['type'];
    discount = json['discount'];
    duration = json['duration'];
    status = json['status'];
    isSlot = json['is_slot'];
    visitType = json['visit_type'];
    description = json['description'];
    isFeatured = json['is_featured'];
    providerName = json['provider_name'];
    cityId = json['city_id'];
    cityName = json['city_name'] != null
        ? json['city_name'].toString().trim().isEmpty
            ? null
            : json['city_name'].toString().trim()
        : null;
    final addrRaw = json['address'] != null
        ? json['address'].toString()
        : (json['service_address'] != null
            ? json['service_address'].toString()
            : null);
    address =
        addrRaw != null && addrRaw.trim().isNotEmpty ? addrRaw.trim() : null;
    latitude = _coordString(json['latitude']) ?? _coordString(json['lat']);
    longitude = _coordString(json['longitude']) ??
        _coordString(json['lng']) ??
        _coordString(json['long']);
    categoryName = json['category_name'];
    imageAttachments = json['attchments'] != null
        ? List<String>.from(json['attchments'])
        : null;
    attchments = json['attchments_array'] != null
        ? (json['attchments_array'] as List)
            .map((i) => Attachments.fromJson(i))
            .toList()
        : null;
    providerSlotData = json['slots'] != null
        ? (json['slots'] as List).map((i) => SlotData.fromJson(i)).toList()
        : null;
    subCategoryName = json['subcategory_name'];
    translations = json['translations'] != null
        ? (jsonDecode(json['translations']) as Map<String, dynamic>).map(
            (key, value) {
              if (value is Map<String, dynamic>) {
                return MapEntry(key, MultiLanguageRequest.fromJson(value));
              } else {
                print('Unexpected translation value for key $key: $value');
                return MapEntry(key, MultiLanguageRequest());
              }
            },
          )
        : null;
    totalReview = json['total_review'];
    totalRating = json['total_rating'];
    isFavourite = json['is_favourite'];
    reason = json['reason'];
    rejectReason = json['reject_reason'] is String ? json['reject_reason'] : '';
    serviceRequestStatus = json['service_request_status'] is String
        ? json['service_request_status']
        : '';

    final mappingJson =
        json['service_address_mapping'] ?? json['serviceAddressMapping'];
    if (mappingJson != null) {
      serviceAddressMapping = [];
      (mappingJson as List).forEach((v) {
        serviceAddressMapping!.add(ServiceAddressMapping.fromJson(
            Map<String, dynamic>.from(v as Map)));
      });
    }
    servicePackage = json['servicePackage'] != null
        ? (json['servicePackage'] as List)
            .map((i) => PackageData.fromJson(i))
            .toList()
        : null;
    advancePaymentSetting = json[AdvancePaymentKey.advancePaymentSetting];
    isEnableAdvancePayment = json[AdvancePaymentKey.isEnableAdvancePayment];
    advancePaymentAmount = json[AdvancePaymentKey.advancePaymentAmount];
    advancePaymentPercentage = json[AdvancePaymentKey.advancePaymentAmount];
    zones = json['zones'] != null
        ? (json['zones'] as List).map((i) => Zones.fromJson(i)).toList()
        : null;

    _augmentServiceLocationFromJson(this, json);
  }

  /// Nested / alternate keys for service location (post-job service[] payloads).
  static void _augmentServiceLocationFromJson(
      ServiceData s, Map<String, dynamic> json) {
    if (s.address.validate().trim().isEmpty) {
      for (final k in [
        'full_address',
        'street_address',
        'job_address',
        'service_address_line',
        'formatted_address',
      ]) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          s.address = v.toString().trim();
          break;
        }
      }
    }
    if (!isUsableLatLngStrings(s.latitude, s.longitude)) {
      final lat =
          _coordString(json['job_latitude']) ?? _coordString(json['geo_lat']);
      final lng =
          _coordString(json['job_longitude']) ?? _coordString(json['geo_lng']);
      if (isUsableLatLngStrings(lat, lng)) {
        s.latitude = lat;
        s.longitude = lng;
      }
    }
    if (s.cityName.validate().trim().isEmpty) {
      for (final k in ['city_name', 'cityName', 'job_city_name']) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          s.cityName = v.toString().trim();
          break;
        }
      }
    }
    for (final key in ['location', 'job_location', 'service_location']) {
      final nested = json[key];
      if (nested is! Map) continue;
      final m = Map<String, dynamic>.from(nested);
      if (s.address.validate().trim().isEmpty) {
        for (final k in ['address', 'formatted_address', 'full_address']) {
          final v = m[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            s.address = v.toString().trim();
            break;
          }
        }
      }
      if (!isUsableLatLngStrings(s.latitude, s.longitude)) {
        final lat = _coordString(m['latitude']) ?? _coordString(m['lat']);
        final lng = _coordString(m['longitude']) ??
            _coordString(m['lng']) ??
            _coordString(m['long']);
        if (isUsableLatLngStrings(lat, lng)) {
          s.latitude = lat;
          s.longitude = lng;
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['provider_image'] = this.providerImage;
    data['category_id'] = this.categoryId;
    data['provider_id'] = this.providerId;
    data['is_slot'] = this.isSlot;
    data['visit_type'] = this.visitType;
    data['price'] = this.price;
    data['price_format'] = this.priceFormat;
    data['type'] = this.type;
    data['discount'] = this.discount;
    data['duration'] = this.duration;
    data['status'] = this.status;
    data['description'] = this.description;
    data['is_featured'] = this.isFeatured;
    data['provider_name'] = this.providerName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['subcategory_id'] = this.subCategoryId;
    data['subcategory_name'] = this.subCategoryName;
    data['category_name'] = this.categoryName;
    data['reason'] = this.reason;
    data['reject_reason'] = this.rejectReason;
    data['service_request_status'] = this.serviceRequestStatus;
    if (this.imageAttachments != null) {
      data['attchments'] = this.imageAttachments;
    }
    if (this.providerSlotData != null) {
      data['slots'] = this.providerSlotData;
    }
    if (this.servicePackage != null) {
      data['servicePackage'] =
          this.servicePackage!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] =
          translations!.map((key, value) => MapEntry(key, value.toJson()));
    }
    data['total_review'] = this.totalReview;
    data['total_rating'] = this.totalRating;
    data['is_favourite'] = this.isFavourite;
    if (this.serviceAddressMapping != null) {
      data['service_address_mapping'] =
          this.serviceAddressMapping!.map((v) => v.toJson()).toList();
    }
    if (this.attchments != null) {
      data['attchments_array'] =
          this.attchments!.map((v) => v.toJson()).toList();
    }

    data[AdvancePaymentKey.advancePaymentSetting] = this.advancePaymentSetting;
    data[AdvancePaymentKey.isEnableAdvancePayment] =
        this.isEnableAdvancePayment;
    data[AdvancePaymentKey.advancePaymentAmount] = this.advancePaymentAmount;
    data[AdvancePaymentKey.advancePaymentAmount] =
        this.advancePaymentPercentage;
    data['zones'] =
        this.zones != null ? this.zones!.map((v) => v.toJson()).toList() : null;
    return data;
  }
}

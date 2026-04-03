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

  /// True when post has enough location data to bid (matches job detail UI / TC-07).
  bool get hasUsableLocationForBid {
    final list = service;
    if (list == null || list.isEmpty) return false;
    final s = list.first;
    final addr = s.address?.trim() ?? '';
    if (addr.isNotEmpty) return true;
    final cid = s.cityId;
    if (cid != null && cid > 0) return true;
    return false;
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
  });

  PostJobData.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    reason = json['reason'];
    price = json['price'].toString();
    jobPrice = json['job_price'];
    providerId = json['provider_id'];
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    status = json['status'];
    customerProfile = json['customer_profile'];
    canBid = json['can_bid'];
    createdAt = json['created_at'];
    if (json['service'] != null) {
      service = [];
      json['service'].forEach((v) {
        service?.add(ServiceData.fromJson(v));
      });
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
    if (service != null) {
      map['service'] = service?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

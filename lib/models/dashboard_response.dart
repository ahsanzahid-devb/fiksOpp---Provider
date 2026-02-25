import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:nb_utils/nb_utils.dart';

import '../provider/jobRequest/models/post_job_data.dart';
import '../utils/constant.dart';
import 'provider_subscription_model.dart';
import 'revenue_chart_data.dart';

class DashboardResponse {
  bool? status;
  int? totalBooking;
  int? totalService;
  num? todayCashAmount;
  num? totalCashInHand;
  int? totalActiveHandyman;
  List<ServiceData>? service;
  List<UserData>? handyman;
  num? totalRevenue;
  Commission? commission;
  int? isSubscribed;
  int? isEmailVerified;
  ProviderSubscriptionModel? subscription;
  ProviderWallet? providerWallet;
  List<String>? onlineHandyman;
  List<PostJobData>? myPostJobData;
  List<BookingData>? upcomingBookings;
  num? notificationUnreadCount;
  num? remainingPayout;

  //Local
  bool get isPlanAboutToExpire => isSubscribed == 1;

  bool get userNeverPurchasedPlan => isSubscribed == 0 && subscription == null;

  bool get isPlanExpired => isSubscribed == 0 && subscription != null;

  DashboardResponse({
    this.status,
    this.totalBooking,
    this.service,
    this.totalService,
    this.totalActiveHandyman,
    this.totalCashInHand,
    this.handyman,
    this.totalRevenue,
    this.commission,
    this.providerWallet,
    this.onlineHandyman,
    this.myPostJobData,
    this.upcomingBookings,
    this.notificationUnreadCount,
    this.todayCashAmount,
    this.isEmailVerified = 0,
    this.remainingPayout,
  });

  static int _int(dynamic v, [int defaultValue = 0]) {
    if (v == null) return defaultValue;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    isEmailVerified = _int(json['is_email_verified']);
    status = json['status'] == true || json['status'] == 1;
    totalBooking = _int(json['total_booking']);
    totalRevenue = num.tryParse(json['total_revenue']?.toString() ?? '') ?? 0;
    totalService = _int(json['total_service']);
    totalActiveHandyman = _int(json['total_active_handyman']);
    todayCashAmount = num.tryParse(json['today_cash']?.toString() ?? '') ?? 0;
    totalCashInHand = num.tryParse(json['total_cash_in_hand']?.toString() ?? '') ?? 0;
    notificationUnreadCount = num.tryParse(json['notification_unread_count']?.toString() ?? '') ?? 0;
    remainingPayout = num.tryParse(json['remaining_payout']?.toString() ?? '') ?? 0;
    commission = json['commission'] != null
        ? Commission.fromJson(json['commission'])
        : null;

    service = <ServiceData>[];
    if (json['service'] != null && json['service'] is List) {
      for (var v in json['service']) {
        service!.add(ServiceData.fromJson(v as Map<String, dynamic>));
      }
    }
    handyman = <UserData>[];
    if (json['handyman'] != null && json['handyman'] is List) {
      for (var v in json['handyman']) {
        handyman!.add(UserData.fromJson(v as Map<String, dynamic>));
      }
    }

    chartData = [];
    final monthlyRevenue = json['monthly_revenue'];
    if (monthlyRevenue != null &&
        monthlyRevenue is Map &&
        monthlyRevenue['revenueData'] != null &&
        monthlyRevenue['revenueData'] is List) {
      final it = monthlyRevenue['revenueData'] as List;
      it.forEachIndexed((element, index) {
        if (index < months.length) {
          if (element is Map && element.containsKey('${index + 1}')) {
            final key = (index + 1).toString();
            final val = element[key]?.toString() ?? '0';
            chartData.add(RevenueChartData(
                month: months[index],
                revenue: (double.tryParse(val) ?? 0)));
          } else {
            chartData.add(RevenueChartData(month: months[index], revenue: 0));
          }
        }
      });
    }
    if (chartData.length < months.length) {
      for (var i = chartData.length; i < months.length; i++) {
        chartData.add(RevenueChartData(month: months[i], revenue: 0));
      }
    }

    providerWallet = json['provider_wallet'] != null
        ? ProviderWallet.fromJson(json['provider_wallet'])
        : null;

    onlineHandyman = [];
    if (json['online_handyman'] != null && json['online_handyman'] is List) {
      onlineHandyman = (json['online_handyman'] as List).map((e) => e.toString()).toList();
    }
    myPostJobData = <PostJobData>[];
    if (json['post_requests'] != null && json['post_requests'] is List) {
      myPostJobData = (json['post_requests'] as List)
          .map((i) => PostJobData.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    upcomingBookings = <BookingData>[];
    if (json['upcomming_booking'] != null && json['upcomming_booking'] is List) {
      upcomingBookings = (json['upcomming_booking'] as List)
          .map((i) => BookingData.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    isSubscribed = _int(json['is_subscribed']);
    subscription = json['subscription'] != null
        ? ProviderSubscriptionModel.fromJson(json['subscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['total_booking'] = this.totalBooking;
    data['total_service'] = this.totalService;
    data['today_cash'] = this.todayCashAmount;
    data['total_cash_in_hand'] = this.totalCashInHand;
    data['is_email_verified'] = this.isEmailVerified;
    if (this.commission != null) {
      data['commission'] = this.commission!.toJson();
    }
    data['total_active_handyman'] = this.totalActiveHandyman;
    if (this.service != null) {
      data['service'] = this.service!.map((v) => v.toJson()).toList();
    }
    if (this.handyman != null) {
      data['handyman'] = this.handyman!.map((v) => v.toJson()).toList();
    }
    data['total_revenue'] = this.totalRevenue;
    data['online_handyman'] = this.onlineHandyman;
    if (this.providerWallet != null) {
      data['provider_wallet'] = this.providerWallet!.toJson();
    }

    if (this.myPostJobData != null) {
      data['post_requests'] =
          this.myPostJobData!.map((v) => v.toJson()).toList();
    }

    if (this.upcomingBookings != null) {
      data['upcomming_booking'] =
          this.upcomingBookings!.map((v) => v.toJson()).toList();
    }
    data['notification_unread_count'] = this.notificationUnreadCount;
    data['remaining_payout'] = this.remainingPayout;

    return data;
  }
}

class CategoryData {
  int? id;
  String? name;
  int? status;
  String? description;
  int? isFeatured;
  String? color;
  String? categoryImage;

  CategoryData(
      {this.id,
      this.name,
      this.status,
      this.description,
      this.isFeatured,
      this.color,
      this.categoryImage});

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    description = json['description'];
    isFeatured = json['is_featured'];
    color = json['color'];
    categoryImage = json['category_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['description'] = this.description;
    data['is_featured'] = this.isFeatured;
    data['color'] = this.color;
    data['category_image'] = this.categoryImage;
    return data;
  }
}

class Commission {
  num? commission;
  String? createdAt;
  String? deletedAt;
  int? id;
  String? name;
  int? status;
  String? type;
  String? updatedAt;

  Commission(
      {this.commission,
      this.createdAt,
      this.deletedAt,
      this.id,
      this.name,
      this.status,
      this.type,
      this.updatedAt});

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      commission: json['commission'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      type: json['type'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['commission'] = this.commission;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['type'] = this.type;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class ProviderWallet {
  int? id;
  String? title;
  int? userId;
  num? amount;
  int? status;
  String? createdAt;
  String? updatedAt;

  ProviderWallet(this.id, this.title, this.userId, this.amount, this.status,
      this.createdAt, this.updatedAt);

  ProviderWallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    userId = json['user_id'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ServiceAddressMapping {
  int? id;
  int? serviceId;
  int? providerAddressId;
  String? createdAt;
  String? updatedAt;
  ProviderAddressMapping? providerAddressMapping;

  ServiceAddressMapping(
      {this.id,
      this.serviceId,
      this.providerAddressId,
      this.createdAt,
      this.updatedAt,
      this.providerAddressMapping});

  ServiceAddressMapping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    providerAddressId = json['provider_address_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    providerAddressMapping = json['provider_address_mapping'] != null
        ? new ProviderAddressMapping.fromJson(json['provider_address_mapping'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['service_id'] = this.serviceId;
    data['provider_address_id'] = this.providerAddressId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.providerAddressMapping != null) {
      data['provider_address_mapping'] = this.providerAddressMapping!.toJson();
    }
    return data;
  }
}

class ProviderAddressMapping {
  int? id;
  int? providerId;
  String? address;
  String? latitude;
  String? longitude;
  int? status;
  String? createdAt;
  String? updatedAt;

  ProviderAddressMapping(
      {this.id,
      this.providerId,
      this.address,
      this.latitude,
      this.longitude,
      this.status,
      this.createdAt,
      this.updatedAt});

  ProviderAddressMapping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['provider_id'] = this.providerId;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class MonthlyRevenue {
  List<RevenueData>? revenueData;

  MonthlyRevenue({this.revenueData});

  MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    if (json['revenueData'] != null) {
      revenueData = [];
      json['revenueData'].forEach((v) {
        revenueData!.add(new RevenueData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.revenueData != null) {
      data['revenueData'] = this.revenueData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RevenueData {
  var i;

  RevenueData({this.i});

  RevenueData.fromJson(Map<String, dynamic> json) {
    for (int i = 1; i <= 12; i++) {
      i = json['$i'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    for (int i = 1; i <= 12; i++) {
      data['$i'] = this.i;
    }
    return data;
  }
}

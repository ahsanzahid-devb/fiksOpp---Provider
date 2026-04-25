class NotificationListResponse {
  List<NotificationData>? notificationData;
  int? allUnreadCount;

  NotificationListResponse({this.notificationData, this.allUnreadCount});

  NotificationListResponse.fromJson(Map<String, dynamic> json) {
    if (json['notification_data'] is List) {
      notificationData = [];
      for (final v in json['notification_data']) {
        if (v is Map<String, dynamic>) {
          notificationData!.add(NotificationData.fromJson(v));
        } else if (v is Map) {
          notificationData!
              .add(NotificationData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
    allUnreadCount = _asInt(json['all_unread_count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notificationData != null) {
      data['notification_data'] =
          this.notificationData!.map((v) => v.toJson()).toList();
    }
    data['all_unread_count'] = this.allUnreadCount;
    return data;
  }
}

class NotificationData {
  String? id;
  String? readAt;
  String? createdAt;
  String? profileImage;
  Data? data;

  NotificationData({this.id, this.readAt, this.createdAt, this.data});

  static String? _asString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = _asString(json['id']);
    readAt = _asString(json['read_at']);
    createdAt = _asString(json['created_at']);
    profileImage = _asString(json['profile_image']);
    if (json['data'] is Map<String, dynamic>) {
      data = Data.fromJson(json['data']);
    } else if (json['data'] is Map) {
      data = Data.fromJson(Map<String, dynamic>.from(json['data']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['read_at'] = this.readAt;
    data['created_at'] = this.createdAt;
    data['profile_image'] = this.profileImage;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  var id;
  String? type;
  String? activityType;
  String? subject;
  String? message;
  String? notificationType;
  String? checkBookingType;
  int? bookingId;
  int? serviceId;
  int? postRequestId;

  Data(
      {this.id,
      this.type,
      this.activityType,
      this.checkBookingType,
      this.subject,
      this.message,
      this.notificationType,
      this.bookingId,
      this.serviceId,
      this.postRequestId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type']?.toString();
    activityType = json['activity_type']?.toString();
    subject = json['subject']?.toString();
    message = json['message']?.toString();
    notificationType = json['notification-type']?.toString();
    checkBookingType = json['check_booking_type']?.toString();
    bookingId = _asInt(json['booking_id']);
    serviceId = _asInt(json['service_id']);
    postRequestId =
        _asInt(json['post_request_id']) ?? _asInt(json['post_job_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['activity_type'] = this.activityType;
    data['subject'] = this.subject;
    data['message'] = this.message;
    data['notification-type'] = this.notificationType;
    data['check_booking_type'] = this.checkBookingType;
    data['booking_id'] = this.bookingId;
    data['service_id'] = this.serviceId;
    data['post_request_id'] = this.postRequestId;
    return data;
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

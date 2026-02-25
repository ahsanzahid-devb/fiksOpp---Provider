import 'package:handyman_provider_flutter/models/pagination_model.dart';
import 'package:handyman_provider_flutter/screens/cash_management/cash_constant.dart';

class PaymentHistoryModel {
  Pagination? pagination;
  List<PaymentHistoryData>? data;

  PaymentHistoryModel({
    this.pagination,
    this.data,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) => PaymentHistoryModel(
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
        data: json["data"] == null ? [] : List<PaymentHistoryData>.from(json["data"]!.map((x) => PaymentHistoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination?.toJson(),
        "data": data == null ? [] : List<PaymentHistoryData>.from(data!.map((x) => x.toJson())),
      };
}

class PaymentHistoryData {
  num? id;
  num? paymentId;
  num? bookingId;
  String? action;
  String? text;
  String? type;
  String? status;
  num? senderId;
  num? receiverId;
  num? parentId;
  String? txnId;
  String? otherTransactionDetail;
  DateTime? datetime;
  num? totalAmount;

  //local
  bool get isTypeBank => type == BANK;

  PaymentHistoryData({
    this.id,
    this.paymentId,
    this.bookingId,
    this.action,
    this.text,
    this.type,
    this.status,
    this.senderId,
    this.parentId,
    this.receiverId,
    this.txnId,
    this.otherTransactionDetail,
    this.datetime,
    this.totalAmount,
  });

  static num? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  factory PaymentHistoryData.fromJson(Map<String, dynamic> json) => PaymentHistoryData(
        id: _num(json["id"]),
        paymentId: _num(json["payment_id"]),
        bookingId: _num(json["booking_id"]),
        action: _str(json["action"]),
        text: _str(json["text"]),
        type: _str(json["type"]),
        status: _str(json["status"]),
        parentId: _num(json["parent_id"]),
        senderId: _num(json["sender_id"]),
        receiverId: _num(json["receiver_id"]),
        txnId: _str(json["txn_id"]),
        otherTransactionDetail: json["other_transaction_detail"] == null ? null : _str(json["other_transaction_detail"]),
        datetime: json["datetime"] == null ? null : DateTime.tryParse(json["datetime"].toString()),
        totalAmount: _num(json["total_amount"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "payment_id": paymentId,
        "booking_id": bookingId,
        "action": action,
        "text": text,
        "txn_id": txnId,
        "parent_id": parentId,
        "other_transaction_detail": otherTransactionDetail,
        "type": type,
        "status": status,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "datetime": datetime?.toIso8601String(),
        "total_amount": totalAmount,
      };
}

import 'package:handyman_provider_flutter/screens/cash_management/model/payment_history_model.dart';

class CashHistoryModel {
  num? totalCashInHand;
  num? todayCash;
  List<PaymentHistoryData>? data;

  CashHistoryModel({
    this.totalCashInHand,
    this.todayCash,
    this.data,
  });

  factory CashHistoryModel.fromJson(Map<String, dynamic> json) => CashHistoryModel(
        totalCashInHand: num.tryParse(json["total_cash_in_hand"]?.toString() ?? '') ?? 0,
        todayCash: num.tryParse(json["today_cash"]?.toString() ?? '') ?? 0,
        data: json["cash_detail"] == null ? [] : List<PaymentHistoryData>.from(json["cash_detail"]!.map((x) => PaymentHistoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    return {
      "total_cash_in_hand": totalCashInHand,
      "today_cash": todayCash,
      "cash_detail": data == null ? [] : List<PaymentHistoryData>.from(data!.map((x) => x.toJson())),
    };
  }
}

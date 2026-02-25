import 'package:handyman_provider_flutter/models/pagination_model.dart';

class UserBankDetails {
  Pagination? pagination;
  List<BankData>? bankData;

  UserBankDetails({this.pagination, this.bankData});

  UserBankDetails.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null && json['pagination'] is Map
        ? Pagination.fromJson(Map<String, dynamic>.from(json['pagination']))
        : null;
    bankData = <BankData>[];
    if (json['data'] != null && json['data'] is List) {
      for (var v in json['data']) {
        bankData!.add(BankData.fromJson(Map<String, dynamic>.from(v as Map)));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.bankData != null) {
      data['data'] = this.bankData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BankData {
  int? id;
  int? providerId;
  String? bankName;
  String? branchName;
  String? accountNo;
  String? ifscNo;
  String? mobileNo;
  String? aadharNo;
  String? panNo;
  int? isDefault;

  BankData({
    this.id,
    this.providerId,
    this.bankName,
    this.branchName,
    this.accountNo,
    this.ifscNo,
    this.mobileNo,
    this.aadharNo,
    this.panNo,
    this.isDefault,
  });

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String _str(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  BankData.fromJson(Map<String, dynamic> json) {
    id = _int(json['id']);
    providerId = _int(json['provider_id']);
    bankName = _str(json['bank_name']);
    branchName = _str(json['branch_name']);
    accountNo = _str(json['account_no']);
    ifscNo = _str(json['ifsc_no']);
    mobileNo = _str(json['mobile_no']);
    aadharNo = _str(json['aadhar_no']);
    panNo = _str(json['pan_no']);
    isDefault = _int(json['is_default']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['bank_name'] = bankName;
    data['branch_name'] = branchName;
    data['account_no'] = accountNo;
    data['ifsc_no'] = ifscNo;
    data['mobile_no'] = mobileNo;
    data['aadhar_no'] = aadharNo;
    data['pan_no'] = panNo;
    data['is_default'] = isDefault;
    return data;
  }
}

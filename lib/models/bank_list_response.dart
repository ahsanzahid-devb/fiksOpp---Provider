class BankListResponse {
  Pagination pagination;
  List<BankHistory> data;

  BankListResponse({
    required this.pagination,
    this.data = const <BankHistory>[],
  });

  factory BankListResponse.fromJson(Map<String, dynamic> json) {
    return BankListResponse(
      pagination: json['pagination'] is Map ? Pagination.fromJson(json['pagination']) : Pagination(),
      data: json['data'] is List ? List<BankHistory>.from(json['data'].map((x) => BankHistory.fromJson(x))) : [],
    );
  }

  get id => null;

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Pagination {
  int totalItems;
  int perPage;
  int currentPage;
  int totalPages;
  int from;
  int to;
  dynamic nextPage;
  dynamic previousPage;

  Pagination({
    this.totalItems = -1,
    this.perPage = -1,
    this.currentPage = -1,
    this.totalPages = -1,
    this.from = -1,
    this.to = -1,
    this.nextPage,
    this.previousPage,
  });

  static int _int(dynamic v, [int def = -1]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: _int(json['total_items'], 0),
      perPage: _int(json['per_page']),
      currentPage: _int(json['currentPage']),
      totalPages: _int(json['totalPages']),
      from: _int(json['from']),
      to: _int(json['to']),
      nextPage: json['next_page'],
      previousPage: json['previous_page'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'per_page': perPage,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'from': from,
      'to': to,
      'next_page': nextPage,
      'previous_page': previousPage,
    };
  }
}

class BankHistory {
  int id;
  int providerId;
  String bankName;
  String branchName;
  String accountNo;
  String ifscNo;
  String mobileNo;
  String aadharNo;
  String panNo;
  List<dynamic> bankAttchments;
  int isDefault;

  BankHistory({
    this.id = -1,
    this.providerId = -1,
    this.bankName = "",
    this.branchName = "",
    this.accountNo = "",
    this.ifscNo = "",
    this.mobileNo = "",
    this.aadharNo = "",
    this.panNo = "",
    this.bankAttchments = const [],
    this.isDefault = -1,
  });

  static int _int(dynamic v, [int def = -1]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  static String _str(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  factory BankHistory.fromJson(Map<String, dynamic> json) {
    return BankHistory(
      id: _int(json['id']),
      providerId: _int(json['provider_id']),
      bankName: _str(json['bank_name']),
      branchName: _str(json['branch_name']),
      accountNo: _str(json['account_no']),
      ifscNo: _str(json['ifsc_no']),
      mobileNo: _str(json['mobile_no']),
      aadharNo: _str(json['aadhar_no']),
      panNo: _str(json['pan_no']),
      bankAttchments: json['bank_attchments'] is List ? List<dynamic>.from(json['bank_attchments']) : [],
      isDefault: _int(json['is_default'], -1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_no': accountNo,
      'ifsc_no': ifscNo,
      'mobile_no': mobileNo,
      'aadhar_no': aadharNo,
      'pan_no': panNo,
      'bank_attchments': [],
      'is_default': isDefault,
    };
  }
}

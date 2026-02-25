class WalletResponse {
  num? balance;

  WalletResponse({this.balance});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    final b = json['balance'];
    final num? balance = b == null ? null : (b is num ? b : num.tryParse(b.toString()));
    return WalletResponse(balance: balance ?? 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    return data;
  }
}
